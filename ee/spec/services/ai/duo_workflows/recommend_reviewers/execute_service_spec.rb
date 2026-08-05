# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::RecommendReviewers::ExecuteService, feature_category: :code_review_workflow do
  subject(:service) { described_class.new(merge_request: merge_request, current_user: current_user) }

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:current_user) { create(:user, developer_of: project) }
  let_it_be(:merge_request) { create(:merge_request, source_project: project, target_project: project) }

  let(:create_and_start_result) { ServiceResponse.success }
  let(:create_and_start_double) do
    instance_double(::Ai::DuoWorkflows::CreateAndStartWorkflowService, execute: create_and_start_result)
  end

  before do
    allow(::Ai::DuoWorkflows::CreateAndStartWorkflowService)
      .to receive(:new).and_return(create_and_start_double)
  end

  describe '#execute' do
    it 'starts a workflow with the correct parameters' do
      expected_reviewer_data = Ai::DuoWorkflows::RecommendReviewers::ReviewerDataBuilder.build(merge_request)

      service.execute

      expect(::Ai::DuoWorkflows::CreateAndStartWorkflowService).to have_received(:new).with(
        container: project,
        current_user: current_user,
        workflow_definition: ::Ai::Catalog::FoundationalFlow['recommend_reviewers/v1'],
        goal: merge_request.iid.to_s,
        source_branch: merge_request.source_branch,
        additional_context: [
          {
            "Category" => "reviewer_data",
            "Content" => ::Gitlab::Json.dump(expected_reviewer_data)
          }
        ]
      )
    end

    it 'returns the workflow service result' do
      expect(service.execute).to eq(create_and_start_result)
    end
  end
end
