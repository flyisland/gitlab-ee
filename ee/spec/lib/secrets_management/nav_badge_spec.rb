# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::NavBadge, feature_category: :secrets_management do
  describe '.visible?' do
    let_it_be(:root_namespace) { create(:group) }
    let(:user) { instance_double(User, dismissed_callout?: false) }

    subject(:visible) { described_class.visible?(user: user, root_namespace: root_namespace) }

    context 'when all conditions are met' do
      it { is_expected.to be(true) }
    end

    context 'when there is no user' do
      let(:user) { nil }

      it { is_expected.to be(false) }
    end

    context 'when the secrets_manager_paid_experience flag is disabled' do
      before do
        stub_feature_flags(secrets_manager_paid_experience: false)
      end

      it { is_expected.to be(false) }
    end

    context 'when the badge has expired' do
      it 'returns false' do
        travel_to(described_class::BADGE_EXPIRES_ON + 1.day) do
          expect(visible).to be(false)
        end
      end
    end

    context 'when the user has dismissed the callout' do
      let(:user) { instance_double(User, dismissed_callout?: true) }

      it { is_expected.to be(false) }
    end
  end
end
