# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ai::DuoWorkflows::WorkflowType, feature_category: :duo_agent_platform do
  include GraphqlHelpers

  it { expect(described_class).to have_graphql_field(:user) }

  describe 'field scopes' do
    using RSpec::Parameterized::TableSyntax

    where(:field_name) do
      %w[archived stalled resourceIid resourceWebUrl user workItem mergeRequest summary title]
    end

    with_them do
      it "includes the correct scopes for the #{params[:field_name]} field" do
        expect(described_class.fields[field_name].instance_variable_get(:@scopes)).to include(:api, :read_api,
          :ai_features, :ai_workflows)
      end
    end
  end

  describe 'auditEvents field' do
    it { expect(described_class).to have_graphql_field(:audit_events) }

    it 'returns an AiAuditEvent connection type' do
      expect(described_class.fields['auditEvents'].type.unwrap.graphql_name).to eq('AiAuditEventConnection')
    end
  end
end
