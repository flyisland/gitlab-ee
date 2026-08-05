# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Rollouts::CreateService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:application) { create(:cd_application, organization: organization) }
  let_it_be(:version_set) { create(:cd_version_set, application: application) }
  let_it_be(:flow_definition) { create(:cd_application_flow_definition, application: application) }

  let(:params) do
    {
      version_set: version_set
    }
  end

  subject(:result) do
    described_class.new(parent: organization, current_user: current_user, params: params).execute
  end

  describe '#execute' do
    it 'creates the rollout' do
      expect { result }.to change { ::Cd::Rollout.count }.by(1)

      rollout = result.payload[:rollout]
      expect(result).to be_success
      expect(rollout).to be_persisted
      expect(rollout).to have_attributes(
        organization: organization,
        application: application,
        version_set: version_set,
        application_flow_definition: flow_definition
      )
    end

    context 'when the application has multiple flow definitions' do
      let_it_be(:newer_flow_definition) { create(:cd_application_flow_definition, application: application) }

      it 'assigns the latest application flow definition' do
        rollout = result.payload[:rollout]

        expect(rollout.application_flow_definition).to eq(newer_flow_definition)
      end
    end

    context 'when the application has no flow definition' do
      let_it_be(:application) { create(:cd_application, organization: organization) }
      let_it_be(:version_set) { create(:cd_version_set, application: application) }

      it 'creates the rollout without a flow definition' do
        rollout = result.payload[:rollout]

        expect(result).to be_success
        expect(rollout.application_flow_definition).to be_nil
      end
    end

    it 'enqueues the kickoff worker for the created rollout' do
      expect(::Cd::Rollouts::StartWorker).to receive(:perform_async).with(kind_of(Integer))

      result
    end

    context 'when the version set is missing' do
      let(:params) { super().merge(version_set: nil) }

      it 'does not create a rollout and returns an error' do
        expect { result }.not_to change { ::Cd::Rollout.count }

        expect(result).to be_error
      end
    end

    context 'when the version set belongs to another organization' do
      let_it_be(:other_organization) { create(:organization) }
      let_it_be(:other_application) { create(:cd_application, organization: other_organization) }
      let_it_be(:other_version_set) { create(:cd_version_set, application: other_application) }

      let(:params) { super().merge(version_set: other_version_set) }

      it 'does not create a rollout and returns an error' do
        expect { result }.not_to change { ::Cd::Rollout.count }

        expect(result).to be_error
        expect(result.message).to include(a_string_matching(/do not belong to the organization/i))
      end

      it 'does not enqueue the kickoff worker' do
        expect(::Cd::Rollouts::StartWorker).not_to receive(:perform_async)

        result
      end
    end
  end
end
