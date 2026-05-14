# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Users::ParticipableService, feature_category: :duo_agent_platform do
  let_it_be(:current_user) { create(:user) }

  let(:service_class) do
    Class.new do
      include EE::Users::ParticipableService

      attr_reader :current_user

      def initialize(current_user)
        @current_user = current_user
      end
    end
  end

  let(:service) { service_class.new(current_user) }

  describe '#user_disabled_fields' do
    context 'when user is a regular user' do
      let_it_be(:user) { create(:user) }

      it 'returns disabled: false and empty disabled_reason' do
        result = service.user_disabled_fields(user)

        expect(result).to eq({ disabled: false, disabled_reason: '' })
      end
    end

    context 'when user is a service account without composite identity enforced' do
      let_it_be(:user) { create(:user, :service_account, composite_identity_enforced: false) }

      it 'returns disabled: false and empty disabled_reason' do
        result = service.user_disabled_fields(user)

        expect(result).to eq({ disabled: false, disabled_reason: '' })
      end
    end

    context 'when user is a service account with composite identity enforced' do
      let_it_be(:user) { create(:user, :service_account, composite_identity_enforced: true) }

      context 'when quota check succeeds' do
        before do
          allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
            allow(quota_service).to receive(:execute).and_return(ServiceResponse.success)
          end
        end

        it 'returns disabled: false and empty disabled_reason' do
          result = service.user_disabled_fields(user)

          expect(result).to eq({ disabled: false, disabled_reason: '' })
        end
      end

      context 'when quota check fails with usage_quota_exceeded' do
        before do
          allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
            allow(quota_service).to receive(:execute).and_return(
              ServiceResponse.error(message: 'Usage quota exceeded', reason: :usage_quota_exceeded)
            )
          end
        end

        it 'returns disabled: true with no credits message' do
          result = service.user_disabled_fields(user)

          expect(result).to eq({ disabled: true, disabled_reason: "Unavailable - no credits" })
        end
      end

      context 'when quota check fails with user_missing' do
        before do
          allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
            allow(quota_service).to receive(:execute).and_return(
              ServiceResponse.error(message: 'User is required', reason: :user_missing)
            )
          end
        end

        it 'returns disabled: true with invalid user message' do
          result = service.user_disabled_fields(user)

          expect(result).to eq({ disabled: true, disabled_reason: "Unavailable - invalid user" })
        end
      end

      context 'when quota check fails with namespace_missing' do
        before do
          allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
            allow(quota_service).to receive(:execute).and_return(
              ServiceResponse.error(message: 'Namespace is required', reason: :namespace_missing)
            )
          end
        end

        it 'returns disabled: true with missing default namespace message' do
          result = service.user_disabled_fields(user)

          expect(result).to eq({ disabled: true, disabled_reason: "Unavailable - missing default namespace" })
        end
      end

      context 'when quota check fails with an unknown reason' do
        before do
          allow_next_instance_of(::Ai::UsageQuotaService) do |quota_service|
            allow(quota_service).to receive(:execute).and_return(
              ServiceResponse.error(message: 'Something went wrong', reason: :some_unknown_reason)
            )
          end
        end

        it 'returns disabled: true with unknown reason message' do
          result = service.user_disabled_fields(user)

          expect(result).to eq({ disabled: true, disabled_reason: "Unavailable - unknown reason" })
        end
      end
    end
  end
end
