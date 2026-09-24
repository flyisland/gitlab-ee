# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitee::Client do
  let(:options) { { token: 'abc123' } }
  let(:connection) { Gitee::Connection.new(options) }

  subject { described_class.new(options) }

  describe '#initialize' do
    it 'initializes connection' do
      expect(Gitee::Connection).to receive(:new).with(options)

      described_class.new(options)
    end
  end

  describe '#issues' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with issues api path' do
      path = 'repos/test/issues'
      issue_options = { state: 'all' }
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :issue, issue_options)
      expect(Gitee::Collection).to receive(:new)

      subject.issues('test')
    end
  end

  describe '#issue_comments' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with issue comments api path' do
      path = 'repos/test/issues/1/comments'
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :issue_comment, {})
      expect(Gitee::Collection).to receive(:new)

      subject.issue_comments('test', '1')
    end
  end

  describe '#pull_requests' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with pull requests api path' do
      path = 'repos/test/pulls'
      pr_options = { state: 'all' }
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :pull_request, pr_options)
      expect(Gitee::Collection).to receive(:new)

      subject.pull_requests('test')
    end
  end

  describe '#pull_request_comments' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with pull request comments api path' do
      path = 'repos/test/pulls/1/comments'
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :pull_request_comment, {})
      expect(Gitee::Collection).to receive(:new)

      subject.pull_request_comments('test', '1')
    end
  end

  describe '#labels' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with labels api path' do
      path = 'repos/test/labels'
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :label, {})
      expect(Gitee::Collection).to receive(:new)

      subject.labels('test')
    end
  end

  describe '#milestones' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with milestones api path' do
      path = 'repos/test/milestones'
      milestone_options = { state: 'all' }
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :milestone, milestone_options)
      expect(Gitee::Collection).to receive(:new)

      subject.milestones('test')
    end
  end

  describe '#repo' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with repo api path' do
      path = 'repos/test'
      expect(connection).to receive(:get).with(path)
      expect(Gitee::Representation::Repo).to receive(:new)

      subject.repo('test')
    end
  end

  describe '#releases' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request collection with releases api path' do
      path = 'repos/test/releases'
      expect(Gitee::Paginator).to receive(:new).with(connection, path, :release, {})
      expect(Gitee::Collection).to receive(:new)

      subject.releases('test')
    end
  end

  describe '#repos' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    context 'with filter params' do
      it 'request collection with repos api path' do
        path = 'user/repos'
        repos_options = { q: 'aaa' }
        expect(Gitee::Paginator).to receive(:new).with(connection, path, :repo, repos_options)

        subject.repos(filter: 'aaa')
      end
    end

    context 'without filter params' do
      it 'request collection with repos api path' do
        path = 'user/repos'
        expect(Gitee::Paginator).to receive(:new).with(connection, path, :repo, {})

        subject.repos
      end
    end
  end

  describe '#user' do
    before do
      allow(Gitee::Connection).to receive(:new).and_return(connection)
    end

    it 'request user with user api path' do
      path = 'user'
      expect(connection).to receive(:get).with(path)
      expect(Gitee::Representation::User).to receive(:new)

      subject.user
    end
  end
end
