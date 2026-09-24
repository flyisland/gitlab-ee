# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Setting assignees of a merge request', :assume_throttled, feature_category: :code_review_workflow do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:current_user) { create(:user, developer_of: project) }
  let_it_be(:assignee) { create(:user) }
  let_it_be(:assignee2) { create(:user) }
  let_it_be_with_reload(:merge_request) { create(:merge_request, source_project: project) }

  let(:input) { { assignee_usernames: [assignee.username] } }

  let(:mutation) do
    variables = {
      project_path: project.full_path,
      iid: merge_request.iid.to_s
    }
    graphql_mutation(
      :merge_request_set_assignees,
      variables.merge(input),
      <<-QL.strip_heredoc
        clientMutationId
        errors
        mergeRequest {
          id
          assignees {
            nodes {
              username
            }
          }
        }
      QL
    )
  end

  def run_mutation!
    recorder = ActiveRecord::QueryRecorder.new do
      post_graphql_mutation(mutation, current_user: current_user)
    end

    expect(recorder.count).to be <= db_query_limit
  end

  before do
    merge_request.update!(assignees: [])
  end

  context 'when the current user does not have permission to add assignees' do
    let(:current_user) { create(:user) }
    let(:db_query_limit) { 39 }

    it 'does not change the assignees' do
      project.add_guest(current_user)

      expect { run_mutation! }.not_to change { merge_request.reset.assignees.pluck(:id) }

      expect(graphql_errors).not_to be_empty
    end
  end
end
