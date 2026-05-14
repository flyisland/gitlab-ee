# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Security::Ascp::ScanType, feature_category: :static_application_security_testing do
  specify { expect(described_class.graphql_name).to eq('AscpScan') }

  it 'has expected fields' do
    expected_fields = %w[
      id
      scan_sequence
      commit_sha
      scan_type
      base_commit_sha
      base_scan
      created_at
      updated_at
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
