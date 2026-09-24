# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, except: { subdomain: :staging } do
    describe 'Purchase' do
      let(:group_for_trial) do
        Resource::Sandbox.fabricate! do |sandbox|
          sandbox.path = "fulfillment-free-trial-prod-#{SecureRandom.hex(4)}"
          sandbox.visibility = 'private'
        end
      end

      before do
        Flow::Login.sign_in
      end

      describe 'starts a free trial' do
        context 'when on about page with multiple eligible namespaces' do
          it 'registers for a new trial and continue to upgrade premium',
            testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/59' do
            Flow::JhPurchase.navigate_to_billing_page(group_for_trial, plan_exists: false)
            Page::Group::Settings::Billing.perform(&:go_to_free_trial)

            ::QA::Flow::JhTrial.start_trial(group_for_trial.path, skip_select: true)

            ThirdPartyPage::Alert::FreeTrial.perform do |free_trial_alert|
              expect(free_trial_alert.trial_activated_message?)
                .to be(true)
            end

            Page::Group::Menu.perform(&:go_to_billing)
            Flow::JhTrial.verify_trial_success

            ::QA::Page::Group::Settings::Billing.perform(&:go_to_upgrade_premium_from_trial)

            Flow::JhPurchase.oauth_login_customerdot

            ::QA::ThirdPartyPage::Customerdot::Subscription.perform do |subscription|
              subscription.fill_seat_quantity(2)
              subscription.accept_terms_and_conditions
              subscription.confirm_purchase
            end

            ::QA::ThirdPartyPage::Customerdot::Invoice.perform do |invoice|
              expect(invoice.page_shown?).to be(true)
            end
          end
        end
      end
    end
  end
end
