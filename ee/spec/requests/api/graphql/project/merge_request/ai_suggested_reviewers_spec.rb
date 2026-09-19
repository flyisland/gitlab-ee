# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting AI-suggested reviewers for a merge request', feature_category: :code_review_workflow do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project) }
  let_it_be(:user_a) { create(:user) }
  let_it_be(:user_b) { create(:user) }
  let_it_be(:catalog_item) do
    create(:ai_catalog_item, :with_foundational_flow_reference,
      foundational_flow_reference: 'recommend_reviewers/v1')
  end

  let_it_be(:foundational_flow) { ::Ai::Catalog::FoundationalFlow['recommend_reviewers/v1'] }

  let(:mr_fields) do
    <<~FIELDS
      aiSuggestedReviewers {
        nodes {
          user { username }
          reason
          createdAt
          approvalRule { name section }
        }
      }
    FIELDS
  end

  let(:query) do
    graphql_query_for(
      :project,
      { full_path: project.full_path },
      query_graphql_field(:merge_request, { iid: merge_request.iid.to_s }, mr_fields)
    )
  end

  let(:merge_requests_query) do
    graphql_query_for(
      :project,
      { full_path: project.full_path },
      query_graphql_field(:merge_requests, {}, "nodes { #{mr_fields} }")
    )
  end

  let(:reviewers_data) { graphql_data_at(:project, :merge_request, :ai_suggested_reviewers, :nodes) }

  before do
    project.project_setting.update!(duo_foundational_flows_enabled: true)
    create(:ai_catalog_enabled_foundational_flow, :for_project, project: project, catalog_item: catalog_item)
    allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_return(true)
    # FoundationalFlow[] returns a process-wide instance that memoizes catalog_item,
    # so another spec can leave a rolled-back record cached here.
    foundational_flow.clear_memoization(:catalog_item)
  end

  def add_merge_request_with_suggestion
    other_merge_request = create(:merge_request, :unique_branches, source_project: project)

    create(:ai_suggested_reviewer,
      merge_request: other_merge_request, project: project, user: create(:user),
      approval_project_rule: create(:approval_project_rule, project: project))
  end

  def create_suggestions
    create(:ai_suggested_reviewer,
      merge_request: merge_request, project: project, user: user_a, reason: 'Owns files.')
    create(:ai_suggested_reviewer,
      merge_request: merge_request, project: project, user: user_b, reason: 'Nearby code.')
  end

  context 'when the feature is available' do
    before do
      create_suggestions
    end

    it 'returns the persisted suggestions' do
      post_graphql(query, current_user: current_user)

      expect(reviewers_data).to match_array([
        a_hash_including('user' => { 'username' => user_a.username }, 'reason' => 'Owns files.'),
        a_hash_including('user' => { 'username' => user_b.username }, 'reason' => 'Nearby code.')
      ])
    end

    context 'when there are no suggestions' do
      before do
        MergeRequests::AiSuggestedReviewer.for_merge_request(merge_request).delete_all
      end

      it 'returns a non-null empty connection' do
        post_graphql(query, current_user: current_user)

        expect(graphql_data_at(:project, :merge_request, :ai_suggested_reviewers)).not_to be_nil
        expect(reviewers_data).to eq([])
      end
    end

    context 'when a suggestion is associated with an approval rule' do
      before do
        stub_licensed_features(merge_request_approvers: true, code_owners: true)
      end

      context 'with an ApprovalProjectRule' do
        let_it_be(:approval_rule) do
          create(:approval_project_rule, project: project, name: 'Backend', approvals_required: 1)
        end

        before do
          create(:ai_suggested_reviewer,
            merge_request: merge_request, project: project, user: create(:user),
            approval_project_rule: approval_rule)
        end

        it 'returns the approval rule' do
          post_graphql(query, current_user: current_user)

          expect(reviewers_data).to include(
            a_hash_including('approvalRule' => a_hash_including('name' => 'Backend'))
          )
        end
      end

      context 'with an ApprovalMergeRequestRule' do
        let_it_be(:approval_rule) do
          create(:code_owner_rule, merge_request: merge_request, name: '*.rb', section: 'codeowners')
        end

        before do
          create(:ai_suggested_reviewer,
            merge_request: merge_request, project: project, user: create(:user),
            approval_merge_request_rule: approval_rule)
        end

        it 'returns the approval rule' do
          post_graphql(query, current_user: current_user)

          expect(reviewers_data).to include(
            a_hash_including('approvalRule' => a_hash_including('name' => '*.rb', 'section' => 'codeowners'))
          )
        end
      end
    end

    it 'avoids N+1 queries as more merge requests return suggestions' do
      stub_licensed_features(merge_request_approvers: true)
      add_merge_request_with_suggestion

      post_graphql(merge_requests_query, current_user: current_user)

      control = ActiveRecord::QueryRecorder.new do
        post_graphql(merge_requests_query, current_user: current_user)
      end

      add_merge_request_with_suggestion

      expect do
        post_graphql(merge_requests_query, current_user: current_user)
      end.not_to exceed_query_limit(control)
    end
  end

  context 'when the flow is not available for the project' do
    before do
      allow(::Gitlab::Llm::StageCheck).to receive(:available?).and_return(false)
      create_suggestions
    end

    it 'returns null' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(:project, :merge_request, :ai_suggested_reviewers)).to be_nil
    end
  end
end
