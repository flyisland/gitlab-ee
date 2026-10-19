# frozen_string_literal: true

module QA
  RSpec.describe 'Ai-powered', feature_category: :duo_agent_platform do
    describe 'Convert jenkins file to GitLab CI with GitLab Duo' do
      let(:jenkins_file_name) { 'Jenkinsfile.groovy' }
      let(:jenkins_file_content) do
        <<~JENKINS
          pipeline {
              agent any
              stages {
                  stage('Build') {
                      steps {
                          echo 'Building...'
                          sh 'make build'
                      }
                  }
                  stage('Test') {
                      steps {
                          echo 'Testing...'
                          sh 'make test'
                      }
                  }
                  stage('Deploy') {
                      steps {
                          echo 'Deploying...'
                          sh 'make deploy'
                      }
                  }
              }
          }
        JENKINS
      end

      shared_examples 'Convert jenkins file to GitLab CI with GitLab Duo' do |testcase|
        it 'converts jenkins file to .gitlab-ci.yml and creates MR', testcase: testcase do
          create(
            :commit,
            project: project,
            api_client: api_client,
            commit_message: 'Add jenkins file',
            actions: [{ action: 'create', file_path: jenkins_file_name, content: jenkins_file_content }]
          )

          project.visit!

          Page::Project::Show.perform do |project|
            project.click_file(jenkins_file_name)
          end

          Page::Component::DuoWorkflow.perform(&:click_convert_jenkins_file_with_duo)

          Support::Waiter.wait_until(
            message: 'Wait for merge request creation',
            max_duration: QA::Runtime::Env.duo_workflow_max_duration,
            sleep_interval: Flow::Pipeline::WAIT_SLEEP_INTERVAL
          ) { project.merge_requests.any? }

          Page::Project::Menu.perform(&:go_to_merge_requests)

          Page::MergeRequest::Show.perform do |mr_page|
            mr_page.click_first_merge_request
            expect(mr_page.has_title_including?('Convert')).to be_truthy, 'Expected MR title to contain "Convert"'
          end

          Page::MergeRequest::Show.perform(&:click_diffs_tab)

          Page::MergeRequest::Show.perform do |diffs_page|
            expect(diffs_page).to have_text('.gitlab-ci.yml'), 'Expected to see .gitlab-ci.yml file in the MR'
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
          create(:group, name: "dap-jenkins-convert-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-jenkins-convert-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end
        end

        include_examples 'Convert jenkins file to GitLab CI with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/97'
      end

      context 'on Self-managed', :orchestrated, :ai_gateway do
        let(:user) { Runtime::User::Store.admin_user }
        let(:api_client) { Runtime::User::Store.admin_api_client }

        let(:group) do
          create(:sandbox, name: "dap-jenkins-convert-group-#{SecureRandom.hex(4)}", api_client: api_client)
        end

        let(:project) do
          create(:project, :with_readme, name: "dap-jenkins-convert-project-#{SecureRandom.hex(4)}",
            group: group, api_client: api_client)
        end

        before do
          if Runtime::Env.duo_workflow_use_hardened_image?
            Runtime::Feature.enable(:duo_workflow_use_hardened_image, project: project)
          end

          group.visit!

          Page::Group::Menu.perform(&:go_to_general_settings)
          Page::Component::DuoAgentPlatform.perform do |dap_jenkins_convert|
            dap_jenkins_convert.enable_duo_foundational_flow_features('Convert to GitLab CI/CD')

            unless dap_jenkins_convert.has_group_updated_successfully?
              raise 'Failed to enable Duo foundational flow features'
            end
          end
        end

        include_examples 'Convert jenkins file to GitLab CI with GitLab Duo',
          'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/98'
      end
    end
  end
end
