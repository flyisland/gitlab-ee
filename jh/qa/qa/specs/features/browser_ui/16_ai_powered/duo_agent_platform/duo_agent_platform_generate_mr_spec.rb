# frozen_string_literal: true

module QA
  RSpec.describe 'Ai-powered', feature_category: :duo_agent_platform do
    describe 'Generate MR with GitLab Duo' do
      let(:issue_title) { '实现一个最简单的基于 Ruby 的冒泡排序示例代码' }
      let(:ruby_keyword) { /Ruby/i }
      let(:bubble_sort_keyword) { /冒泡排序|bubble/i }

      shared_examples 'Generate MR with GitLab Duo' do |testcase|
        it 'generates a merge request from an issue', testcase: testcase do
          issue.visit!

          Page::Component::DuoWorkflow.perform(&:click_generate_mr_with_duo)

          Flow::Pipeline.visit_latest_pipeline(status: 'passed', wait: QA::Runtime::Env.duo_workflow_max_duration)

          Page::Project::Menu.perform(&:go_to_merge_requests)

          Page::MergeRequest::Show.perform do |mr_page|
            mr_page.click_first_merge_request
            expect do
              [ruby_keyword, bubble_sort_keyword].all? { |pattern| mr_page.title.match?(pattern) }
            end.to eventually_be_truthy.within(max_duration: 30),
              "Expected MR title to contain both '#{ruby_keyword}' and '#{bubble_sort_keyword}'"
          end

          Page::MergeRequest::Show.perform(&:click_commits_tab)

          Page::MergeRequest::Show.perform do |commit_tab|
            expect(commit_tab.has_commits?(minimum: 1)).to be_truthy, 'Expected at least 1 commit in the generated MR'
          end
        end
      end

      before do
        Flow::Login.sign_in(as: user)
      end

      after do
        group.remove_via_api!
      end

      context 'on SaaS', :external_ai_provider,
        only: { pipeline: %i[staging staging-canary canary production] } do
        let(:user) { Runtime::User::Store.test_user }
        let(:api_client) { Runtime::User::Store.default_api_client }

        let(:group) do
          create(:group, name: "dap-mr-test-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-mr-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        let(:issue) do
          create(:issue, project: project, title: issue_title, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end
        end

        include_examples 'Generate MR with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/95'
      end

      context 'on Self-managed', :orchestrated, :ai_gateway do
        let(:user) { Runtime::User::Store.admin_user }
        let(:api_client) { Runtime::User::Store.admin_api_client }

        let(:group) do
          create(:sandbox, name: "dap-mr-test-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-mr-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        let(:issue) do
          create(:issue, project: project, title: issue_title, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end

          group.visit!

          Page::Group::Menu.perform(&:go_to_general_settings)
          Page::Component::DuoAgentPlatform.perform do |dap_developer|
            dap_developer.enable_duo_foundational_flow_features('Developer')

            raise 'Failed to enable Duo foundational flow features' unless dap_developer.has_group_updated_successfully?
          end
        end

        include_examples 'Generate MR with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/96'
      end
    end
  end
end
