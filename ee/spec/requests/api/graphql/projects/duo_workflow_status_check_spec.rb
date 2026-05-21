# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'querying duoWorkflowStatusCheck', feature_category: :duo_agent_platform do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :with_duo_features_enabled) }
  let_it_be(:current_user) { create(:user, developer_of: project) }

  describe 'duoWorkflowStatusCheck' do
    it 'is available to query' do
      result = GitlabSchema.execute(%(
        query {
          project(fullPath: "#{project.full_path}") {
            duoWorkflowStatusCheck {
              enabled
              createDuoWorkflowForCiAllowed
              checks {
                name
                value
                message
              }
            }
          }
        }
      ), context: { current_user: current_user }).as_json
      status = result.dig('data', 'project', 'duoWorkflowStatusCheck')

      expect(status['enabled']).to be_truthy
      expect(status['createDuoWorkflowForCiAllowed']).to be_falsey
      expect(status['checks']).to match_array([
        hash_including('name' => 'feature_flag', 'value' => true),
        hash_including('name' => 'duo_features_enabled', 'value' => true),
        hash_including('name' => 'developer_access', 'value' => false),
        hash_including('name' => 'feature_available', 'value' => false)
      ])
    end
  end
end
