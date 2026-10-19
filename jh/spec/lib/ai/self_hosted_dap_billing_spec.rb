# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::SelfHostedDapBilling, feature_category: :duo_agent_platform do
  describe '.self_hosted_dap_billing_enabled? with jh_disable_billing feature flag' do
    subject { described_class.self_hosted_dap_billing_enabled? }

    context 'when jh_disable_billing is enabled' do
      before do
        stub_feature_flags(jh_disable_billing: true)
      end

      context 'when all upstream conditions would be met' do
        let(:license) { instance_double(License, online_cloud_license?: true) }
        let_it_be(:feature_setting) do
          create(:ai_feature_setting, :duo_agent_platform_agentic_chat, provider: :vendored)
        end

        before do
          allow(License).to receive(:current).and_return(license)
        end

        it 'returns false and disables billing' do
          expect(subject).to be_falsey

          expect(described_class.should_bill?(feature_setting)).to be_falsey
        end

        it 'returns false and disables billing' do
          expect(described_class.should_bill?(feature_setting)).to be_falsey
        end
      end

      context 'when license is nil' do
        before do
          allow(License).to receive(:current).and_return(nil)
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end

    context 'when jh_disable_billing is disabled' do
      before do
        stub_feature_flags(jh_disable_billing: false)
      end

      context 'when all conditions are met' do
        let(:license) { instance_double(License, online_cloud_license?: true) }

        before do
          allow(License).to receive(:current).and_return(license)
        end

        it 'returns true and uses upstream logic' do
          expect(subject).to be_truthy
        end
      end

      context 'when using offline cloud license' do
        let(:license) { instance_double(License, online_cloud_license?: false) }

        before do
          allow(License).to receive(:current).and_return(license)
        end

        it 'returns false' do
          expect(subject).to be_falsey
        end
      end
    end
  end
end
