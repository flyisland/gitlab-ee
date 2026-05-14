# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Agents::CheckAgentStatusService, feature_category: :duo_agent_platform do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:regular_user) { create(:user) }
  let_it_be(:service_account) { create(:user, :service_account) }
  let_it_be(:agent_user) { create(:user, :service_account, composite_identity_enforced: true) }

  subject(:service) { described_class.new(current_user) }

  describe Ai::Agents::CheckAgentStatusService::AgentStatus do
    describe '.enabled' do
      it 'returns an enabled status' do
        status = described_class.enabled

        expect(status).to be_enabled
        expect(status).not_to be_disabled
        expect(status.disabled_reason).to eq("")
      end
    end

    describe '.disabled' do
      it 'returns a disabled status with a reason' do
        status = described_class.disabled("some reason")

        expect(status).to be_disabled
        expect(status).not_to be_enabled
        expect(status.disabled_reason).to eq("some reason")
      end
    end
  end

  describe '#execute' do
    subject(:result) { service.execute(user) }

    context 'when user is not an agent (regular user)' do
      let(:user) { regular_user }

      it 'returns enabled status without checking usage quota' do
        expect(::Ai::UsageQuotaService).not_to receive(:new)

        expect(result).to be_enabled
      end
    end

    context 'when user is a service account without composite identity enforced' do
      let(:user) { service_account }

      it 'returns enabled status without checking usage quota' do
        expect(::Ai::UsageQuotaService).not_to receive(:new)

        expect(result).to be_enabled
      end
    end

    context 'when user is an agent (service account with composite identity enforced)' do
      let(:user) { agent_user }

      context 'when usage quota check succeeds' do
        before do
          allow(::Ai::UsageQuotaService)
            .to receive(:new)
            .with(ai_feature: :duo_agent_platform, user: current_user)
            .and_return(instance_double(::Ai::UsageQuotaService, execute: ServiceResponse.success))
        end

        it 'returns enabled status' do
          expect(result).to be_enabled
        end
      end

      context 'when usage quota check fails with :user_missing' do
        before do
          allow(::Ai::UsageQuotaService)
            .to receive(:new)
            .with(ai_feature: :duo_agent_platform, user: current_user)
            .and_return(instance_double(
              ::Ai::UsageQuotaService,
              execute: ServiceResponse.error(message: "User is required", reason: :user_missing)
            ))
        end

        it 'returns disabled status with invalid user reason' do
          expect(result).to be_disabled
          expect(result.disabled_reason).to eq(s_("CheckAgentStatusService|Unavailable - invalid user"))
        end
      end

      context 'when usage quota check fails with :namespace_missing' do
        before do
          allow(::Ai::UsageQuotaService)
            .to receive(:new)
            .with(ai_feature: :duo_agent_platform, user: current_user)
            .and_return(instance_double(
              ::Ai::UsageQuotaService,
              execute: ServiceResponse.error(message: "Namespace is required", reason: :namespace_missing)
            ))
        end

        it 'returns disabled status with missing namespace reason' do
          expect(result).to be_disabled
          expect(result.disabled_reason).to eq(s_("CheckAgentStatusService|Unavailable - missing default namespace"))
        end
      end

      context 'when usage quota check fails with :usage_quota_exceeded' do
        before do
          allow(::Ai::UsageQuotaService)
            .to receive(:new)
            .with(ai_feature: :duo_agent_platform, user: current_user)
            .and_return(instance_double(
              ::Ai::UsageQuotaService,
              execute: ServiceResponse.error(message: "Usage quota exceeded", reason: :usage_quota_exceeded)
            ))
        end

        it 'returns disabled status with no credits reason' do
          expect(result).to be_disabled
          expect(result.disabled_reason).to eq(s_("CheckAgentStatusService|Unavailable - no credits"))
        end
      end

      context 'when usage quota check fails with an unknown reason' do
        before do
          allow(::Ai::UsageQuotaService)
            .to receive(:new)
            .with(ai_feature: :duo_agent_platform, user: current_user)
            .and_return(instance_double(
              ::Ai::UsageQuotaService,
              execute: ServiceResponse.error(message: "Something went wrong", reason: :some_unknown_reason)
            ))
        end

        it 'returns disabled status with unknown reason' do
          expect(result).to be_disabled
          expect(result.disabled_reason).to eq(s_("CheckAgentStatusService|Unavailable - unknown reason"))
        end
      end
    end
  end
end
