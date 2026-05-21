# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Security::Parsers::Sarif, feature_category: :vulnerability_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  let(:report) { Gitlab::Ci::Reports::Security::Report.new('sarif', pipeline, nil) }

  def parse!(json_data, validate: false)
    described_class.parse!(json_data, report, validate: validate)
  end

  # Build a minimal SARIF JSON string around the provided results array.
  # Use this instead of duplicating the outer envelope in every context.
  def sarif_doc(results:, tool_name: 'TestTool', rules: [])
    {
      'version' => '2.1.0',
      'runs' => [{
        'tool' => { 'driver' => { 'name' => tool_name, 'rules' => rules } },
        'results' => results
      }]
    }.to_json
  end

  # A result that will be accepted: has ruleId and physicalLocation.
  def valid_result(rule_id: 'R1', file: 'app/foo.rb', line: 1, **overrides)
    {
      'ruleId' => rule_id,
      'locations' => [{
        'physicalLocation' => {
          'artifactLocation' => { 'uri' => file },
          'region' => { 'startLine' => line }
        }
      }]
    }.merge(overrides)
  end

  # A result that will be skipped: has ruleId but no physicalLocation.
  def invalid_result(rule_id: 'R1-invalid')
    { 'ruleId' => rule_id }
  end

  describe '.parse!' do
    context 'with a minimal valid SARIF document' do
      let(:json_data) { fixture_file('security_reports/sarif/minimal.sarif.json', dir: 'ee') }

      before do
        parse!(json_data)
      end

      it 'adds findings to the report' do
        expect(report.findings).not_to be_empty
      end

      it 'sets the scanner name from tool.driver.name' do
        expect(report.scanner.name).to eq('Semgrep')
      end

      it 'sets the scanner external_id as a downcased slug' do
        expect(report.scanner.external_id).to eq('semgrep')
      end
    end

    context 'with a full valid SARIF document' do
      let(:json_data) { fixture_file('security_reports/sarif/valid.sarif.json', dir: 'ee') }

      before do
        parse!(json_data)
      end

      it 'parses all findings' do
        expect(report.findings.length).to eq(2)
      end

      it 'uses rule shortDescription as the finding name' do
        expect(report.findings.first.name).to eq('Potential SQL injection vulnerability')
      end

      it 'sets description from result.message.text' do
        expected = 'User input is used directly in a SQL query without sanitization.'
        expect(report.findings.first.description).to eq(expected)
      end

      it 'sets file_path from artifactLocation.uri' do
        expect(report.findings.first.location.file_path).to eq('app/models/user.rb')
      end

      it 'sets start_line and end_line from region' do
        location = report.findings.first.location
        expect(location.start_line).to eq(42)
        expect(location.end_line).to eq(42)
      end

      it 'stores location_data with file/start_line/end_line keys for persistence' do
        location_data = report.findings.first.location_data
        expect(location_data).to eq({
          'file' => 'app/models/user.rb',
          'start_line' => 42,
          'end_line' => 42
        })
      end

      it 'creates a primary identifier scoped to the tool name' do
        primary = report.findings.first.identifiers.first
        expect(primary.external_type).to eq('semgrep')
        expect(primary.external_id).to eq('sql-injection')
      end

      it 'extracts CWE tags as secondary identifiers' do
        cwe_id = report.findings.first.identifiers.find { |i| i.external_type == 'cwe' }
        expect(cwe_id).not_to be_nil
        expect(cwe_id.external_id).to eq('89')
        expect(cwe_id.url).to eq('https://cwe.mitre.org/data/definitions/89.html')
      end
    end

    context 'with a CVE tag on the rule' do
      let(:json_data) do
        sarif_doc(
          rules: [{ 'id' => 'R1', 'properties' => { 'tags' => ['CVE-2021-44228'] } }],
          results: [valid_result]
        )
      end

      before do
        parse!(json_data)
      end

      it 'extracts CVE tags as secondary identifiers' do
        cve_id = report.findings.first.identifiers.find { |i| i.external_type == 'cve' }
        expect(cve_id).not_to be_nil
        expect(cve_id.external_id).to eq('2021-44228')
        expect(cve_id.url).to eq('https://www.cve.org/CVERecord?id=CVE-2021-44228')
      end
    end

    describe 'suppression' do
      context 'with suppressions' do
        using RSpec::Parameterized::TableSyntax

        where(:status, :expected_count) do
          nil           | 0  # no status = accepted suppression by default
          'accepted'    | 0  # explicitly accepted
          'underReview' | 1  # contested - include the finding
          'rejected'    | 1  # contested - include the finding
        end

        with_them do
          it 'includes or skips the finding based on suppression status' do
            suppression = { 'kind' => 'inSource', 'status' => status }
            json = sarif_doc(results: [valid_result('suppressions' => [suppression])])
            parse!(json)
            expect(report.findings.length).to eq(expected_count)
          end
        end
      end

      context 'without suppressions' do
        it 'includes findings' do
          json = sarif_doc(results: [valid_result])
          parse!(json)
          expect(report.findings.length).to eq(1)
        end
      end
    end

    context 'with severity from rule.properties.security-severity' do
      let(:json_data) do
        sarif_doc(
          rules: [{ 'id' => 'R1', 'properties' => { 'security-severity' => '9.1' } }],
          results: [valid_result]
        )
      end

      it 'maps rule.properties.security-severity 9.1 (x10 = 91.0) to critical' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('critical')
      end
    end

    context 'with rule.properties.security-severity taking precedence over result.properties' do
      let(:json_data) do
        sarif_doc(
          rules: [{ 'id' => 'R1', 'properties' => { 'security-severity' => '2.0' } }],
          results: [valid_result('properties' => { 'security-severity' => '9.9' })]
        )
      end

      it 'uses rule.properties (2.0 -> low) over result.properties (9.9 -> critical)' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('low')
      end
    end

    context 'with fullDescription as name and description fallback' do
      let(:json_data) do
        sarif_doc(
          rules: [{ 'id' => 'R1', 'fullDescription' => { 'text' => 'A detailed description of the rule.' } }],
          results: [valid_result]
        )
      end

      before do
        parse!(json_data)
      end

      it 'uses fullDescription.text as the finding name when no shortDescription or message' do
        expect(report.findings.first.name).to eq('A detailed description of the rule.')
      end

      it 'uses fullDescription.text as the description when no message.text' do
        expect(report.findings.first.description).to eq('A detailed description of the rule.')
      end
    end

    context 'with severity from level field' do
      using RSpec::Parameterized::TableSyntax

      where(:level, :expected_severity) do
        'error'   | 'high'
        'warning' | 'medium'
        'note'    | 'low'
        'none'    | 'info'
      end

      with_them do
        let(:json_data) { sarif_doc(results: [valid_result('level' => level)]) }

        it "maps level '#{params[:level]}' to '#{params[:expected_severity]}'" do
          parse!(json_data)
          expect(report.findings.first.severity).to eq(expected_severity)
        end
      end
    end

    context 'with severity from rank field' do
      using RSpec::Parameterized::TableSyntax

      where(:rank, :expected_severity) do
        0.0   | 'info'
        9.9   | 'info'
        10.0  | 'low'
        39.9  | 'low'
        40.0  | 'medium'
        69.9  | 'medium'
        70.0  | 'high'
        89.9  | 'high'
        90.0  | 'critical'
        100.0 | 'critical'
      end

      with_them do
        let(:json_data) { sarif_doc(results: [valid_result('rank' => rank, 'level' => 'error')]) }

        it "maps rank #{params[:rank]} to '#{params[:expected_severity]}'" do
          parse!(json_data)
          expect(report.findings.first.severity).to eq(expected_severity)
        end
      end
    end

    context 'with severity from result.properties.security-severity (fallback)' do
      let(:json_data) { sarif_doc(results: [valid_result('properties' => { 'security-severity' => '7.5' })]) }

      it 'maps result.properties security-severity 7.5 (x10 = 75.0) to high when no rule.properties present' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('high')
      end
    end

    context 'with rank taking precedence over level and security-severity' do
      let(:json_data) do
        sarif_doc(results: [valid_result('rank' => 5.0, 'level' => 'error',
          'properties' => { 'security-severity' => '9.9' })])
      end

      it 'uses rank (5.0 -> info) over level (error -> high) and security-severity (9.9 -> critical)' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('info')
      end
    end

    context 'with uriBaseId resolution' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'originalUriBaseIds' => { 'SRCROOT' => { 'uri' => 'file:///workspace/' } },
            'results' => [{
              'ruleId' => 'R1',
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'src/main.rb', 'uriBaseId' => 'SRCROOT' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      it 'resolves the full file path' do
        parse!(json_data)
        expect(report.findings.first.location.file_path).to eq('/workspace/src/main.rb')
      end
    end

    context 'with multiple runs' do
      let(:json_data) { fixture_file('security_reports/sarif/multi_run.sarif.json', dir: 'ee') }

      before do
        parse!(json_data)
      end

      it 'includes findings from all runs' do
        expect(report.findings.length).to eq(2)
      end

      it 'sets report.scanner to the first run scanner' do
        expect(report.scanner.name).to eq('Semgrep')
      end

      it 'registers all run scanners in report.scanners' do
        expect(report.scanners.keys).to match_array(%w[semgrep eslint])
      end

      it 'attributes each finding to its own run scanner' do
        semgrep_finding = report.findings.find { |f| f.location.file_path == 'app/models/user.rb' }
        eslint_finding  = report.findings.find { |f| f.location.file_path == 'app/javascript/utils.js' }

        expect(semgrep_finding.scanner.external_id).to eq('semgrep')
        expect(eslint_finding.scanner.external_id).to eq('eslint')
      end
    end

    context 'with missing ruleId' do
      # A result that has a physical location and a message but no ruleId/rule.id.
      def result_without_rule_id(overrides = {})
        base = valid_result('message' => { 'text' => 'A finding with no rule association' })
          .except('ruleId')
          .merge(overrides)
        sarif_doc(results: [base])
      end

      context 'when neither ruleId nor rule.id is present' do
        before do
          allow(Gitlab::AppLogger).to receive(:info)
          parse!(result_without_rule_id)
        end

        it 'skips the finding' do
          expect(report.findings).to be_empty
        end

        it 'logs an info message for the skipped finding' do
          expect(Gitlab::AppLogger).to have_received(:info).with(
            a_hash_including(
              message: "SARIF finding skipped: ruleId absent",
              result_message: include('A finding with no rule association')
            )
          )
        end

        it 'adds a drop count error when all results are skipped (100% > 50% threshold)' do
          expect(report.errors).to include(
            a_hash_including(type: 'Ingestion', message: /1 of 1 result\(s\) could not be ingested/)
          )
        end

        it 'does not add any warnings for the drop' do
          expect(report.warnings).to be_empty
        end
      end

      context 'when ruleId is absent but rule.id is present' do
        before do
          parse!(result_without_rule_id('rule' => { 'id' => 'R1' }))
        end

        it 'accepts the finding using rule.id as the rule identifier' do
          expect(report.findings.length).to eq(1)
        end

        it 'sets the primary identifier from rule.id' do
          primary = report.findings.first.identifiers.first
          expect(primary.external_type).to eq('testtool')
          expect(primary.external_id).to eq('R1')
        end

        it 'does not add any warnings' do
          expect(report.warnings).to be_empty
        end
      end

      context 'when both ruleId and rule.id are present and equal' do
        before do
          parse!(result_without_rule_id('ruleId' => 'R1', 'rule' => { 'id' => 'R1' }))
        end

        it 'accepts the finding' do
          expect(report.findings.length).to eq(1)
        end

        it 'uses ruleId as the primary identifier' do
          expect(report.findings.first.identifiers.first.external_id).to eq('R1')
        end
      end
    end

    context 'with invalid JSON' do
      it 'raises SecurityReportParserError' do
        expect { parse!('not json {{{') }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, /parsing failed/i)
      end
    end

    context 'with validate: true and a schema-invalid document' do
      let(:json_data) { { 'version' => '2.1.0' }.to_json }

      it 'adds schema errors to the report and returns no findings' do
        parse!(json_data, validate: true)

        expect(report.findings).to be_empty
        expect(report.errors).not_to be_empty
      end
    end

    context 'with validate: true and an unsupported version' do
      let(:json_data) { { 'version' => '1.0.0', 'runs' => [] }.to_json }

      it 'adds a version error and returns no findings' do
        parse!(json_data, validate: true)

        expect(report.findings).to be_empty
        expect(report.errors.pluck(:message).join).to match(/Unsupported SARIF version/)
      end
    end

    context 'with no_locations fixture' do
      let(:json_data) { fixture_file('security_reports/sarif/no_locations.sarif.json', dir: 'ee') }

      before do
        allow(Gitlab::AppLogger).to receive(:info)
        parse!(json_data)
      end

      it 'accepts the result with a physical location but no region' do
        expect(report.findings.length).to eq(1)
        expect(report.findings.first.location.file_path).to eq('app/models/user.rb')
      end

      it 'sets nil lines for the no-region result' do
        location = report.findings.first.location
        expect(location.start_line).to be_nil
        expect(location.end_line).to be_nil
      end

      it 'logs info messages for the two skipped results' do
        expect(Gitlab::AppLogger).to have_received(:info).with(
          a_hash_including(message: "SARIF finding skipped: no physicalLocation", rule_id: 'rule-no-locations')
        )
        expect(Gitlab::AppLogger).to have_received(:info).with(
          a_hash_including(message: "SARIF finding skipped: no physicalLocation", rule_id: 'rule-logical-only')
        )
      end

      it 'adds a drop count error when the drop rate exceeds the 50% threshold (2/3 = 66.7%)' do
        expect(report.errors).to include(
          a_hash_including(type: 'Ingestion', message: /2 of 3 result\(s\) could not be ingested/)
        )
      end

      it 'does not add an Ingestion warning' do
        expect(report.warnings).to be_empty
      end
    end

    describe 'ingestion failure threshold' do
      before do
        allow(Gitlab::AppLogger).to receive(:info)
        parse!(json_data)
      end

      context 'when drop rate is 0% (all results valid)' do
        let(:json_data) { sarif_doc(results: [valid_result(rule_id: 'R1'), valid_result(rule_id: 'R2')]) }

        it 'emits no Ingestion warning' do
          expect(report.warnings).to be_empty
        end

        it 'emits no Ingestion error' do
          expect(report.errors).to be_empty
        end

        it 'ingests all findings' do
          expect(report.findings.length).to eq(2)
        end
      end

      context 'when drop rate is 50% (at threshold, partial ingestion)' do
        let(:json_data) { sarif_doc(results: [valid_result, invalid_result]) }

        it 'emits an Ingestion warning with the drop count' do
          expect(report.warnings).to include(
            a_hash_including(type: 'Ingestion', message: /1 of 2 result\(s\) were skipped/)
          )
        end

        it 'emits no Ingestion error' do
          expect(report.errors.map { |e| e[:type] }).not_to include('Ingestion')
        end

        it 'ingests only the valid findings' do
          expect(report.findings.length).to eq(1)
        end
      end

      context 'when drop rate is 67% (above threshold, scan aborted)' do
        let(:json_data) do
          sarif_doc(results: [valid_result, invalid_result(rule_id: 'R-inv-1'), invalid_result(rule_id: 'R-inv-2')])
        end

        it 'emits an Ingestion error with the drop count' do
          expect(report.errors).to include(
            a_hash_including(type: 'Ingestion', message: /2 of 3 result\(s\) could not be ingested/)
          )
        end

        it 'emits no Ingestion warning' do
          expect(report.warnings.map { |w| w[:type] }).not_to include('Ingestion')
        end

        it 'ingests only the valid findings' do
          expect(report.findings.length).to eq(1)
        end
      end

      context 'when drop rate is 100% (all results invalid, scan aborted)' do
        let(:json_data) { sarif_doc(results: [invalid_result]) }

        it 'emits an Ingestion error with the drop count' do
          expect(report.errors).to include(
            a_hash_including(type: 'Ingestion', message: /1 of 1 result\(s\) could not be ingested/)
          )
        end

        it 'emits no Ingestion warning' do
          expect(report.warnings.map { |w| w[:type] }).not_to include('Ingestion')
        end

        it 'ingests no findings' do
          expect(report.findings).to be_empty
        end
      end
    end
  end

  describe '#calculate_uuid' do
    let(:json_data) { fixture_file('security_reports/sarif/minimal.sarif.json', dir: 'ee') }
    let(:finding_instance_double) { instance_double(::Gitlab::Ci::Reports::Security::Finding) }

    context 'when primary_identifier is nil' do
      it 'logs an info message and returns nil' do
        allow(::Gitlab::Ci::Reports::Security::Finding).to receive(:new).and_return(finding_instance_double)
        allow(finding_instance_double).to receive(:uuid).and_return(nil)

        expect(Gitlab::AppLogger).to receive(:info).with(
          a_hash_including(message: "SARIF finding skipped: nil UUID components")
        )

        parse!(json_data)
      end
    end
  end

  describe '.rank_to_severity' do
    using RSpec::Parameterized::TableSyntax

    where(:rank, :expected) do
      0.0   | 'info'
      9.9   | 'info'
      10.0  | 'low'
      39.9  | 'low'
      40.0  | 'medium'
      69.9  | 'medium'
      70.0  | 'high'
      89.9  | 'high'
      90.0  | 'critical'
      100.0 | 'critical'
    end

    with_them do
      it "maps rank #{params[:rank]} to #{params[:expected]}" do
        expect(described_class.rank_to_severity(rank)).to eq(expected)
      end
    end
  end
end
