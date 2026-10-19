# frozen_string_literal: true

require 'base64'

module QA
  RSpec.describe 'JH Verify', :gitee, :requires_admin, only: { subdomain: :staging } do
    describe 'Project import from gitee' do
      let(:commit_message) { "Update #{gitee_data[:file_name]} - #{Time.now}" }
      let(:project_name) { 'gitee-project-with-pipeline' }
      let(:admin_api_client) { Runtime::API::Client.as_admin }

      let!(:user_api_client) do
        Runtime::API::Client.new(
          :gitlab,
          personal_access_token: create(:personal_access_token, user_id: user.id, expires_at: (Time.now.to_date + 6)
          ).token
        )
      end

      let(:gitee_data) do
        {
          access_token: Runtime::Env.gitee_access_token,
          file_name: 'README.md',
          repo: 'gitlab-qa-gitee/test-project',
          repo_url: "https://gitlab-qa-gitee@gitee.com/gitlab-qa-gitee/test-project.git"
        }
      end

      let(:group) do
        Resource::Group.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
        end
      end

      let(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = admin_api_client
          resource.hard_delete_on_api_removal = true
        end
      end

      let(:imported_project) do
        Resource::ProjectImportedFromGitee.fabricate_via_browser_ui! do |project|
          project.import = true
          project.name = project_name
          project.group = group
          project.gitee_personal_access_token = gitee_data[:access_token]
          project.gitee_repository_path = gitee_data[:repo]
          project.gitee_file = gitee_data[:file_name]
          project.api_client = user_api_client
        end
      end

      before do
        admin_api_client.personal_access_token
        user_api_client.personal_access_token
        group.add_member(user, Resource::Members::AccessLevel::OWNER)
        Flow::Login.sign_in(as: user)
        imported_project
      end

      it(
        'can be synced after the mirror repository is updated',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/66'
      ) do
        Page::Project::Menu.perform(&:go_to_repository_settings)

        Page::Project::Settings::Repository.perform do |settings|
          settings.expand_mirroring_repositories do |mirror_settings|
            mirror_settings.repository_url = gitee_data[:repo_url]
            mirror_settings.mirror_direction = 'Pull'
            mirror_settings.authentication_method = 'Password'
            mirror_settings.password = Runtime::Env.gitee_password
            mirror_settings.mirror_repository
          end
        end

        current_content = edit_gitee_file

        imported_project.visit!

        Support::Waiter.wait_until(sleep_interval: 5, max_duration: 60, reload_page: page, retry_on_exception: true) do
          Page::Project::Show.perform do |project|
            expect(project).to have_readme_content(current_content)
          end
        end
      end

      private

      def edit_gitee_file
        Runtime::Logger.info "Making changes to Gitee file."

        gitee_file_contents = imported_project.get_repo_contents

        file_new_content = Base64.encode64(Faker::Lorem.sentence).strip

        contents_body =
          {
            owner: gitee_data[:repo].split('/').first,
            repo: gitee_data[:repo].split('/').last,
            path: gitee_data[:file_name],
            message: commit_message,
            content: file_new_content,
            sha: gitee_file_contents[:sha]
          }

        imported_project.update_repo_contents(contents_body)

        Support::Retrier.retry_until(max_attempts: 5, sleep_interval: 2) do
          file_content = imported_project.get_repo_contents
          current_content = Base64.decode64(file_content[:content]).strip
          current_content.equal?(Base64.decode64(file_new_content).strip)

          current_content
        end
      end
    end
  end
end
