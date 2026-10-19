# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Finding do
  it { is_expected.to define_enum_for(:report_type) }
  it { is_expected.to define_enum_for(:severity) }
  it { is_expected.to define_enum_for(:detection_method) }

  where(vulnerability_finding_signatures: [true, false])
  with_them do
    before do
      stub_licensed_features(vulnerability_finding_signatures: vulnerability_finding_signatures)
    end

    describe '#other_identifier_values_with_links' do
      let(:finding) { build(:vulnerabilities_finding) }
      let(:expected_values) do
        ['ID 1,http://cve.mitre.org/cgi-bin/cvename.cgi?name=2018-1234', 'ID 2,http://cve.mitre.org/cgi-bin/cvename.cgi?name=2018-1234']
      end

      subject { finding.other_identifier_values_with_links }

      before do
        finding.identifiers << build(:vulnerabilities_identifier, external_type: 'foo', name: 'ID 1', url: 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=2018-1234')
        finding.identifiers << build(:vulnerabilities_identifier, external_type: 'bar', name: 'ID 2', url: 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=2018-1234')
      end

      it { is_expected.to match_array(expected_values) }
    end
  end
end
