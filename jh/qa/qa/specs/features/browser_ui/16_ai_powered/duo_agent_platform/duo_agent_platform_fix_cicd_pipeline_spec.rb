# frozen_string_literal: true

module QA
  RSpec.describe 'Ai-powered', feature_category: :duo_agent_platform do
    describe 'Fix CI/CD Pipeline with GitLab Duo' do
      let(:invalid_ci_content) do
        <<~YAML
          stages:
            - build

          build_job:
            stage: build
            script:
              - invalid_command
        YAML
      end

      shared_examples 'Fix CI/CD Pipeline with GitLab Duo' do |testcase|
        it 'fixes the failed pipeline', testcase: testcase do
          create(
            :commit,
            project: project,
            api_client: api_client,
            commit_message: 'Add broken .gitlab-ci.yml',
            actions: [{ action: 'create', file_path: '.gitlab-ci.yml', content: invalid_ci_content }]
          )

          project.visit!

          Page::Project::Menu.perform(&:go_to_pipelines)

          Page::Project::Pipeline::Index.perform do |index_page|
            index_page.wait_for_latest_pipeline(status: 'failed', wait: QA::Runtime::Env.duo_workflow_max_duration)
            index_page.click_on_latest_pipeline
          end

          Page::Component::DuoWorkflow.perform(&:click_fix_pipeline_with_duo)

          Flow::Pipeline.visit_latest_pipeline(
            status: 'passed',
            wait: QA::Runtime::Env.duo_workflow_max_duration
          )

          Page::Project::Pipeline::Show.perform do |pipeline|
            expect(pipeline).to be_passed(timeout: 1)
          end
        end
      end

      before do
        Flow::Login.sign_in(as: user)
      end

      context 'on SaaS', :external_ai_provider,
        only: { pipeline: %i[staging staging-canary canary production] } do
        let(:user) { Runtime::User::Store.test_user }
        let(:api_client) { Runtime::User::Store.default_api_client }

        let(:group) do
          create(:group, name: "dap-fix-pipeline-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-fix-pipeline-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end
        end

        include_examples 'Fix CI/CD Pipeline with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/99'
      end

      context 'on Self-managed', :orchestrated, :ai_gateway do
        let(:api_client) { Runtime::User::Store.admin_api_client }
        let(:user) { Runtime::User::Store.admin_user }

        let(:group) do
          create(:sandbox, name: "dap-fix-pipeline-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-fix-pipeline-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end

          group.visit!

          Page::Group::Menu.perform(&:go_to_general_settings)
          Page::Component::DuoAgentPlatform.perform do |dap_fix_pipeline|
            dap_fix_pipeline.enable_duo_foundational_flow_features('Fix CI/CD Pipeline')

            unless dap_fix_pipeline.has_group_updated_successfully?
              raise 'Failed to enable Duo foundational flow features'
            end
          end
        end

        include_examples 'Fix CI/CD Pipeline with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/100'
      end
    end
  end
end
