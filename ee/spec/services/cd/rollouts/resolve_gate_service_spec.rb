# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Rollouts::ResolveGateService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:application) { create(:cd_application, organization: organization) }
  let_it_be(:version_set) { create(:cd_version_set, application: application) }
  let_it_be(:user) { create(:user) }

  let(:rollout) do
    create(:cd_rollout, version_set: version_set, application: application, state: :paused, workflow_ref: 'wf-1')
  end

  let(:status) { :approved }
  let(:reason) { nil }

  subject(:service) do
    described_class.new(rollout, current_user: user, status: status, reason: reason)
  end

  describe '#execute' do
    context 'when the rollout is paused' do
      context 'when approving' do
        let(:status) { :approved }

        it 'creates an approve transition journal entry' do
          response = nil

          expect { response = service.execute }.to change { ::Cd::RolloutTransition.count }.by(1)

          expect(response).to be_success
          expect(response.payload[:rollout_transition]).to have_attributes(
            rollout: rollout,
            organization: organization,
            event: 'approve',
            from_state: 'paused',
            to_state: 'paused',
            principal: "user:#{user.id}",
            reason: nil
          )
        end

        it 'does not change the rollout state' do
          expect { service.execute }.not_to change { rollout.reload.state }
        end
      end

      context 'when rejecting' do
        let(:status) { :rejected }

        it 'creates a reject transition journal entry' do
          response = nil

          expect { response = service.execute }.to change { ::Cd::RolloutTransition.count }.by(1)

          expect(response.payload[:rollout_transition]).to have_attributes(
            event: 'reject',
            from_state: 'paused',
            to_state: 'paused',
            principal: "user:#{user.id}"
          )
        end
      end

      context 'with a reason' do
        let(:reason) { 'Looks good to ship' }

        it 'records the reason on the transition' do
          response = service.execute

          expect(response.payload[:rollout_transition].reason).to eq('Looks good to ship')
        end
      end

      context 'when the transition is invalid' do
        let(:reason) { 'a' * 2001 }

        it 'returns an error response and does not create a transition' do
          response = nil

          expect { response = service.execute }.not_to change { ::Cd::RolloutTransition.count }

          expect(response).to be_error
          expect(response.message).to include(a_string_matching(/Reason is too long/))
        end
      end
    end

    context 'when the rollout is not paused' do
      let(:rollout) do
        create(:cd_rollout, version_set: version_set, application: application, state: :in_progress,
          workflow_ref: 'wf-1')
      end

      it 'returns an error response and does not create a transition' do
        response = nil

        expect { response = service.execute }.not_to change { ::Cd::RolloutTransition.count }

        expect(response).to be_error
        expect(response.message).to include(a_string_matching(/not awaiting approval/i))
      end
    end

    context 'when the status is unknown' do
      let(:status) { :unknown }

      it 'returns an error response and does not create a transition' do
        response = nil

        expect { response = service.execute }.not_to change { ::Cd::RolloutTransition.count }

        expect(response).to be_error
        expect(response.message).to include(a_string_matching(/unknown gate status/i))
      end
    end
  end
end
