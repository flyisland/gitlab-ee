# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::ApplicationRateLimiter::LabkitAdapter::SupportedRateLimits,
  feature_category: :system_access do
  describe 'JH registry entries' do
    let(:jh_keys) { %i[email_exists invitation_email].to_set }

    it 'registers every JH rate limit key' do
      registered = described_class.all.keys.to_set

      expect(jh_keys - registered).to be_empty
    end

    it 'registers email_exists with IP-scoped labkit metadata' do
      expect(rule_attributes(:email_exists)).to eq(
        name: 'limit_email_existence_checks_by_ip',
        characteristics: %i[ip],
        limit: 20,
        period: 1.minute,
        action: :limit
      )
    end

    it 'registers invitation_email with user-scoped labkit metadata' do
      expect(rule_attributes(:invitation_email)).to eq(
        name: 'limit_invitation_emails_by_user',
        characteristics: %i[user],
        limit: 50,
        period: 1.day,
        action: :limit
      )
    end

    def rule_attributes(key)
      rule = described_class.rule_for(key)

      {
        name: rule.name,
        characteristics: rule.characteristics,
        limit: described_class.limit_for(key),
        period: described_class.period_for(key),
        action: rule.action
      }
    end
  end
end
