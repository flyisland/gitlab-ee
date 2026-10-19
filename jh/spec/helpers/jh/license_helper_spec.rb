# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JH::LicenseHelper do
  describe '#self_managed_new_trial_url' do
    it "return JH_Doc url" do
      expect(helper.self_managed_new_trial_url).to eq(::Gitlab::SubscriptionPortal.free_trial_url)
    end

    context "when run as SaaS", :saas do
      let(:user) { build_stubbed(:user) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
      end

      it "return saas trials url" do
        expect(helper.self_managed_new_trial_url).to include('/trials/new')
      end
    end
  end
end
