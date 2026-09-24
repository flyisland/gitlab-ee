# frozen_string_literal: true

module QA
  RSpec.describe 'JH Manage', :gitee, :smoke, :requires_admin do
    describe 'Project import' do
      let(:gitee_repo) { 'gitlab-qa-gitee/import-test' }
      let(:api_client) { Runtime::API::Client.as_admin }
      let(:group) { Resource::Group.fabricate_via_api! { |resource| resource.api_client = api_client } }
      let(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = api_client
          resource.hard_delete_on_api_removal = true
        end
      end

      let(:imported_project) do
        Resource::ProjectImportedFromGitee.init do |project|
          project.import = true
          project.group = group
          project.gitee_personal_access_token = Runtime::Env.gitee_access_token
          project.gitee_repository_path = gitee_repo
          project.api_client = api_client
        end
      end

      before do
        group.add_member(user, Resource::Members::AccessLevel::MAINTAINER)

        Flow::Login.sign_in(as: user)
        Page::Main::Menu.perform(&:go_to_create_project)
        Page::Project::New.perform do |project_page|
          project_page.click_import_project
          project_page.click_gitee_link
        end
      end

      it 'imports a Gitee repo', testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/61' do
        Page::Project::Import::Gitee.perform do |import_page|
          import_page.add_personal_access_token(Runtime::Env.gitee_access_token)
          import_page.import!(gitee_repo, group.full_path, imported_project.name)

          aggregate_failures do
            expect(import_page).to have_imported_project(gitee_repo, wait: 240)
            expect(import_page).to have_go_to_project_link(gitee_repo)
          end
        end

        imported_project.reload!.visit!
        Page::Project::Show.perform do |project|
          aggregate_failures do
            expect(project).to have_content(imported_project.name)
            expect(project).to have_content('Project for gitee import test')
          end
        end
      end
    end
  end
end
