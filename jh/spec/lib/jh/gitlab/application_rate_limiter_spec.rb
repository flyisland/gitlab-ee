# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::ApplicationRateLimiter, feature_category: :system_access do
  describe 'JH rate limits' do
    subject(:jh_rate_limits) do
      {
        email_exists: rate_limit_for(:email_exists),
        invitation_email: rate_limit_for(:invitation_email)
      }
    end

    let(:supported_rate_limits) { described_class::LabkitAdapter::SupportedRateLimits }

    it 'includes JH rate limit keys' do
      expect(jh_rate_limits.keys).to contain_exactly(:email_exists, :invitation_email)
    end

    it 'configures email_exists' do
      expect(jh_rate_limits[:email_exists]).to eq({ threshold: 20, interval: 1.minute })
    end

    it 'configures invitation_email' do
      expect(jh_rate_limits[:invitation_email]).to eq({ threshold: 50, interval: 1.day })
    end

    def rate_limit_for(key)
      {
        threshold: supported_rate_limits.limit_for(key),
        interval: supported_rate_limits.period_for(key)
      }
    end
  end
end
