# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Ai::DuoWorkflows::CreateCheckpointService, feature_category: :duo_agent_platform do
  describe '#execute' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, group: group) }
    let(:workflow) { create(:duo_workflows_workflow, **container_params) }
    let(:container_params) { { project: project } }
    let(:thread_ts) { Gitlab::Utils.uuid_v7 }
    let(:parent_ts) { Gitlab::Utils.uuid_v7 }
    let(:metadata) { { another_key: 'another value' } }
    let(:channel_blobs) { nil }
    let(:params) do
      { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: { key: 'value' }, metadata: metadata,
        channel_blobs: channel_blobs }
    end

    before do
      allow(GraphqlTriggers).to receive(:workflow_events_updated)
    end

    subject(:execute) do
      described_class
        .new(workflow: workflow, params: params)
        .execute
    end

    it 'creates a new checkpoint' do
      expect { execute }.to change { workflow.reload.checkpoints.count }.by(1)
      expect(execute[:checkpoint]).to be_a(Ai::DuoWorkflows::Checkpoint)
      expect(execute[:checkpoint].workflow).to eq(workflow)
      expect(execute[:checkpoint].project).to eq(project)
      expect(execute[:checkpoint].thread_ts).to eq(thread_ts)
      expect(execute[:checkpoint].parent_ts).to eq(parent_ts)
      expect(execute[:checkpoint].checkpoint).to eq({ 'key' => 'value' })
      expect(execute[:checkpoint].metadata).to eq({ 'another_key' => 'another value' })
      expect(GraphqlTriggers).to have_received(:workflow_events_updated).with(execute[:checkpoint])
    end

    context 'with messaging progress delivery' do
      context 'when the workflow is not messaging-triggered' do
        it 'does not enqueue a progress delivery' do
          expect(Ai::Messaging::ProgressDeliveryWorker).not_to receive(:perform_in)

          execute
        end
      end

      context 'when a messaging workflow whose adapter streams live progress' do
        let(:workflow) do
          create(:duo_workflows_workflow, project: project, messaging_callback_context: { 'adapter' => 'slack' })
        end

        before do
          # No adapter opts in yet (the Slack surface lands in a follow-up), so we
          # stub the capability to exercise the enqueue gate's positive path.
          allow(Ai::Messaging::Adapters::Slack).to receive(:supports_live_progress?).and_return(true)
        end

        it 'enqueues a debounced progress delivery' do
          expect(Ai::Messaging::ProgressDeliveryWorker)
            .to receive(:perform_in)
            .with(Ai::Messaging::ProgressDeliveryWorker::DEBOUNCE_INTERVAL, workflow.id)

          execute
        end
      end

      context 'when a messaging workflow whose adapter does not stream live progress' do
        let(:workflow) do
          create(:duo_workflows_workflow, project: project, messaging_callback_context: { 'adapter' => 'unknown' })
        end

        it 'does not enqueue a progress delivery' do
          expect(Ai::Messaging::ProgressDeliveryWorker).not_to receive(:perform_in)

          execute
        end
      end
    end

    context 'when namespace-level workflow' do
      let(:container_params) { { namespace: group } }

      it 'creates a new checkpoint' do
        expect { execute }.to change { workflow.reload.checkpoints.count }.by(1)
        expect(execute[:checkpoint]).to be_a(Ai::DuoWorkflows::Checkpoint)
        expect(execute[:checkpoint].workflow).to eq(workflow)
        expect(execute[:checkpoint].namespace).to eq(group)
      end
    end

    context 'when there is invalid params' do
      let(:thread_ts) { '' }

      it 'returns an error' do
        expect(execute[:status]).to eq(:error)
        expect(execute[:message].to_s).to include("can't be blank")
        expect(GraphqlTriggers).not_to have_received(:workflow_events_updated).with(execute[:checkpoint])
      end
    end

    describe 'setting goal when first checkpoint' do
      let(:goal) { 'Hello, World!' }
      let(:checkpoint) do
        {
          "channel_values" => {
            "__start__" => {
              "goal" => goal
            }
          }
        }
      end

      let(:params) { { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: checkpoint, metadata: metadata } }

      context 'when first checkpoint' do
        it 'updates the workflows goal to be new goal' do
          expect { execute }.to change { workflow.reload.goal }.to('Hello, World!')
        end

        context 'when goal is nil' do
          let(:goal) { nil }

          it 'does not update the workflows goal' do
            expect { execute }.to not_change { workflow.reload.goal }
          end
        end

        context 'when goal is blank' do
          let(:goal) { '' }

          it 'does not update the workflows goal' do
            expect { execute }.to not_change { workflow.reload.goal }
          end
        end

        context 'when goal field is not present' do
          let(:checkpoint) do
            {
              "channel_values" => {
                "__start__" => {
                  "another_goal" => goal
                }
              }
            }
          end

          it 'does not update the workflows goal' do
            expect { execute }.to not_change { workflow.reload.goal }
          end
        end

        context 'when __start__ is absent' do
          let(:checkpoint) do
            {
              "channel_values" => {}
            }
          end

          # `dig` returns nil here; a non-`dig` lookup such as `start['goal']`
          # would raise NoMethodError and 500 the checkpoint-create request.
          it 'does not raise and does not update the workflows goal', :aggregate_failures do
            original_goal = workflow.goal

            expect { execute }.not_to raise_error
            expect(workflow.reload.goal).to eq(original_goal)
          end
        end

        context 'when the goal is only at __start__.context.goal (pre-created CLI workflow)' do
          let(:checkpoint) do
            {
              "channel_values" => {
                "__start__" => {
                  "status" => "Not Started",
                  "context" => { "goal" => "What was the last commit?" }
                }
              }
            }
          end

          it 'backfills the goal from the nested context goal' do
            expect { execute }.to change { workflow.reload.goal }.to('What was the last commit?')
          end
        end

        context 'when __start__.goal is blank and the goal is at __start__.context.goal' do
          let(:checkpoint) do
            {
              "channel_values" => {
                "__start__" => {
                  "goal" => "",
                  "context" => { "goal" => "What was the last commit?" }
                }
              }
            }
          end

          it 'backfills the goal from the nested context goal' do
            expect { execute }.to change { workflow.reload.goal }.to('What was the last commit?')
          end
        end

        context 'when goal exceeds the maximum length' do
          let(:goal) { 'a' * (Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH + 1) }

          it 'truncates the goal to the maximum length without raising', :aggregate_failures do
            expect { execute }.not_to raise_error
            expect(workflow.reload.goal.length).to eq(Ai::DuoWorkflows::Workflow::GOAL_MAX_LENGTH)
          end
        end
      end

      context 'when not first checkpoint' do
        let!(:existing_checkpoint) do
          create(:duo_workflows_checkpoint, workflow: workflow)
        end

        it 'does not update the workflows goal' do
          expect { execute }.to not_change { workflow.reload.goal }
        end
      end

      it 'detects the first checkpoint without a MIN(id) aggregate scan', :aggregate_failures do
        recorder = ActiveRecord::QueryRecorder.new { execute }

        expect(recorder.log).not_to include(a_string_matching(/MIN\(/i))
        expect(recorder.log).to include(a_string_matching(/SELECT 1 .*p_duo_workflows_checkpoints.*LIMIT 1/im))
      end
    end

    describe 'persisting model metadata' do
      context 'when model_metadata_json is present' do
        let(:model_metadata) { '{"model":"claude-3"}' }
        let(:params) do
          { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: { key: 'value' },
            metadata: metadata, model_metadata_json: model_metadata }
        end

        it 'persists model_metadata_json on the workflow' do
          execute
          expect(workflow.reload.model_metadata_json).to eq(model_metadata)
        end

        it 'does not pass model_metadata_json to the checkpoint' do
          execute
          expect(execute[:checkpoint].reload.attributes).not_to have_key('model_metadata_json')
        end
      end

      context 'when model_metadata_json is blank' do
        let(:params) do
          { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: { key: 'value' },
            metadata: metadata, model_metadata_json: '' }
        end

        it 'does not update model_metadata_json on the workflow' do
          expect { execute }.to not_change { workflow.reload.model_metadata_json }
        end
      end

      context 'when model_metadata_json is not provided' do
        it 'does not update model_metadata_json on the workflow' do
          expect { execute }.to not_change { workflow.reload.model_metadata_json }
        end
      end
    end

    context 'with channel_blobs and incremental checkpoints enabled on the workflow' do
      let(:workflow) { create(:duo_workflows_workflow, incremental_checkpoints_enabled: true, **container_params) }
      let(:channel_blobs) do
        [
          { channel: 'messages', version: '1', write_type: 'msgpack',
            step_action: 'conversation', data: Base64.strict_encode64('blob1') },
          { channel: 'search', version: '1', write_type: 'msgpack',
            step_action: 'compaction', data: Base64.strict_encode64('blob2') }
        ]
      end

      let(:params) do
        { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: { key: 'value' }, metadata: metadata,
          channel_blobs: channel_blobs, current_thread: 2 }
      end

      it 'creates the checkpoint and blobs atomically' do
        expect { execute }.to change { workflow.reload.checkpoints.count }.by(1)
          .and change { workflow.reload.checkpoint_blobs.count }.by(2)

        checkpoint = workflow.checkpoints.order(:id).last
        expect(checkpoint.current_thread).to eq(2)

        blobs = workflow.checkpoint_blobs.order(:id)
        expect(blobs.map(&:channel)).to eq(%w[messages search])
        expect(blobs.map(&:thread_ts).uniq).to eq([thread_ts])
        expect(blobs.map(&:step_action)).to eq(%w[conversation compaction])
        expect(blobs.map(&:current_thread).uniq).to eq([2])
        # `data` is base64-decoded to raw bytes before it hits the bytea column.
        expect(blobs.map(&:data)).to eq(%w[blob1 blob2])
      end

      it 'returns success with the checkpoint' do
        result = execute
        expect(result[:status]).to eq(:success)
        expect(result[:checkpoint]).to be_a(Ai::DuoWorkflows::Checkpoint)
      end

      context 'when the workflow is also updated in the same request' do
        let(:params) do
          { thread_ts: thread_ts, parent_ts: parent_ts, checkpoint: { key: 'value' }, metadata: metadata,
            channel_blobs: channel_blobs, current_thread: 2, model_metadata_json: '{"model":"claude-3"}' }
        end

        # Regression: blobs were built on the `@workflow.checkpoint_blobs`
        # association and persisted with `bulk_insert!`, which leaves them
        # unpersisted in memory. The subsequent `@workflow.update!` (here from
        # model metadata) autosaved the association and inserted every blob a
        # second time.
        it 'writes each blob exactly once' do
          expect { execute }.to change { workflow.reload.checkpoint_blobs.count }.by(channel_blobs.size)

          written = workflow.checkpoint_blobs.pluck(:channel, :version)
          expect(written).to match_array(written.uniq)
        end
      end

      it 'anchors blob workflow_created_at to the workflow created_at (partition key), keeping created_at honest' do
        workflow.update!(created_at: 3.days.ago)

        execute

        blobs = workflow.checkpoint_blobs
        # Partition key mirrors the workflow's created_at (compared at DB precision).
        expect(blobs.map(&:workflow_created_at).uniq).to eq([workflow.reload.created_at])
        # created_at is the real write time, not the workflow's (3-days-ago) created_at.
        expect(blobs.map(&:created_at)).to all(be_within(1.minute).of(Time.current))
      end

      it 'skips duplicate blobs when the same delta is re-sent' do
        # A redundant re-send repeats the same thread_ts, so blobs collide on the
        # unique index and are skipped; only the checkpoint row (not deduped) doubles.
        described_class.new(workflow: workflow, params: params).execute
        expect(workflow.reload.checkpoint_blobs.count).to eq(2)

        expect { described_class.new(workflow: workflow, params: params).execute }
          .to not_change { workflow.reload.checkpoint_blobs.count }
      end

      context 'when a re-send carries a compaction for an already-stored version' do
        let(:resend_blobs) do
          [
            # Same (channel, version) as the first send but step_action=compaction:
            # a force_rewrite re-emits the full value, and it must NOT be deduped.
            { channel: 'messages', version: '1', write_type: 'msgpack',
              step_action: 'compaction', data: Base64.strict_encode64('blob1-full') }
          ]
        end

        it 'stores it alongside the conversation delta' do
          execute

          resend = params.merge(channel_blobs: resend_blobs)
          expect { described_class.new(workflow: workflow, params: resend).execute }
            .to change { workflow.reload.checkpoint_blobs.count }.by(1)

          messages = workflow.checkpoint_blobs.where(channel: 'messages', version: '1')
          expect(messages.map(&:step_action)).to match_array(%w[conversation compaction])
        end
      end

      context 'when checkpoint save fails' do
        let(:thread_ts) { '' }

        it 'rolls back blobs and returns error', :aggregate_failures do
          result = nil
          expect { result = execute }.not_to change { Ai::DuoWorkflows::CheckpointBlob.count }
          expect(result[:status]).to eq(:error)
        end
      end
    end

    context 'with channel_blobs and incremental checkpoints disabled on the workflow' do
      let(:workflow) { create(:duo_workflows_workflow, incremental_checkpoints_enabled: false, **container_params) }
      let(:channel_blobs) do
        [{ channel: 'messages', version: '1', write_type: 'msgpack',
           step_action: 'conversation', data: Base64.strict_encode64('blob') }]
      end

      it 'ignores channel_blobs and creates the checkpoint only' do
        expect { execute }.to change { workflow.reload.checkpoints.count }.by(1)
          .and not_change { Ai::DuoWorkflows::CheckpointBlob.count }
      end
    end
  end
end
