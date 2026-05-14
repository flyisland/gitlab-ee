# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Security::Parsers::Sarif, feature_category: :vulnerability_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  let(:report) { Gitlab::Ci::Reports::Security::Report.new('sarif', pipeline, nil) }

  def parse!(json_data, validate: false)
    described_class.parse!(json_data, report, validate: validate)
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
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => {
              'driver' => {
                'name' => 'TestTool',
                'rules' => [{
                  'id' => 'R1',
                  'properties' => { 'tags' => ['CVE-2021-44228'] }
                }]
              }
            },
            'results' => [{
              'ruleId' => 'R1',
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
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

    context 'with suppressions' do
      using RSpec::Parameterized::TableSyntax

      def sarif_with_suppression(status)
        suppression = { 'kind' => 'inSource' }
        suppression['status'] = status if status
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'results' => [{
              'ruleId' => 'R1',
              'suppressions' => [suppression],
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      where(:status, :expected_count) do
        nil           | 0  # no status = accepted by default
        'accepted'    | 0  # explicitly accepted
        'underReview' | 1  # contested - include the finding
        'rejected'    | 1  # contested - include the finding
      end

      with_them do
        it 'includes or skips the finding based on suppression status' do
          parse!(sarif_with_suppression(status))
          expect(report.findings.length).to eq(expected_count)
        end
      end

      it 'includes findings with no suppressions array' do
        json = {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'results' => [{
              'ruleId' => 'R1',
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
        parse!(json)
        expect(report.findings.length).to eq(1)
      end
    end

    context 'with severity from rule.properties.security-severity' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => {
              'driver' => {
                'name' => 'TestTool',
                'rules' => [{
                  'id' => 'R1',
                  'properties' => { 'security-severity' => '9.1' }
                }]
              }
            },
            'results' => [{
              'ruleId' => 'R1',
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      it 'maps rule.properties.security-severity 9.1 (×10 = 91.0) to critical' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('critical')
      end
    end

    context 'with rule.properties.security-severity taking precedence over result.properties' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => {
              'driver' => {
                'name' => 'TestTool',
                'rules' => [{
                  'id' => 'R1',
                  'properties' => { 'security-severity' => '2.0' }
                }]
              }
            },
            'results' => [{
              'ruleId' => 'R1',
              'properties' => { 'security-severity' => '9.9' },
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      it 'uses rule.properties (2.0 → low) over result.properties (9.9 → critical)' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('low')
      end
    end

    context 'with fullDescription as name and description fallback' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => {
              'driver' => {
                'name' => 'TestTool',
                'rules' => [{
                  'id' => 'R1',
                  'fullDescription' => { 'text' => 'A detailed description of the rule.' }
                }]
              }
            },
            'results' => [{
              'ruleId' => 'R1',
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
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
        let(:json_data) do
          {
            'version' => '2.1.0',
            'runs' => [{
              'tool' => { 'driver' => { 'name' => 'TestTool' } },
              'results' => [{
                'ruleId' => 'R1',
                'level' => level,
                'locations' => [{
                  'physicalLocation' => {
                    'artifactLocation' => { 'uri' => 'app/foo.rb' },
                    'region' => { 'startLine' => 1 }
                  }
                }]
              }]
            }]
          }.to_json
        end

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
        let(:json_data) do
          {
            'version' => '2.1.0',
            'runs' => [{
              'tool' => { 'driver' => { 'name' => 'TestTool' } },
              'results' => [{
                'ruleId' => 'R1',
                'rank' => rank,
                'level' => 'error',
                'locations' => [{
                  'physicalLocation' => {
                    'artifactLocation' => { 'uri' => 'app/foo.rb' },
                    'region' => { 'startLine' => 1 }
                  }
                }]
              }]
            }]
          }.to_json
        end

        it "maps rank #{params[:rank]} to '#{params[:expected_severity]}'" do
          parse!(json_data)
          expect(report.findings.first.severity).to eq(expected_severity)
        end
      end
    end

    context 'with severity from result.properties.security-severity (fallback)' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'results' => [{
              'ruleId' => 'R1',
              'properties' => { 'security-severity' => '7.5' },
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      it 'maps result.properties security-severity 7.5 (×10 = 75.0) to high when no rule.properties present' do
        parse!(json_data)
        expect(report.findings.first.severity).to eq('high')
      end
    end

    context 'with rank taking precedence over level and security-severity' do
      let(:json_data) do
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'results' => [{
              'ruleId' => 'R1',
              'rank' => 5.0,
              'level' => 'error',
              'properties' => { 'security-severity' => '9.9' },
              'locations' => [{
                'physicalLocation' => {
                  'artifactLocation' => { 'uri' => 'app/foo.rb' },
                  'region' => { 'startLine' => 1 }
                }
              }]
            }]
          }]
        }.to_json
      end

      it 'uses rank (5.0 → info) over level (error → high) and security-severity (9.9 → critical)' do
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
            'originalUriBaseIds' => {
              'SRCROOT' => { 'uri' => 'file:///workspace/' }
            },
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
      def result_without_rule_id(overrides = {})
        {
          'version' => '2.1.0',
          'runs' => [{
            'tool' => { 'driver' => { 'name' => 'TestTool' } },
            'results' => [
              overrides.merge(
                'message' => { 'text' => 'A finding with no rule association' },
                'locations' => [{
                  'physicalLocation' => {
                    'artifactLocation' => { 'uri' => 'app/foo.rb' },
                    'region' => { 'startLine' => 1 }
                  }
                }]
              )
            ]
          }]
        }.to_json
      end

      context 'when neither ruleId nor rule.id is present' do
        before do
          parse!(result_without_rule_id)
        end

        it 'skips the finding' do
          expect(report.findings).to be_empty
        end

        it 'adds an Identifier error to the report' do
          expect(report.errors).to include(
            a_hash_including(type: 'Identifier', message: /ruleId is required/)
          )
        end

        it 'includes a truncated excerpt of the result message in the error' do
          expect(report.errors.first[:message]).to include('A finding with no rule association')
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

        it 'adds no Identifier errors' do
          expect(report.errors.select { |e| e[:type] == 'Identifier' }).to be_empty
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

      it 'adds UUID errors for the two skipped results' do
        uuid_errors = report.errors.select { |e| e[:type] == 'UUID' }
        expect(uuid_errors.length).to eq(2)
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
