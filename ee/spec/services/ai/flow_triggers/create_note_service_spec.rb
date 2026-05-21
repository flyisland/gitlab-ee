# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::FlowTriggers::CreateNoteService, feature_category: :duo_agent_platform do
  let_it_be_with_refind(:project) { create(:project, :repository) }
  let_it_be(:author) { create(:service_account, maintainer_of: project, name: 'Author Name') }
  let_it_be(:resource) { create(:issue, project: project) }
  let_it_be(:existing_note) { create(:note, project: project, noteable: resource) }
  let_it_be(:discussion) { existing_note.discussion }

  let(:params) { { input: 'test input', event: 'mention' } }

  subject(:service) do
    described_class.new(
      project: project,
      resource: resource,
      author: author,
      discussion: discussion
    )
  end

  describe '#execute' do
    let_it_be(:workflow_workload) { create(:duo_workflows_workload, project: project) }
    let_it_be(:workflow) { workflow_workload.workflow }

    let(:mock_response) { ServiceResponse.success(payload: workflow_workload.workload) }

    context 'when block yields successful response' do
      it 'creates initial note, yields with discussion_id, and updates note with success message' do
        expect(Notes::CreateService).to receive(:new).with(
          project,
          author,
          note: '🔄 Processing the request...',
          noteable: resource,
          in_reply_to_discussion_id: discussion.id
        ).and_call_original

        initial_note_count = Note.count

        response = service.execute(params) do |yielded_params|
          expect(yielded_params).to eq(params.merge(discussion_id: discussion.id))
          expect(yielded_params[:discussion_id]).to be_present

          [mock_response, workflow]
        end

        expect(response).to eq(mock_response)
        expect(Note.count).to eq(initial_note_count + 1)

        created_note = Note.last
        expect(created_note.note).to include('✅ Author Name has started. You can view progress')
        expect(created_note.note).to match(/automate.agent.sessions.#{workflow.id}/)
        expect(created_note.note).to include('target="_blank" rel="noopener noreferrer"')
      end

      context 'when the username contains HTML' do
        before do
          allow(author).to receive(:name).and_return('Hacker <a>Person</a>')
        end

        it 'safely renders the name' do
          service.execute(params) do
            [mock_response, workflow]
          end

          created_note = Note.last
          expect(created_note.note).to include('✅ Hacker &lt;a&gt;Person&lt;/a&gt; has started.')
        end
      end
    end

    context 'when block yields error response' do
      let(:error_response) { ServiceResponse.error(message: 'Something went wrong') }

      it 'creates initial note and updates with error message' do
        initial_note_count = Note.count

        response = service.execute(params) { [error_response, workflow] }

        expect(response).to eq(error_response)
        expect(Note.count).to eq(initial_note_count + 1)

        created_note = Note.last
        expect(created_note.note).to include('❌ Could not start processing due to this error: Something went wrong')
      end
    end

    context 'when note creation fails' do
      let(:unpersisted_note) { build(:note, project: project, noteable: resource) }
      let(:mock_logger) { Ai::Catalog::Logger.build }

      before do
        allow_next_instance_of(Notes::CreateService) do |instance|
          allow(instance).to receive(:execute).and_return(unpersisted_note)
        end

        allow(Ai::Catalog::Logger).to receive(:build).and_return(mock_logger)
        allow(mock_logger).to receive(:context).and_return(mock_logger)
        allow(mock_logger).to receive(:error)
      end

      it 'logs the failure' do
        service.execute(params) { [mock_response, workflow] }

        expect(mock_logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to create processing note',
            noteable_type: resource.class.name,
            noteable_id: resource.id
          )
        )
      end

      it 'does not attempt to update the unpersisted note' do
        expect(unpersisted_note).not_to receive(:update)

        service.execute(params) { [mock_response, workflow] }
      end
    end

    context 'when note update fails' do
      let(:persisted_note) { create(:note, project: project, noteable: resource, author: author) }
      let(:mock_logger) { Ai::Catalog::Logger.build }

      before do
        allow(persisted_note).to receive_messages(
          update: false,
          errors: instance_double(ActiveModel::Errors, full_messages: ['Note is too long'])
        )

        allow_next_instance_of(Notes::CreateService) do |instance|
          allow(instance).to receive(:execute).and_return(persisted_note)
        end

        allow(Ai::Catalog::Logger).to receive(:build).and_return(mock_logger)
        allow(mock_logger).to receive(:context).and_return(mock_logger)
        allow(mock_logger).to receive(:error)
      end

      it 'logs the failure with the error details' do
        service.execute(params) { [mock_response, workflow] }

        expect(mock_logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to update processing note',
            note_id: persisted_note.id,
            errors: 'Note is too long'
          )
        )
      end
    end

    context 'when no discussion is provided' do
      subject(:service) do
        described_class.new(
          project: project,
          resource: resource,
          author: author,
          discussion: nil
        )
      end

      it 'creates note without in_reply_to_discussion_id' do
        expect(Notes::CreateService).to receive(:new).with(
          project,
          author,
          note: '🔄 Processing the request...',
          noteable: resource,
          in_reply_to_discussion_id: nil
        ).and_call_original

        service.execute(params) { [mock_response, workflow] }
      end
    end

    context 'when resource is a merge request' do
      let_it_be(:merge_request) do
        create(:merge_request,
          source_project: project,
          target_project: project,
          source_branch: 'feature-branch',
          target_branch: 'main'
        )
      end

      let_it_be(:resource) { merge_request }

      it 'creates note on merge request' do
        expect(Notes::CreateService).to receive(:new).with(
          project,
          author,
          note: '🔄 Processing the request...',
          noteable: merge_request,
          in_reply_to_discussion_id: discussion.id
        ).and_call_original

        service.execute(params) { [mock_response, workflow] }
      end
    end
  end
end
