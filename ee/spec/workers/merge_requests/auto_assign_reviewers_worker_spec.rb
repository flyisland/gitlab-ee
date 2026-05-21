# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::AutoAssignReviewersWorker, feature_category: :code_review_workflow do
  let_it_be(:project) do
    create(:project, :repository).tap do |p|
      p.project_setting.update!(reviewer_assignment_strategy: 'code_owners')
    end
  end

  let_it_be(:automation_bot) { Users::Internal.in_organization(project.organization_id).automation_bot }

  let(:merge_request) { create(:merge_request, source_project: project) }

  before do
    stub_licensed_features(merge_request_approvers: true, multiple_merge_request_reviewers: true, code_owners: true)
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [merge_request.id] }
  end

  describe '#perform' do
    context 'when merge request does not exist' do
      it 'does nothing' do
        expect(MergeRequests::ReviewerAssignment::AssignService).not_to receive(:new)

        described_class.new.perform(non_existing_record_id)
      end
    end

    context 'when reviewer auto assignment is disabled' do
      before do
        merge_request.project.project_setting.update!(reviewer_assignment_strategy: 'disabled')
      end

      it 'does nothing' do
        expect(MergeRequests::ReviewerAssignment::AssignService).not_to receive(:new)

        described_class.new.perform(merge_request.id)
      end
    end

    context 'when merge request exists' do
      it 'delegates to AssignService with the automation bot as current_user' do
        expect_next_instance_of(
          MergeRequests::ReviewerAssignment::AssignService,
          merge_request: merge_request,
          current_user: automation_bot
        ) do |service|
          expect(service).to receive(:execute)
        end

        described_class.new.perform(merge_request.id)
      end
    end
  end
end
