# frozen_string_literal: true

module QA
  RSpec.describe 'JH Verify', :smoke, only: { subdomain: :staging } do
    describe 'Kubernetes Agent' do
      before do
        Flow::Login.sign_in
        visit_kubernetes_agent_project
      end

      it 'verifies agent status and pipeline result',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/79' do
        Page::Project::Menu.perform(&:go_to_kubernetes_clusters)

        Page::Project::Operate::Kubernetes.perform do |show|
          expect(show.has_agent?(::QA::Runtime::Env.kubernetes_agent)).to be(true)
          expect(show.has_agent_connected?).to be(true)
        end

        Page::Project::Menu.perform(&:go_to_pipelines)
        Page::Project::Pipeline::Index.perform(&:click_run_pipeline_button)
        Page::Project::Pipeline::New.perform(&:click_run_pipeline_button)

        Page::Project::Pipeline::Show.perform do |pipeline|
          pipeline.click_job(::QA::Runtime::Env.kubernetes_job)
        end

        Page::Project::Job::Show.perform do |job|
          expect(job).to be_successful(timeout: 180)
        end
      end

      private

      def visit_kubernetes_agent_project
        visit "#{Runtime::Env.gitlab_url}/#{::QA::Runtime::Env.default_kubernetes_agent_project_path}"
      end
    end
  end
end
