# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Security::Ascp::SecurityGuidelineType, feature_category: :static_application_security_testing do
  specify { expect(described_class.graphql_name).to eq('AscpSecurityGuideline') }

  it 'has the expected fields' do
    expected_fields = %w[
      id
      name
      operation
      legitimate_use
      security_boundary
      business_context
      severity_if_violated
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
