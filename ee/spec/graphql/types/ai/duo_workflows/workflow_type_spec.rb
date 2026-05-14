# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ai::DuoWorkflows::WorkflowType, feature_category: :duo_agent_platform do
  describe 'field scopes' do
    it 'includes the correct scopes for the archived field' do
      expect(described_class.fields['archived'].instance_variable_get(:@scopes)).to include(:api, :read_api,
        :ai_features, :ai_workflows)
    end

    it 'includes the correct scopes for the stalled field' do
      expect(described_class.fields['stalled'].instance_variable_get(:@scopes)).to include(:api, :read_api,
        :ai_features, :ai_workflows)
    end
  end
end
