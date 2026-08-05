# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Rollouts::StartService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let(:rollout) { create(:cd_rollout, state: :pending) }

  let(:kas_client) { instance_double(Gitlab::Kas::Client) }
  let(:response) { Gitlab::Agent::AutoFlow::Rpc::StartWorkflowResponse.new(workflow_key: 'wk:1/abc') }

  subject(:result) { described_class.new(rollout).execute }

  before do
    allow(Gitlab::Kas::Client).to receive(:new).and_return(kas_client)
    allow(kas_client).to receive(:start_workflow).and_return(response)
  end

  describe '#execute' do
    it 'transitions the rollout to in_progress' do
      expect { result }.to change { rollout.reload.state }.from('pending').to('in_progress')
    end

    it 'starts the workflow with the rollout identity and namespace' do
      expect(kas_client).to receive(:start_workflow) do |identity_key:, workflow_definition:, namespace_id:, kwargs:|
        expect(identity_key).to eq("cd-rollout-#{rollout.id}")
        expect(namespace_id).to eq(rollout.organization_id)
        # KAS expects the deploy program unencoded (not base64).
        expect(workflow_definition).to eq("def main(w, *a, **k):\n    pass\n")
        expect(kwargs).to include('rollout' => rollout.id.to_s)
        response
      end

      result
    end

    context 'when the rollout has rollout environments' do
      let(:rollout) { create(:cd_rollout, state: :pending) }
      let!(:rollout_environment) { create(:cd_rollout_environment, rollout: rollout, position: 1) }

      it 'includes each ordered rollout environment in the workflow kwargs' do
        expect(kas_client).to receive(:start_workflow) do |kwargs:, **|
          expect(kwargs['environments']).to include(
            a_hash_including(
              'position' => rollout_environment.position.to_s,
              'environment_id' => rollout_environment.environment_id.to_s,
              'driver_binding_id' => rollout_environment.driver_binding_id.to_s
            )
          )
          response
        end

        result
      end
    end

    it 'calls KAS start_workflow' do
      expect(kas_client).to receive(:start_workflow).and_return(response)

      result
    end

    it 'persists the returned workflow_key as the rollout workflow_ref' do
      expect { result }.to change { rollout.reload.workflow_ref }.from(nil).to('wk:1/abc')
    end

    it 'returns a success response with the rollout' do
      expect(result).to be_success
      expect(result.payload[:rollout]).to eq(rollout)
    end

    context 'when the rollout is in a terminal state with a workflow_ref' do
      let(:rollout) { create(:cd_rollout, state: :completed, workflow_ref: 'wk:1/done') }

      it 'does not call KAS and returns success (idempotent no-op)' do
        expect(kas_client).not_to receive(:start_workflow)

        expect(result).to be_success
        expect(rollout.reload.workflow_ref).to eq('wk:1/done')
      end
    end

    context 'when the rollout is not pending and has no workflow_ref' do
      # Not reachable through the normal flow (a non-pending rollout always has a
      # workflow_ref), but guards the startable? check defensively.
      let(:rollout) do
        create(:cd_rollout, state: :in_progress, workflow_ref: 'wk:1/x').tap do |r|
          r.update_column(:workflow_ref, nil)
        end
      end

      it 'does not call KAS and returns an error' do
        expect(kas_client).not_to receive(:start_workflow)

        expect(result).to be_error
        expect(result.message).to include(a_string_matching(/cannot be started/i))
      end
    end

    context 'when the KAS call fails' do
      before do
        allow(kas_client).to receive(:start_workflow).and_raise(GRPC::Unavailable.new('kas down'))
      end

      it 'propagates the error so the worker can retry' do
        expect { result }.to raise_error(GRPC::Unavailable)
      end

      it 'rolls back the state transition so the rollout stays pending for retry' do
        expect { result }.to raise_error(GRPC::Unavailable)
          .and not_change { rollout.reload.state }.from('pending')
      end

      it 'does not persist a workflow_ref' do
        expect { result }.to raise_error(GRPC::Unavailable)
        expect(rollout.reload.workflow_ref).to be_nil
      end
    end

    context 'when retried after a previous KAS failure left the rollout pending' do
      it 'proceeds with the KAS call and transitions while persisting the workflow_ref' do
        expect(kas_client).to receive(:start_workflow).and_return(response)

        expect { result }
          .to change { rollout.reload.workflow_ref }.from(nil).to('wk:1/abc')
          .and change { rollout.reload.state }.from('pending').to('in_progress')

        expect(result).to be_success
      end
    end

    context 'when the rollout is already in progress with a workflow_ref' do
      let(:rollout) { create(:cd_rollout, state: :in_progress, workflow_ref: 'wk:1/existing') }

      it 'does not call KAS again and returns success' do
        expect(kas_client).not_to receive(:start_workflow)

        expect(result).to be_success
        expect(rollout.reload.workflow_ref).to eq('wk:1/existing')
      end
    end
  end
end
