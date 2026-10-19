# frozen_string_literal: true

module QA
  include QA::Support::Helpers::Plan
  RSpec.shared_examples 'Purchase storage' do |purchase_quantity, existed_quantity|
    it 'adds additional storage to group namespace' do
      Flow::JhPurchase.navigate_to_usage_quotas(group)
      Flow::JhPurchase.purchase_storage(purchase_quantity)

      Flow::JhPurchase.navigate_to_usage_quotas(group)
      QA::Page::Group::Settings::UsageQuotas.perform do |usage_quota|
        expected_storage = (storage * (purchase_quantity + existed_quantity)) + Runtime::Env.default_storage.to_f
        usage_quota.switch_to_storage
        Support::Waiter.wait_until(max_duration: 120, reload_page: page, raise_on_failure: false) do
          expect(usage_quota.purchased_storage).to eq(expected_storage)
        end
      end
    end
  end

  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, only: { subdomain: :staging, tld: '.com' } do
    let(:addon_type) { 'storage' }
    let(:storage) { 10 }
    let(:user) do
      Resource::User.fabricate_via_api! do |user|
        user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
        user.api_client = Runtime::API::Client.as_admin
        user.hard_delete_on_api_removal = true
      end
    end

    let(:group) do
      Resource::Sandbox.fabricate! do |sandbox|
        sandbox.path = "fulfillment-purchase-storage-#{SecureRandom.hex(4)}"
        sandbox.api_client = Runtime::API::Client.as_admin
      end
    end

    before do
      Flow::Login.sign_in(as: user)

      Resource::Project.fabricate_via_api! do |project|
        project.name = 'storage'
        project.group = group
        project.initialize_with_readme = true
        project.api_client = Runtime::API::Client.as_admin
      end
    end

    context 'when purchase storage without active subscription',
      testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/43' do
      after do
        group.remove_via_api!
      end

      it_behaves_like 'Purchase storage', 5, 0
    end

    context 'when purchase storage with trial user',
      testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/42' do
      before do
        Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
        Page::Group::Settings::Billing.perform(&:go_to_free_trial)
        ::QA::Flow::JhTrial.start_trial(group.path, skip_select: true)
      end

      it_behaves_like 'Purchase storage', 10, 0
    end

    context 'with purchase storage with existing CI minutes packs',
      testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/40' do
      before do
        Flow::JhPurchase.navigate_to_usage_quotas(group)
        Flow::JhPurchase.purchase_storage(5)
      end

      it_behaves_like 'Purchase storage', 10, 5
    end
  end
end
