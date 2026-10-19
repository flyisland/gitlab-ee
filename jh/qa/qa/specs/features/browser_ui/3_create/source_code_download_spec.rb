# frozen_string_literal: true

require 'base64'

module QA
  RSpec.describe 'JH Create', :smoke, :require_admin do
    describe 'source code download' do
      let(:test_file) { 'cannot_be_previewed' }
      let(:test_file_content) { Base64.strict_encode64("\x00\xFF\x0F\xE1\xAB\xCD\xDE\xEF") }

      let(:project) do
        create(:project,
          :with_readme,
          name: 'project-for-disable-source-code-download',
          description: 'Add file for disable source code download')
      end

      let!(:commit) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add new file'
          commit.add_files([{ file_path: test_file, content: test_file_content, encoding: 'base64' }])
        end
      end

      context 'when source code download is disabled' do
        before do
          Flow::Login.sign_in_as_admin
          Page::Main::Menu.perform(&:go_to_admin_area)
          Page::Admin::Menu.perform(&:go_to_general_settings)
          Page::Settings::VisibilityAndAccessControls.perform(&:expand_visibility_and_access_controls)
          Page::Settings::VisibilityAndAccessControls.perform(&:check_disable_download_source_code)
        end

        after do
          Runtime::ApplicationSettings.set_application_settings(disable_download_button: false)
        end

        it 'hides the menu in code panel', \
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/21' do
          Page::Settings::VisibilityAndAccessControls.perform do |save_successfully_tips|
            expect(save_successfully_tips).to have_notice("Application settings saved successfully")
          end

          Flow::Login.sign_in
          project.visit!
          Support::Retrier.retry_until(
            max_attempts: 5, retry_on_exception: true, reload_page: page, sleep_interval: 2
          ) do
            Page::Project::Components::CodePanel.perform(&:open_code_panel)
            Page::Project::Components::CodePanel.perform do |menu|
              expect(menu).not_to have_download_source_code_is_disabled
            end
          end
        end

        it 'hides the download button for files that cannot be previewed', \
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/22' do
          Page::Settings::VisibilityAndAccessControls.perform do |save_successfully_tips|
            expect(save_successfully_tips).to have_notice("Application settings saved successfully")
          end

          Flow::Login.sign_in
          project.visit!

          Page::Project::Show.perform do |show|
            show.click_file(test_file)
          end

          Page::Project::New.perform do |show|
            expect(show).to have_no_preview_for_this_file_type
            expect(show).not_to have_download_link(test_file)
          end
        end
      end
    end
  end
end
