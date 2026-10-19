# frozen_string_literal: true

module OnesClientHelper
  def ones_url(path)
    # "https://example.com/project/api/project/team/#{integration.namespace}/items/graphql"
    # "https://example.com/project/api/project/team/#{integration.namespace}/task/#{task_uuid}/messages"
    url_base = "https://example.com/project/api/project/"
    Gitlab::Utils.append_path url_base, path
  end

  def mock_fetch_project(url:, project_uuid:, success: true)
    response_body = success ? valid_project_response(project_uuid) : invalid_project_response(project_uuid)
    WebMock.stub_request(:post, url).with do |request|
      request.body.include?('query FetchProject')
    end.to_return(body: Gitlab::Json.generate(response_body))
  end

  def valid_project_response(project_uuid)
    {
      data: {
        project: {
          createTime: 1600000000000000,
          name: project_uuid,
          status: {
            category: "in_progress"
          },
          uuid: project_uuid
        }
      }
    }
  end

  def invalid_project_response(project_uuid)
    {
      data: {
        project: {
          createTime: nil,
          name: nil,
          status: nil,
          uuid: project_uuid
        }
      }
    }
  end

  def mock_fetch_message(url:, team_uuid:, project_uuid:, task_uuid:, user_uuid: nil)
    user_uuid ||= SecureRandom.hex(4)
    WebMock.stub_request(:get, url)
           .to_return(body: Gitlab::Json.generate(message_response(team_uuid, project_uuid, task_uuid, user_uuid)))
  end

  def message_response(team_uuid, project_uuid, task_uuid, user_uuid)
    {
      messages: [
        {
          uuid: SecureRandom.hex(4),
          team_uuid: team_uuid,
          ref_type: "task",
          ref_id: task_uuid,
          ref_name: "",
          type: "discussion",
          from: user_uuid,
          to: task_uuid,
          send_time: 1600000000000000,
          text: "message text",
          is_can_show_richtext_diff: false
        },
        {
          uuid: SecureRandom.hex(4),
          team_uuid: team_uuid,
          ref_type: "project",
          ref_id: project_uuid,
          ref_name: "",
          type: "system",
          from: "BOT",
          to: project_uuid,
          send_time: 1600000000000001,
          subject_type: "user",
          subject_id: user_uuid,
          action: "add",
          object_type: "task",
          object_id: task_uuid,
          object_name: "Multi content",
          ext: {
            field_values: [
              {
                field_name: "some field name",
                field_type: 2,
                field_uuid: "field001",
                new_value: "Multi content",
                old_value: ""
              }
            ]
          }
        }
      ]
    }
  end

  def mock_fetch_issues(url:, response_body:)
    WebMock.stub_request(:post, url).with do |request|
      request.body.include?('query FetchIssueList')
    end.to_return(body: Gitlab::Json.generate(response_body))
  end

  def issues_total_account
    66
  end

  def issues_response(task_count = Gitlab::Ones::Query::ISSUES_DEFAULT_LIMIT)
    tasks = Array.new(task_count) { issue_response }
    {
      data: {
        buckets: [
          {
            pageInfo: {
              count: task_count,
              endCursor: SecureRandom.hex(22),
              totalCount: issues_total_account
            },
            tasks: tasks
          }
        ]
      }
    }
  end

  def issue_response(options = {})
    task_uuid = options[:task_uuid] || SecureRandom.hex(8)
    user_uuid = options[:user_uuid] || SecureRandom.hex(4)
    category = options[:category] || Gitlab::Ones::Query::STATUSES.values.flatten.sample

    {
      assign: {
        avatar: "https://example.com/avatar-#{user_uuid}.png",
        key: "user-#{user_uuid}",
        name: "user name"
      },
      createTime: 1600000000000000,
      key: "task-#{task_uuid}",
      name: "task name",
      owner: {
        avatar: "",
        key: "user-#{user_uuid}",
        name: "user name"
      },
      serverUpdateStamp: 1600000000000010,
      status: {
        category: category
      },
      uuid: task_uuid
    }
  end

  def mock_fetch_issue(url:, response_body:)
    WebMock.stub_request(:post, url).with do |request|
      request.body.include?('query FetchIssue(')
    end.to_return(body: Gitlab::Json.generate(response_body))
  end

  def issue_details_response(options = {})
    {
      data: {
        task: {
          deadline: 1600000000,
          description: "<h1>issue description details</h1>",
          **issue_response(options)
        }
      }
    }
  end

  def mock_fetch_users(url:, response_body:)
    WebMock.stub_request(:post, url).with do |request|
      request.body.include?('query FetchUsers')
    end.to_return(body: Gitlab::Json.generate(response_body))
  end

  def users_response(user_uuid_list = [])
    users = user_uuid_list.map { |user_uuid| user_response(user_uuid) }
    {
      data: {
        buckets: [
          {
            users: users
          }
        ]
      }
    }
  end

  def user_response(user_uuid)
    {
      avatar: "",
      key: "user-#{user_uuid}",
      name: "user name"
    }
  end
end
