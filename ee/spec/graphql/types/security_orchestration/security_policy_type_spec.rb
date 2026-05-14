# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::SecurityOrchestration::SecurityPolicyType, feature_category: :security_policy_management do
  let(:fields) do
    %i[id policy_configuration_id description edit_path enabled name updated_at yaml policy_scope csp policy_attributes
      type test_runs]
  end

  it { expect(described_class).to have_graphql_fields(fields) }
end
