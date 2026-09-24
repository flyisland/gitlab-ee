# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe '#buy_minutes_subscriptions_url' do
    describe "when jh_new_purchase_flow feature is disabled" do
      before do
        stub_feature_flags(jh_new_purchase_flow: false)
      end

      it 'returns old subscription portal URL in JiHu' do
        expect(helper.buy_minutes_subscriptions_url(selected_group: 1))
          .to eq(::Gitlab::Routing.url_helpers.subscription_portal_more_minutes_url)
        expect(helper.buy_minutes_subscriptions_path(selected_group: 1))
          .to eq(::Gitlab::Routing.url_helpers.subscription_portal_more_minutes_url)
      end
    end

    describe "when jh_new_purchase_flow feature is enabled" do
      before do
        stub_feature_flags(jh_new_purchase_flow: true)
      end

      it 'returns new subscription portal URL in JiHu' do
        expect(helper.buy_minutes_subscriptions_url(selected_group: 1))
          .to eq("http://#{helper.request.host}/-/subscriptions/buy_minutes?selected_group=1")
        expect(helper.buy_minutes_subscriptions_path(selected_group: 1))
          .to eq("/-/subscriptions/buy_minutes?selected_group=1")
      end
    end
  end
end
