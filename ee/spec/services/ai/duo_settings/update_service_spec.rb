# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoSettings::UpdateService, feature_category: :"self-hosted_models" do
  let_it_be(:user) { create(:admin) }
  let_it_be(:duo_settings) { create(:ai_settings) }

  let(:params) { { ai_gateway_url: "http://new-ai-gateway-url", duo_core_features_enabled: true, ai_gateway_timeout_seconds: 100 } }

  subject(:service_result) { described_class.new(params, current_user: user).execute }

  describe '#execute', :enable_admin_mode do
    context 'when user is not an admin' do
      let_it_be(:user) { create(:user) }

      it 'returns an error without updating settings' do
        expect { service_result }.not_to change { duo_settings.reload }

        expect(service_result).to be_error
        expect(service_result.message).to eq("Unable to update AI settings")
      end
    end

    context 'when update succeeds' do
      it 'returns a success response' do
        expect { service_result }.to change { duo_settings.reload.ai_gateway_url }.to("http://new-ai-gateway-url")
          .and change { duo_settings.reload.duo_core_features_enabled }.to(true)
          .and change { duo_settings.reload.ai_gateway_timeout_seconds }.to(100)

        expect(service_result).to be_success
        expect(service_result.payload).to eq(duo_settings)
      end

      it 'calls the changes auditor' do
        auditor = instance_double(Ai::DuoSettings::ChangesAuditor)
        allow(Ai::DuoSettings::ChangesAuditor).to receive(:new).and_return(auditor)
        expect(auditor).to receive(:execute)

        service_result
      end
    end

    context 'when update fails due to a validation error' do
      let(:params) { { ai_gateway_url: 'invalid-url', duo_core_features_enabled: true } }

      it 'returns an error response with validation messages' do
        expect { service_result }.not_to change { duo_settings.reload }

        expect(service_result).to be_error
        expect(service_result.errors).to match_array(
          ["Ai gateway url Only allowed schemes are http, https"]
        )
      end

      it 'does not call the changes auditor' do
        expect(Ai::DuoSettings::ChangesAuditor).not_to receive(:new)

        service_result
      end
    end

    context 'when update fails due to an unexpected error' do
      let(:error) { StandardError.new("something unexpected") }

      before do
        allow(::Ai::Setting).to receive(:instance).and_raise(error)
      end

      it 'returns a generic error response without leaking details' do
        expect(service_result).to be_error
        expect(service_result.message).to eq("Unable to update AI settings")
      end

      it 'tracks the exception in Sentry' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception).with(error)

        service_result
      end
    end
  end
end
