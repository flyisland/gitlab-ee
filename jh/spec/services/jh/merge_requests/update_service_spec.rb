# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::MergeRequests::UpdateService, feature_category: :code_review_workflow do
  describe '#handle_topic_label_changes' do
    let(:project) { instance_double(Project) }
    let(:user) { instance_double(User) }
    let(:merge_request) { instance_double(MergeRequest) }
    let(:service) { MergeRequests::UpdateService.new(project: project, current_user: user, params: {}) }
    let(:topic_label) { instance_double(Label, title: 'topic::test1') }
    let(:topic_label2) { instance_double(Label, title: 'topic::test2') }
    let(:regular_label) { instance_double(Label, title: 'bug') }
    let(:monorepo_service) { instance_double(MergeRequests::MonorepoService) }

    before do
      allow(service).to receive(:merge_request).and_return(merge_request)
      allow(MergeRequests::MonorepoService).to receive(:new).and_return(monorepo_service)
      allow(monorepo_service).to receive(:trigger_central_pipeline)
    end

    context 'when both monorepo feature and feature flag are enabled' do
      before do
        allow(merge_request).to receive_messages(project: project, id: 1)
        allow(project).to receive_messages(root_ancestor: project, flipper_id: "Project:1")
      end

      context 'when topic labels are added' do
        before do
          allow(merge_request).to receive(:labels).and_return([topic_label])
        end

        it 'triggers central pipeline' do
          expect(::MergeRequests::MonorepoService).to receive(:new).with(project, 'topic::test1')
          expect(monorepo_service).to receive(:trigger_central_pipeline).with(user)

          service.send(:handle_topic_label_changes, merge_request, [])
        end
      end

      context 'when topic labels are removed' do
        before do
          allow(merge_request).to receive(:labels).and_return([])
        end

        it 'triggers central pipeline' do
          expect(::MergeRequests::MonorepoService).to receive(:new).with(project, 'topic::test1')
          expect(monorepo_service).to receive(:trigger_central_pipeline).with(user)

          service.send(:handle_topic_label_changes, merge_request, [topic_label])
        end
      end

      context 'when topic labels are changed' do
        before do
          allow(merge_request).to receive(:labels).and_return([topic_label2])
        end

        it 'triggers central pipeline' do
          expect(::MergeRequests::MonorepoService).to receive(:new).with(project, 'topic::test2')
          expect(monorepo_service).to receive(:trigger_central_pipeline).with(user)

          service.send(:handle_topic_label_changes, merge_request, [topic_label])
        end
      end

      context 'when topic labels do not change' do
        before do
          allow(merge_request).to receive(:labels).and_return([topic_label])
        end

        it 'does not trigger central pipeline' do
          expect(::MergeRequests::MonorepoService).not_to receive(:new)

          service.send(:handle_topic_label_changes, merge_request, [topic_label])
        end
      end

      context 'when only non-topic labels change' do
        before do
          allow(merge_request).to receive(:labels).and_return([regular_label])
        end

        it 'does not trigger central pipeline' do
          expect(::MergeRequests::MonorepoService).not_to receive(:new)

          service.send(:handle_topic_label_changes, merge_request, [])
        end
      end

      context 'when no topic labels are present' do
        before do
          allow(merge_request).to receive(:labels).and_return([regular_label])
        end

        it 'does not trigger central pipeline' do
          expect(::MergeRequests::MonorepoService).not_to receive(:new)

          service.send(:handle_topic_label_changes, merge_request, [regular_label])
        end
      end

      context 'when pipeline triggering fails' do
        before do
          allow(merge_request).to receive_messages(labels: [topic_label], id: 1)
          allow(monorepo_service).to receive(:trigger_central_pipeline).and_raise(StandardError, 'Pipeline error')
        end

        it 'handles the error gracefully' do
          expect(::MergeRequests::MonorepoService).to receive(:new).with(project, 'topic::test1')
          expect(monorepo_service).to receive(:trigger_central_pipeline).with(user)

          expect { service.send(:handle_topic_label_changes, merge_request, []) }.not_to raise_error
        end
      end
    end
  end

  describe 'MR label update triggers handle_topic_label_changes' do
    let(:project) { create(:project, :repository) }
    let(:user) { create(:user) }
    let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
    let(:topic_label) { create(:label, project: project, title: 'topic::backend') }
    let(:bug_label) { create(:label, project: project, title: 'bug') }
    let(:service) { MergeRequests::UpdateService.new(project: project, current_user: user, params: params) }

    before do
      project.add_developer(user)
      monorepo_service = instance_double(::MergeRequests::MonorepoService)
      allow(::MergeRequests::MonorepoService).to receive_messages(
        monorepo_feature_available?: true,
        new: monorepo_service
      )
      allow(monorepo_service).to receive(:trigger_central_pipeline)
    end

    context 'when adding topic labels to MR' do
      let(:params) { { label_ids: [topic_label.id, bug_label.id] } }

      it 'calls handle_topic_label_changes when labels are updated' do
        allow(service).to receive(:handle_topic_label_changes).and_call_original
        result = service.execute(merge_request)
        expect(result).to be_valid
        expect(service).to have_received(:handle_topic_label_changes).with(merge_request, [])
        expect(merge_request.reload.labels).to include(topic_label, bug_label)
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(ff_monorepo_topic_ci_trigger: false)
        end

        it 'does not trigger central pipeline' do
          allow(service).to receive(:handle_topic_label_changes).and_call_original
          service.execute(merge_request)
          expect(service).not_to have_received(:handle_topic_label_changes)
        end
      end

      context 'when monorepo feature is not available' do
        before do
          allow(::MergeRequests::MonorepoService).to receive(:monorepo_feature_available?).and_return(false)
        end

        it 'does not trigger central pipeline' do
          allow(service).to receive(:handle_topic_label_changes).and_call_original
          service.execute(merge_request)
          expect(service).not_to have_received(:handle_topic_label_changes)
        end
      end
    end

    context 'when removing topic labels from MR' do
      let(:params) { { label_ids: [bug_label.id] } }

      before do
        merge_request.labels = [topic_label, bug_label]
        merge_request.save!
      end

      it 'calls handle_topic_label_changes when topic labels are removed' do
        allow(service).to receive(:handle_topic_label_changes).and_call_original
        result = service.execute(merge_request)
        expect(result).to be_valid
        expect(service).to have_received(:handle_topic_label_changes).with(merge_request, [topic_label, bug_label])
        expect(merge_request.reload.labels).to include(bug_label)
        expect(merge_request.labels).not_to include(topic_label)
      end
    end

    context 'when changing topic labels on MR' do
      let(:new_topic_label) { create(:label, project: project, title: 'topic::frontend') }
      let(:params) { { label_ids: [new_topic_label.id, bug_label.id] } }

      before do
        merge_request.labels = [topic_label, bug_label]
        merge_request.save!
      end

      it 'calls handle_topic_label_changes when topic labels are changed' do
        allow(service).to receive(:handle_topic_label_changes).and_call_original
        result = service.execute(merge_request)
        expect(result).to be_valid
        expect(service).to have_received(:handle_topic_label_changes).with(merge_request, [topic_label, bug_label])
        expect(merge_request.reload.labels).to include(new_topic_label, bug_label)
        expect(merge_request.labels).not_to include(topic_label)
      end
    end
  end
end
