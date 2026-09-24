# frozen_string_literal: true

module QA
  RSpec.describe 'JH Plan', :smoke, :require_admin, only: { subdomain: 'staging' } do
    describe 'Pages' do
      let(:admin_api_client) { Runtime::API::Client.as_admin }

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

      let(:anonymous_user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      # rubocop:disable Layout/LineLength -- Long messages for UI
      let(:permission_deny_text) do
        /The resource that you are attempting to access does not exist or you don't have the necessary permissions to view it./
      end
      # rubocop:enable Layout/LineLength

      before do
        Flow::Login.sign_in
        create(:project_runner, project: project, executor: :docker)
        pipeline.visit!

        # rubocop:disable RSpec/ExpectInHook -- Need to use expect to make sure job is success
        Page::Project::Pipeline::Show.perform do |show|
          expect(show).to have_job(:pages)
          show.click_on_first_job
        end

        Page::Project::Job::Show.perform do |show|
          expect(show).to have_passed(timeout: 300)
        end
        # rubocop:enable RSpec/ExpectInHook

        Page::Project::Menu.perform(&:go_to_pages_settings)
        Page::Project::Pages.perform(&:go_to_access_page)
        @pages_url = page.current_url
      end

      after do
        anonymous_user.remove_via_api!
        project.remove_via_api!
      end

      it 'user without project permission cannot access pages',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/44' do
        page.driver.browser.close
        switch_to_window windows.first
        Capybara.reset_sessions!
        Flow::Login.sign_in(as: anonymous_user)
        visit(@pages_url) # rubocop:disable RSpec/InstanceVariable -- Need to use instance variable to save the url
        Page::Project::Pages.perform(&:accept_authorization) if Page::Main::OAuth.perform(&:needs_authorization?)
        expect(page).to have_content(permission_deny_text)
      end
    end
  end
end
