# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyFirewallPolicies::BypassSettings, feature_category: :dependency_firewall do
  let_it_be(:user) { create(:user) }
  let_it_be(:other_user) { create(:user) }
  let_it_be(:access_token) { create(:personal_access_token, user: user) }

  let(:bypass_settings_hash) do
    {
      users: [{ id: user.id }],
      access_tokens: [{ id: access_token.id }]
    }
  end

  subject(:bypass_settings) { described_class.new(bypass_settings_hash) }

  describe '#user_ids' do
    it 'returns the ids of users' do
      expect(bypass_settings.user_ids).to eq([user.id])
    end

    context 'when users is nil or missing' do
      let(:bypass_settings_hash) { {} }

      it 'returns empty array' do
        expect(bypass_settings.user_ids).to be_empty
      end
    end

    context 'with multiple users' do
      let(:bypass_settings_hash) do
        {
          users: [{ id: 100 }, { id: 200 }, { id: 300 }]
        }
      end

      it 'returns all user ids' do
        expect(bypass_settings.user_ids).to match_array([100, 200, 300])
      end
    end
  end

  describe '#access_token_ids' do
    it 'returns the ids of access tokens' do
      expect(bypass_settings.access_token_ids).to eq([access_token.id])
    end

    context 'when access_tokens is nil or missing' do
      let(:bypass_settings_hash) { {} }

      it 'returns empty array' do
        expect(bypass_settings.access_token_ids).to be_empty
      end
    end

    context 'with multiple access tokens' do
      let(:bypass_settings_hash) do
        {
          access_tokens: [{ id: 1 }, { id: 2 }, { id: 3 }]
        }
      end

      it 'returns all access token ids' do
        expect(bypass_settings.access_token_ids).to match_array([1, 2, 3])
      end
    end
  end

  describe '#user_bypassed?' do
    context 'when user is in bypass list' do
      it 'returns true' do
        expect(bypass_settings.user_bypassed?(user)).to be true
      end
    end

    context 'when user is not in bypass list' do
      it 'returns false' do
        expect(bypass_settings.user_bypassed?(other_user)).to be false
      end
    end

    context 'when user is nil' do
      it 'returns false' do
        expect(bypass_settings.user_bypassed?(nil)).to be false
      end
    end

    context 'when bypass list is empty' do
      let(:bypass_settings_hash) { { users: [] } }

      it 'returns false' do
        expect(bypass_settings.user_bypassed?(user)).to be false
      end
    end

    context 'when users key is missing' do
      let(:bypass_settings_hash) { {} }

      it 'returns false' do
        expect(bypass_settings.user_bypassed?(user)).to be false
      end
    end
  end

  describe '#access_token_bypassed?' do
    context 'when user has an active access token in bypass list' do
      it 'returns truthy value' do
        expect(bypass_settings.access_token_bypassed?(user)).to be_truthy
      end
    end

    context 'when user is not in bypass list' do
      it 'returns falsy value' do
        expect(bypass_settings.access_token_bypassed?(other_user)).to be_falsy
      end
    end

    context 'when user is nil' do
      it 'returns false' do
        expect(bypass_settings.access_token_bypassed?(nil)).to be false
      end
    end

    context 'when access token list is empty' do
      let(:bypass_settings_hash) { { access_tokens: [] } }

      it 'returns false' do
        expect(bypass_settings.access_token_bypassed?(user)).to be false
      end
    end

    context 'when access_tokens key is missing' do
      let(:bypass_settings_hash) { {} }

      it 'returns false' do
        expect(bypass_settings.access_token_bypassed?(user)).to be false
      end
    end

    context 'when user has inactive access token' do
      let_it_be(:inactive_token) { create(:personal_access_token, :revoked, user: user) }
      let(:bypass_settings_hash) do
        {
          access_tokens: [{ id: inactive_token.id }]
        }
      end

      it 'returns falsy value' do
        expect(bypass_settings.access_token_bypassed?(user)).to be_falsy
      end
    end

    context 'when user has multiple tokens and one is in bypass list' do
      let_it_be(:another_token) { create(:personal_access_token, user: user) }
      let(:bypass_settings_hash) do
        {
          access_tokens: [{ id: access_token.id }]
        }
      end

      it 'returns truthy value' do
        expect(bypass_settings.access_token_bypassed?(user)).to be_truthy
      end
    end
  end
end
