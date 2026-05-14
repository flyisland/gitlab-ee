# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Security::Ascp::ComponentType, feature_category: :static_application_security_testing do
  specify { expect(described_class.graphql_name).to eq('AscpComponent') }

  it 'has the expected fields' do
    expected_fields = %w[
      id
      title
      description
      sub_directory
      expected_user_behavior
      scan
      security_context
      dependencies
      created_at
      updated_at
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
