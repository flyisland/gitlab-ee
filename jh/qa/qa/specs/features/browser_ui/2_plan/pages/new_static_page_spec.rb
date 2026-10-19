# frozen_string_literal: true

module QA
  RSpec.describe 'JH Plan', :smoke, only: { subdomain: 'staging' } do
    describe 'Pages' do
      let!(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'gitlab-pages-project'
          project.template_name = :plainhtml
        end
      end

      let(:pipeline) do
        Resource::Pipeline.fabricate_via_api! do |pipeline|
          pipeline.project = project
          pipeline.variables = [
            { key: :CI_PAGES_DOMAIN, value: 'nip.io', variable_type: :env_var },
            { key: :CI_PAGES_URL, value: 'http://127.0.0.1.nip.io', variable_type: :env_var }
          ]
        end
      end

      before do
        Flow::Login.sign_in
        create(:project_runner, project: project, executor: :docker)
        pipeline.visit!
      end

      it 'creates a Pages website',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/45' do
        Page::Project::Pipeline::Show.perform do |show|
          expect(show).to have_job(:pages)
          show.click_on_first_job
        end

        Page::Project::Job::Show.perform do |show|
          expect(show).to have_passed(timeout: 300)
        end

        Page::Project::Menu.perform(&:go_to_pages_settings)
        Page::Project::Pages.perform(&:go_to_access_page)

        Page::Main::OAuth.perform(&:authorize!) if Page::Main::OAuth.perform(&:needs_authorization?)

        Support::Waiter.wait_until(
          sleep_interval: 2,
          max_duration: 60,
          reload_page: page,
          retry_on_exception: true
        ) do
          expect(page).to have_content(
            'This is a simple plain-HTML website on GitLab Pages, without any fancy static site generator.'
          )
        end
      end
    end
  end
end
