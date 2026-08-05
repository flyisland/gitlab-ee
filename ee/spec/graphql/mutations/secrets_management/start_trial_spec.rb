# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::SecretsManagement::StartTrial, feature_category: :secrets_management do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be_with_reload(:root_group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: root_group) }

  let(:client) { ::Gitlab::SubscriptionPortal::Client }

  subject(:mutation) { described_class.new(context: query_context, object: nil, field: nil) }

  before_all do
    root_group.add_owner(current_user)
    subgroup.add_owner(current_user)
  end

  before do
    stub_saas_features(gitlab_com_subscriptions: true)
  end

  describe '#resolve' do
    let(:success_response) do
      ::Gitlab::SubscriptionPortal::SecretsManagerStartTrialResponse.new(success: true)
    end

    def resolve(group_path: root_group.full_path)
      mutation.resolve(group_path: group_path)
    end

    context 'when CDot starts the trial successfully', :saas do
      before do
        allow(client).to receive(:start_secrets_manager_trial)
          .with(namespace_id: root_group.id).and_return(success_response)
        allow(::SecretsManagement::Entitlement).to receive(:for)
          .with(root_group, user: current_user)
          .and_return(::SecretsManagement::Entitlement.new(state: :trial))
      end

      it 'returns the post-trial entitlement with no errors', :aggregate_failures do
        result = resolve

        expect(result[:errors]).to be_empty
        expect(result[:entitlement]).to be_a(::Types::SecretsManagement::EntitlementType::Adapter)
        expect(result[:entitlement].state).to eq(:trial)
      end

      it 'tracks the secrets_manager_trial_started event' do
        expect { resolve }
          .to trigger_internal_events('secrets_manager_trial_started')
          .with(namespace: root_group, user: current_user, category: described_class.name)
      end
    end

    context 'when CDot rejects the request', :saas do
      where(:error_code, :expected_message) do
        [
          [:trial_already_active, 'A Secrets Manager trial is already active for this group.'],
          [:not_found, 'This group is not recognized by the subscription service.'],
          [:ineligible, 'This group is not eligible to start a Secrets Manager trial.']
        ]
      end

      with_them do
        before do
          allow(client).to receive(:start_secrets_manager_trial).and_return(
            ::Gitlab::SubscriptionPortal::SecretsManagerStartTrialResponse.new(
              success: false, error_code: error_code
            )
          )
        end

        it 'returns the mapped error and a nil entitlement', :aggregate_failures do
          result = resolve

          expect(result[:entitlement]).to be_nil
          expect(result[:errors]).to contain_exactly(expected_message)
        end
      end

      context 'when ineligible with a CDot-supplied message' do
        before do
          allow(client).to receive(:start_secrets_manager_trial).and_return(
            ::Gitlab::SubscriptionPortal::SecretsManagerStartTrialResponse.new(
              success: false, error_code: :ineligible, error_message: 'Namespace already used its trial'
            )
          )
        end

        it 'surfaces the CDot message' do
          expect(resolve[:errors]).to contain_exactly('Namespace already used its trial')
        end
      end
    end

    context 'when the subscription service is unreachable', :saas do
      before do
        allow(client).to receive(:start_secrets_manager_trial)
          .and_raise(::Gitlab::SubscriptionPortal::SecretsManagerStartTrialResponse::Error, 'boom')
      end

      it 'returns a generic unavailable error', :aggregate_failures do
        result = resolve

        expect(result[:entitlement]).to be_nil
        expect(result[:errors]).to contain_exactly(described_class::UNAVAILABLE_ERROR)
      end
    end

    context 'when the group is not a top-level group' do
      it 'raises an argument error and never calls CDot' do
        expect(client).not_to receive(:start_secrets_manager_trial)

        expect { resolve(group_path: subgroup.full_path) }
          .to raise_error(::Gitlab::Graphql::Errors::ArgumentError, /top-level groups/)
      end
    end

    context 'when the feature flag is disabled' do
      before do
        stub_feature_flags(secrets_manager_paid_experience: false)
      end

      it 'raises a resource not available error and never calls CDot' do
        expect(client).not_to receive(:start_secrets_manager_trial)

        expect { resolve }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'on a self-managed offline (air-gapped) install' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        allow(::License).to receive(:current).and_return(
          instance_double(License, online_cloud_license?: false, feature_available?: false, plan: nil)
        )
      end

      it 'rejects with the offline error and never calls CDot', :aggregate_failures do
        expect(client).not_to receive(:start_secrets_manager_trial)

        result = resolve

        expect(result[:entitlement]).to be_nil
        expect(result[:errors]).to contain_exactly(described_class::OFFLINE_ERROR)
      end
    end

    context 'on a self-managed install with no license' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        allow(::License).to receive(:current).and_return(nil)
      end

      it 'rejects as ineligible and never calls CDot', :aggregate_failures do
        expect(client).not_to receive(:start_secrets_manager_trial)

        result = resolve

        expect(result[:entitlement]).to be_nil
        expect(result[:errors]).to contain_exactly(described_class::ERROR_MESSAGES.fetch(:ineligible))
      end
    end
  end
end
