# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Security::Ascp::SecurityContextType, feature_category: :static_application_security_testing do
  specify { expect(described_class.graphql_name).to eq('AscpSecurityContext') }

  it 'has the expected fields' do
    expected_fields = %w[
      id
      summary
      authentication_model
      authorization_model
      data_sensitivity
      scan
      security_guidelines
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
