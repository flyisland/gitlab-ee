# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::SubscriptionsController do
  let_it_be(:user) { create(:user) }

  describe 'GET #new' do
    context 'when the user is authenticated' do
      before do
        sign_in(user)
      end

      context 'when the user already has a customers dot account' do
        before do
          allow(Gitlab::SubscriptionPortal::Client)
            .to receive(:get_billing_account_details)
            .with(user)
            .and_return({
              success: true,
              billing_account_details: { "billingAccount" => { "zuoraAccountName" => "sample-account" } }
            })
        end

        context 'when URL has no plan_id param' do
          before do
            get :new
          end

          it { is_expected.to redirect_to "https://about.gitlab.cn/pricing" }
        end
      end
    end
  end
end
