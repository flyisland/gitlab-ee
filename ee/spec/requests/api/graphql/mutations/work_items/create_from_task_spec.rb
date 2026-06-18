# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Create a work item from a task in a work item's description", feature_category: :team_planning do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:developer) { create(:user, developer_of: group) }
  let_it_be(:work_item, refind: true) do
    create(:work_item, :epic, namespace: group, description: '- [ ] A task in a list', lock_version: 3)
  end

  let(:task_type) { build(:work_item_system_defined_type, :task) }
  let(:input) do
    {
      'id' => work_item.to_gid.to_s,
      'workItemData' => {
        'title' => 'A task in a list',
        'workItemTypeId' => task_type.to_gid.to_s,
        'lineNumberStart' => 1,
        'lineNumberEnd' => 1,
        'lockVersion' => work_item.lock_version
      }
    }
  end

  let_it_be(:current_user) { developer }

  before do
    stub_licensed_features(epics: true)
  end

  it_behaves_like 'authorizing granular token permissions for GraphQL', :update_work_item do
    let(:user) { current_user }
    let(:boundary_object) { group }
    let(:mutation) do
      graphql_mutation(:workItemCreateFromTask, input, 'errors')
    end

    let(:request) { post_graphql_mutation(mutation, token: { personal_access_token: pat }) }
  end
end
