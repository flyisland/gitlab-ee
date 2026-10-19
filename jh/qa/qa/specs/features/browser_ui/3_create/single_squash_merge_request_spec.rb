# frozen_string_literal: true

module QA
  RSpec.describe 'JH Create' do
    describe 'Single squash merge', :smoke, :require_admin,
      feature_flag: { name: 'single_squash_merge_ff' },
      except: { subdomain: :production } do
      let(:project) do
        Resource::Project.fabricate_via_api! do |project|
          project.name = "single-squash-merge-project-#{SecureRandom.hex(8)}"
        end
      end

      let(:merge_request) do
        Resource::MergeRequest.fabricate_via_api! do |merge_request|
          merge_request.project = project
          merge_request.title = "single-squash-merge-request-#{SecureRandom.hex(8)}"
          merge_request.file_name = "file-#{SecureRandom.hex(8)}.txt"
          merge_request.file_content = "First commit of single squash merge"
        end
      end

      before do
        Runtime::Feature.enable(:single_squash_merge_ff, project: project)
        Flow::Login.sign_in
      end

      it 'user merges a MR with single squash merge', \
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/60' do
        merge_request.visit!

        enable_single_squash_merge

        Resource::Repository::ProjectPush.fabricate! do |push|
          push.project = project
          push.commit_message = 'The is the second commit'
          push.branch_name = merge_request.source_branch
          push.new_branch = false
          push.file_name = "file-#{SecureRandom.hex(8)}.txt"
          push.file_content = "Second commit of single squash merge"
        end

        merge_request.visit!

        Page::MergeRequest::Show.perform(&:merge!)

        Git::Repository.perform do |repository|
          repository.uri = project.repository_http_location.uri
          repository.use_default_credentials
          repository.clone

          expect(repository.commits.size).to eq 2
        end
      end

      def enable_single_squash_merge
        Page::Project::Menu.perform(&:go_to_merge_request_settings)
        Page::Project::Settings::JhMergeRequest.perform(&:enable_single_squash_merge)
      end
    end
  end
end
