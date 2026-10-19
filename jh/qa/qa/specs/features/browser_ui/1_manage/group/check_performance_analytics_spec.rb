# frozen_string_literal: true

module QA
  RSpec.describe 'JH Manage', :smoke, :requires_admin do
    let!(:developer) { create(:user, :with_personal_access_token) }
    let!(:developer_api_client) do
      Runtime::API::Client.new(
        :gitlab,
        personal_access_token: create(:personal_access_token, user_id: developer.id, expires_at: (Time.now.to_date + 6)
        ).token
      )
    end

    let!(:group) do
      Resource::Group.fabricate_via_api! do |group|
        group.path = "performance_analytics_group_test_#{SecureRandom.hex(8)}"
        group.api_client = Runtime::API::Client.as_admin
      end
    end

    let!(:project) do
      Resource::Project.fabricate_via_api! do |project|
        project.add_name_uuid = false
        project.name = 'project_performance_analytics_test'
        project.group = group
      end
    end

    let!(:issue) do
      Resource::Issue.fabricate_via_api! do |issue|
        issue.project = project
      end
    end

    let!(:commit) do
      Resource::Repository::Commit.fabricate_via_api! do |commit|
        commit.project = project
        commit.commit_message = "performance analytics #{random_string_for_this_trial}"
        commit.add_files([{ file_path: "text-#{SecureRandom.hex(8)}.txt", content: 'new file' }])
      end
    end

    def random_string_for_this_trial
      SecureRandom.hex(8)
    end

    def create_merge_request(api_client)
      Resource::MergeRequest.fabricate_via_api! do |merge_request|
        merge_request.api_client = api_client
        merge_request.project = project
        merge_request.description = Faker::Lorem.sentence
        merge_request.target_new_branch = false
        merge_request.file_name = Faker::File.unique.file_name
        merge_request.file_content = Faker::Lorem.sentence
      end
    end

    def create_commit(api_client)
      Resource::Repository::Commit.fabricate_via_api! do |commit|
        commit.api_client = api_client
        commit.project = project
        commit.commit_message = "performance analytics #{random_string_for_this_trial}"
        commit.add_files([{ file_path: "text-#{SecureRandom.hex(8)}.txt", content: 'new file' }])
      end
    end

    describe 'Group' do
      before do
        Flow::Login.sign_in
        project.add_member(developer)
        issue.visit!

        Page::Project::WorkItem::Show.perform(&:click_close_issue_button)

        merge_request = create_merge_request(developer_api_client)
        Flow::Login.sign_in
        merge_request.visit!
        Page::MergeRequest::Show.perform(&:merge!)
        group.visit!
        Page::Group::Menu.new.go_to_performance_analytics
      end

      context 'when export csv file' do
        it 'user can export the group performance report csv file',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/35' do
          Page::Group::Analytics.perform do |analytics|
            analytics.click_export_csv_button
            expect(analytics).to have_the_analytics_csv_file("performance_report.csv")
            Page::Group::Analytics.new.remove_exist_csv_file("performance_report.csv")
          end
        end
      end

      context 'when performance analytics title,card,lead board,performance table' do
        it 'group page can be visited and have have the all the card board and lead_board,correct value',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/34' do
          Page::Group::Analytics.perform do |analytics|
            expect(analytics).to have_analytics_title("Performance Analytics")
            card_list = {
              issuesClosed: 1,
              commitsPushed: 3,
              mergeRequestsMerged: 1,
              commitsPushedPerCapita: 1.5
            }

            expect(analytics).to have_correct_the_card_value(card_list)
            expect(analytics).to have_the_card(%w[issuesClosed
              commitsPushed
              mergeRequestsMerged
              commitsPushedPerCapita
              rank-list performance-table])
            expect(analytics).to have_the_rank_list_option(%w[commitsPushed
              issuesClosed
              mergeRequestsMerged])
          end
        end
      end

      it 'user can select project from the project filter and date range should be exist',
        testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/33' do
        Page::Group::Analytics.perform do |analytics|
          expect(analytics).to have_date_range(%w[last-7-days last-14-days last-30-days])
          analytics.select_project(project.name)
          expect(analytics).to have_project_in_project_filter(project.name)
        end
      end
    end

    describe 'Project' do
      let(:branch_name) { "test_branch" }

      before do
        Flow::Login.sign_in
        project.add_member(developer, Resource::Members::AccessLevel::MAINTAINER)
        issue.visit!

        Page::Project::WorkItem::Show.perform(&:click_close_issue_button)

        merge_request = create_merge_request(developer_api_client)
        create_commit(developer_api_client)
        Flow::Login.sign_in
        merge_request.visit!
        Page::MergeRequest::Show.perform(&:merge!)
        project.create_repository_branch(branch_name)
        project.visit!
        Page::Project::Menu.new.go_to_performance_analytics
      end

      after do
        project.remove_via_api!
        group.remove_via_api!
      end

      context 'when export csv file' do
        it 'user can export project the performance report csv file',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/31' do
          Page::Group::Analytics.perform do |analytics|
            analytics.click_export_csv_button
            expect(analytics).to have_the_analytics_csv_file("performance_report.csv")
            Page::Group::Analytics.new.remove_exist_csv_file("performance_report.csv")
          end
        end

        it 'user can select branch and date range should be exist',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/30' do
          Page::Group::Analytics.perform do |analytics|
            expect(analytics).to have_date_range(%w[last-7-days last-14-days last-30-days])
            analytics.select_branch(branch_name)
            expect(analytics).to have_branch_in_branch_filter(branch_name)
          end
        end
      end

      context 'when performance analytics tile and card,lead board,performance table' do
        it 'project page can be visited and have have the all the card board and lead_board,correct value',
          testcase: 'https://jihulab.com/gitlab-cn/quality/testcases/-/quality/test_cases/32' do
          Page::Group::Analytics.perform do |analytics|
            card_list = { issuesClosed: 1,
                          commitsPushed: 3,
                          mergeRequestsMerged: 1,
                          commitsPushedPerCapita: 1.5 }
            expect(analytics).to have_correct_the_card_value(card_list)
            expect(analytics).to have_the_card(%w[issuesClosed
              commitsPushed
              mergeRequestsMerged
              commitsPushedPerCapita
              rank-list performance-table])
            expect(analytics).to have_the_rank_list_option(%w[commitsPushed
              issuesClosed
              mergeRequestsMerged])
          end
        end
      end
    end
  end
end
