# frozen_string_literal: true

module Gitlab
  module Security
    module Parsers
      class Sarif
        SecurityReportParserError = Class.new(::Gitlab::Ci::Parsers::ParserError)

        LEVEL_TO_SEVERITY = {
          'error' => 'high',
          'warning' => 'medium',
          'note' => 'low',
          'none' => 'info'
        }.freeze

        DEFAULT_SEVERITY = 'medium'

        def self.rank_to_severity(rank)
          case rank
          when 0.0..9.9   then 'info'
          when 10.0..39.9 then 'low'
          when 40.0..69.9 then 'medium'
          when 70.0..89.9 then 'high'
          else                 'critical'
          end
        end

        def self.parse!(json_data, report, validate: false, **)
          new(json_data, report, validate: validate).parse!
        end

        def initialize(json_data, report, validate: false, **)
          @json_data = json_data
          @report    = report
          @project   = report.project
          @validate  = validate
        end

        def parse!
          sanitize_json_data

          return report unless valid?
          raise SecurityReportParserError, "Invalid report format" unless report_data.is_a?(Hash)

          Array(report_data['runs']).each { |run| process_run(run) }

          report
        rescue JSON::ParserError
          raise SecurityReportParserError, 'JSON parsing failed'
        rescue SecurityReportParserError
          raise
        rescue StandardError
          raise SecurityReportParserError, 'SARIF security report parsing failed'
        end

        private

        attr_reader :json_data, :report, :validate, :project

        # PostgreSQL cannot store texts containing the unicode null character (U+0000).
        # The regex matches unescaped \u0000 sequences in the raw JSON string and
        # escapes them so Oj parses them as the literal string "\u0000" rather than
        # the null byte. This is identical to the sanitisation in Common#sanitize_json_data.
        def sanitize_json_data
          return unless json_data.gsub!(/(?<!\\)(?:\\\\)*\\u0000/, '\\\\\u0000')

          report.add_warning('Parsing',
            'Report artifact contained unicode null characters which are escaped during ingestion.')
        end

        def valid?
          return true unless validate

          validator = ::Gitlab::Security::Parsers::Validators::SarifSchemaValidator.new(report_data)
          validator.errors.each { |error| report.add_error('Schema', error) }
          validator.valid?
        end

        def report_data
          @report_data ||= Gitlab::Json.safe_parse(json_data)
        end

        def process_run(run)
          driver    = run.dig('tool', 'driver') || {}
          rules     = index_rules(driver['rules'])
          scanner   = build_scanner(driver)
          orig_uris = run['originalUriBaseIds'] || {}

          # First run's scanner becomes the report-level default, used by
          # MergeReportsService and scanner_order_to. All run scanners are
          # registered in report.scanners so StoreScanService can upsert each one.
          report.scanner ||= scanner
          report.add_scanner(scanner)

          Array(run['results']).each do |result|
            process_result(result, rules, scanner, orig_uris)
          end
        end

        # Build a lookup hash: ruleId => rule object, scoped to the current run.
        # Rules are defined per-run inside tool.driver.rules (and optionally in
        # tool.extensions[].rules). Indexing per-run is correct: the SARIF spec
        # allows different runs to use the same ruleId with different definitions.
        def index_rules(rules_array)
          return {} unless rules_array.is_a?(Array)

          rules_array.index_by { |r| r['id'] }
        end

        def build_scanner(driver)
          name = driver['name'].to_s
          ::Gitlab::Ci::Reports::Security::Scanner.new(
            external_id: name.downcase.gsub(/\s+/, '-').presence || 'sarif',
            name: name,
            vendor: driver['organization'] || driver['informationUri'],
            version: driver['version'] || driver['semanticVersion']
          )
        end

        def process_result(result, rules, scanner, orig_uris)
          return if suppressed?(result)

          rule_id = result['ruleId'] || result.dig('rule', 'id')
          if rule_id.blank?
            report.add_error('Identifier',
              "Finding skipped: ruleId is required for stable tracking but was absent in result: " \
                "#{message_text(result).to_s.truncate(100)}")
            return
          end

          rule        = rules[rule_id] || {}
          severity    = resolve_severity(result, rule)
          location    = build_location(result, orig_uris)
          identifiers = build_identifiers(rule_id, rule, scanner)

          uuid = calculate_uuid(identifiers.first, location&.fingerprint)
          return unless uuid

          report.add_finding(
            ::Gitlab::Ci::Reports::Security::Finding.new(
              uuid: uuid,
              report_type: report.type,
              name: finding_name(result, rule, identifiers),
              severity: ::Enums::Vulnerability.parse_severity_level(severity),
              confidence: nil,
              location: location,
              evidence: nil,
              scanner: scanner,
              scan: report.scan,
              identifiers: identifiers,
              flags: [],
              links: build_links(rule),
              remediations: [],
              original_data: result.merge(
                'description' => message_text(result) || full_description_text(rule),
                'location' => location_data(location)
              ),
              metadata_version: report_data['version'],
              details: {},
              signatures: [],
              project_id: project.id,
              found_by_pipeline: report.pipeline,
              vulnerability_finding_signatures_enabled: false,
              cvss: []
            )
          )
        end

        # Severity resolution priority (highest to lowest):
        #   1. result.rank                         - 0.0-100.0 float; most precise when present
        #   2. rule.properties.security-severity   - GitHub-convention CVSS-like float (0-10 scale);
        #                                            canonical location per SARIF convention
        #   3. result.properties.security-severity - some tools emit here instead
        #   4. result.level                        - SARIF enum: error|warning|note|none
        #   5. rule.defaultConfiguration.level     - rule author's default level
        #   6. DEFAULT_SEVERITY                    - safe fallback
        def resolve_severity(result, rule)
          if result['rank']
            self.class.rank_to_severity(result['rank'].to_f)
          else
            sec_sev = rule.dig('properties', 'security-severity').presence ||
              result.dig('properties', 'security-severity').presence

            if sec_sev
              self.class.rank_to_severity(sec_sev.to_f * 10)
            else
              level = result['level'] || rule.dig('defaultConfiguration', 'level')
              LEVEL_TO_SEVERITY.fetch(level, DEFAULT_SEVERITY)
            end
          end
        end

        # A result is suppressed when it has at least one suppression entry and none
        # of them are contested (underReview or rejected). This mirrors the logic in
        # the Go SARIF converter in the analyzers/report package.
        def suppressed?(result)
          suppressions = result['suppressions']
          return false if suppressions.blank?

          suppressions.none? { |s| s['status'] == 'underReview' || s['status'] == 'rejected' }
        end

        # Prefers the first physicalLocation. Falls back to nil (logical locations
        # like function names are not yet mapped).
        def build_location(result, orig_uris)
          ploc = result.dig('locations', 0, 'physicalLocation')
          return unless ploc

          uri    = resolve_uri(ploc['artifactLocation'], orig_uris)
          region = ploc['region'] || {}

          ::Gitlab::Ci::Reports::Security::Locations::Sarif.new(
            file_path: uri,
            start_line: region['startLine'],
            end_line: region['endLine'],
            start_column: region['startColumn'],
            end_column: region['endColumn']
          )
        end

        # Resolve uriBaseId references from originalUriBaseIds.
        # Most tools emit plain relative paths without uriBaseId; handle gracefully.
        def resolve_uri(artifact_location, orig_uris)
          return unless artifact_location.is_a?(Hash)

          uri     = artifact_location['uri'].to_s
          base_id = artifact_location['uriBaseId']

          if base_id && orig_uris[base_id]
            base_uri = orig_uris.dig(base_id, 'uri').to_s.delete_prefix('file://').delete_suffix('/')
            rel_uri = uri.delete_prefix('/')
            base_uri.empty? ? rel_uri : "#{base_uri}/#{rel_uri}"
          else
            uri.delete_prefix('file://').sub(%r{\A%[A-Z_]+%/?}, '')
          end
        end

        # Primary identifier: ruleId scoped to the tool name to prevent cross-tool
        # collisions when multiple SARIF reports are ingested for the same project.
        # Secondary identifiers: CWE/CVE tags from rule.properties.tags.
        def build_identifiers(rule_id, rule, scanner)
          ids = []

          if rule_id.present?
            ids << report.add_identifier(
              ::Gitlab::Ci::Reports::Security::Identifier.new(
                external_type: scanner.external_id,
                external_id: rule_id,
                name: rule['name'] || rule.dig('shortDescription', 'text') || rule_id,
                url: rule['helpUri']
              )
            )
          end

          Array(rule.dig('properties', 'tags')).each do |tag|
            m = tag.match(/\A(cwe|cve)[:-](\S+)\z/i)
            next unless m

            type  = m[1].downcase
            value = m[2]
            ids << report.add_identifier(
              ::Gitlab::Ci::Reports::Security::Identifier.new(
                external_type: type,
                external_id: value,
                name: tag,
                url: identifier_url(type, value)
              )
            )
          end

          ids.compact
        end

        def identifier_url(type, value)
          case type
          when 'cwe' then "https://cwe.mitre.org/data/definitions/#{value.delete_prefix('CWE-')}.html"
          when 'cve' then "https://www.cve.org/CVERecord?id=CVE-#{value.upcase.delete_prefix('CVE-')}"
          end
        end

        def message_text(result)
          result.dig('message', 'text') || result.dig('message', 'markdown')
        end

        def full_description_text(rule)
          rule.dig('fullDescription', 'text')
        end

        # Serialize the parsed location into the shape the rest of the GitLab
        # security pipeline expects in original_data['location']: the model reads
        # location['file'], location['start_line'], and location['end_line'].
        def location_data(location)
          return {} unless location

          {
            'file' => location.file_path,
            'start_line' => location.start_line,
            'end_line' => location.end_line
          }.compact
        end

        def build_links(rule)
          return [] unless rule['helpUri'].present?

          [::Gitlab::Ci::Reports::Security::Link.new(name: 'Rule documentation', url: rule['helpUri'])]
        end

        # Naming priority (highest to lowest):
        #   1. rule.shortDescription.text - stable, rule-authored title (preferred)
        #   2. result.message.text / .markdown - truncated to 255 chars
        #   3. rule.fullDescription.text - truncated to 255 chars
        #   4. identifiers.first.name - derived from ruleId
        #   5. 'Unknown finding' - absolute fallback
        def finding_name(result, rule, identifiers)
          short_desc = rule.dig('shortDescription', 'text')
          return short_desc if short_desc.present?

          msg = message_text(result)
          return msg.truncate(255) if msg.present?

          full_desc = full_description_text(rule)
          return full_desc.truncate(255) if full_desc.present?

          identifiers.first&.name || 'Unknown finding'
        end

        def calculate_uuid(primary_identifier, location_fingerprint)
          components = {
            report_type: report.type,
            primary_identifier_fingerprint: primary_identifier&.fingerprint,
            location_fingerprint: location_fingerprint,
            project_id: project.id
          }

          if components.values.any?(&:nil?)
            report.add_error(
              'UUID',
              "Finding skipped: one or more UUID components are nil - #{components.inspect}"
            )
            return
          end

          ::Security::VulnerabilityUUID.generate(**components)
        end
      end
    end
  end
end
