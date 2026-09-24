# frozen_string_literal: true

module QA
  RSpec.describe 'JH Create', :smoke, :require_admin, feature_flag: { name: 'lines_of_code', scope: :project } do
    describe 'code lines for contributors' do
      let(:test_file) { 'test.yml' }

      let(:test_file_content) do
        <<~YML
          test-success1:
            script: echo 'First Lines'

          test-success2:
            script: echo 'Second Lines'
        YML
      end

      let(:group) do
        Resource::Group.fabricate_via_api! do |group|
          group.path = "group-to-test-code-lines-for-contributors-#{SecureRandom.hex(8)}"
        end
      end

      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = 'project-to-test-code-lines-for-contributors'
          project.group = group
        end
      end

      let!(:commit) do
        Resource::Repository::Commit.fabricate_via_api! do |commit|
          commit.project = project
          commit.commit_message = 'Add new file'
          commit.add_files([{ file_path: test_file, content: test_file_content }])
        end
      end

      before do
        Runtime::Feature.enable(:lines_of_code, project: project)

        Flow::Login.sign_in
        group.visit!
        project.visit!
      end

      it 'show the code lines',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/63' do
        Page::Project::Menu.perform(&:go_to_contributor_statistics)
        Page::Repository::Contributors::CodeLines.perform do |code_lines|
          expect(code_lines).to have_addition_lines_element("+ 5 lines")
          expect(code_lines).to have_deletion_lines_element("- 0 lines")
        end
      end

      it 'show the effective code lines',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/64' do
        Page::Project::Menu.perform(&:go_to_contributor_statistics)
        Page::Repository::Contributors::CodeLines.perform do |code_lines|
          expect(code_lines).to have_addition_effective_lines_element("+ 4 effective lines")
          expect(code_lines).to have_deletion_effective_lines_element("- 0 effective lines")
        end
      end
    end
  end
end
