# frozen_string_literal: true

module Gitee
  class Client
    attr_reader :connection

    def initialize(options = {})
      @connection = Connection.new(options)
    end

    def issues(repo)
      path = "repos/#{repo}/issues"
      get_collection(path, :issue, state: 'all')
    end

    def issue_comments(repo, issue_number)
      path = "repos/#{repo}/issues/#{issue_number}/comments"
      get_collection(path, :issue_comment)
    end

    def pull_requests(repo)
      path = "repos/#{repo}/pulls"
      get_collection(path, :pull_request, state: 'all')
    end

    def pull_request_comments(repo, pull_request_id)
      path = "repos/#{repo}/pulls/#{pull_request_id}/comments"
      get_collection(path, :pull_request_comment)
    end

    def labels(repo)
      path = "repos/#{repo}/labels"
      get_collection(path, :label)
    end

    def milestones(repo)
      path = "repos/#{repo}/milestones"
      get_collection(path, :milestone, state: 'all')
    end

    def releases(repo)
      path = "repos/#{repo}/releases"
      get_collection(path, :release)
    end

    def repo(name)
      response = connection.get("repos/#{name}")
      Representation::Repo.new(response)
    end

    def repos(filter: nil)
      path = "user/repos"
      options = {}
      options[:q] = filter if filter

      get_collection(path, :repo, options)
    end

    def user
      @user ||= begin
        response = connection.get('user')
        Representation::User.new(response)
      end
    end

    private

    def get_collection(path, type, options = {})
      paginator = Paginator.new(connection, path, type, options)
      Collection.new(paginator)
    end
  end
end
