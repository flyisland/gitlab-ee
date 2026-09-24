# frozen_string_literal: true

module QA
  RSpec.describe 'JH Fulfillment', :smoke, :requires_admin, :external_api_calls, :external_ai_provider,
    only: { subdomain: :staging, tld: '.com' },
    feature_flag: { name: 'dap_require_identity_verification', scope: :group } do
    describe 'Consume GitLab Credits' do
      let(:credits_quantity) { 100 }
      let(:admin_api_client) { Runtime::API::Client.as_admin }
      let(:reset_plan_after_test) { false }

      let(:user) do
        Resource::User.fabricate_via_api! do |user|
          user.email = "jihu-qa+#{SecureRandom.hex(4)}@gitlab.cn"
          user.api_client = admin_api_client
          user.hard_delete_on_api_removal = true
        end
      end

      let(:group) do
        sandbox = Resource::Sandbox.fabricate_via_api! do |resource|
          resource.path = "fulfillment-consume-credits-#{SecureRandom.hex(4)}"
          resource.visibility = 'private'
          resource.api_client = admin_api_client
        end
        sandbox.add_member(user, Resource::Members::AccessLevel::OWNER)
        sandbox
      end

      before do
        group
        Flow::Login.sign_in(as: user)
        Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
      end

      after do
        if reset_plan_after_test
          Flow::Login.sign_in_as_admin
          Page::Admin::Groups::Index.perform do |index|
            index.edit_group_subscription(group.name, 'No plan')
          end
        end

        group.remove_via_api!
        user.remove_via_api!
      end

      context 'for a Free group' do
        let(:projects_to_remove) { [] }

        after do
          projects_to_remove.each(&:remove_via_api!)
        end

        it 'consumes purchased credits by using Duo Agent Platform Chat',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/126' do
          Flow::JhPurchase.purchase_credits(group, credits_quantity, source: :billing)
          ::QA::Page::Group::Settings::UsageQuotas.perform(&:close_window)

          Flow::JhPurchase.navigate_to_billing_page(group, plan_exists: false)
          ::QA::Page::Group::Settings::Billing.perform do |billing|
            expect(billing.purchased_credits).to eq(credits_quantity)
          end

          project = create(:project,
            :with_readme,
            name: "consume-credits-chat-#{SecureRandom.hex(4)}",
            group: group,
            api_client: admin_api_client)
          projects_to_remove << project
          project.visit!

          chat_response = Flow::JhCredits.consume_with_chat(
            '请以“我是 GitLab Duo Chat”开头，用中文列出你的至少 5 项主要能力，' \
              '每项包含一个具体使用场景，并在结尾用一句话总结。'
          )
          expect(chat_response).to include('我是 GitLab Duo Chat')
          Flow::JhCredits.sync_spend_credits

          consumed_credits = Flow::JhCredits.wait_for_consumed_credits(group) { |credits| credits > 0 }
          expect(consumed_credits).to be > 0
        end
      end

      context 'for an Ultimate plan group' do
        let(:reset_plan_after_test) { true }
        let(:vulnerability_name) { 'Relative Path Traversal' }
        let(:expected_consumed_credits) { 10 }

        let!(:project) do
          create(:project,
            name: "consume-credits-sast-#{SecureRandom.hex(4)}",
            description: 'Consume GitLab Credits with SAST vulnerability resolution',
            group: group,
            api_client: admin_api_client)
        end

        let!(:runner) do
          create(:project_runner,
            project: project,
            name: "runner-for-#{project.name}",
            tags: ['secure_report'])
        end

        after do
          Runtime::Feature.enable(:dap_require_identity_verification, group: group)
          runner.remove_via_api!
          project.remove_via_api!
        end

        it 'consumes purchased credits by resolving a SAST vulnerability',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/127' do
          Flow::JhPurchase.purchase_subscription('ultimate')
          Flow::JhPurchase.navigate_to_billing_page(group)
          expect(Flow::JhPurchase.verify_purchase_successful(group, 'Ultimate')).to be(true)

          Flow::JhVulnerability.enable_resolution_workflow(project: project, api_client: admin_api_client)
          Runtime::Feature.disable(:dap_require_identity_verification, group: group)

          ::QA::Page::Group::Settings::GitlabDuo.perform(&:go_to_gitlab_duo)
          Flow::JhPurchase.purchase_credits(group, credits_quantity)

          ::QA::Page::Group::Settings::UsageQuotas.perform(&:close_window)

          ::QA::Page::Group::Settings::GitlabDuo.perform do |gitlab_duo|
            gitlab_duo.go_to_configuration
            gitlab_duo.enable_foundational_flow('Resolve SAST Vulnerability')
          end

          Flow::JhVulnerability.prepare_sast_report(project: project)
          Flow::JhVulnerability.resolve_with_agentic_ai(project: project, vulnerability_name: vulnerability_name)
          Flow::JhVulnerability.wait_for_resolution_workflow(project: project)
          Flow::JhCredits.sync_spend_credits

          consumed_credits = Flow::JhCredits.wait_for_consumed_credits(group) do |credits|
            credits == expected_consumed_credits
          end
          expect(consumed_credits).to eq(expected_consumed_credits)
        end
      end
    end
  end
end
