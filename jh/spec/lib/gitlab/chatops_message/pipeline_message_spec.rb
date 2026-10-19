# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ChatopsMessage::PipelineMessage do
  subject { described_class.new(args) }

  let(:args) do
    {
      markdown: true,
      object_attributes: {
        id: 123,
        sha: '97de212e80737a608d939f648d959671fb0a0142',
        tag: false,
        ref: 'develop',
        status: 'success',
        detailed_status: nil,
        duration: 7210,
        finished_at: "2019-05-27 11:56:36 -0300"
      },
      project: {
        id: 234,
        name: "project_name",
        path_with_namespace: 'group/project_name',
        web_url: 'http://example.gitlab.com',
        avatar_url: 'http://example.com/project_avatar'
      },
      user: {
        id: 345,
        name: "The Hacker",
        username: "hacker",
        email: "hacker@example.gitlab.com",
        avatar_url: "http://example.com/avatar"
      },
      commit: {
        id: "abcdef"
      },
      builds: nil
    }
  end

  let(:has_yaml_errors) { false }

  before do
    test_commit = Struct.new(:committer, :title).new(args[:user], "A test commit message")
    test_project = Struct.new(:commit, :name, :web_url) do
      def commit_by(_)
        commit
      end
    end.new(test_commit, args[:project][:name], args[:project][:web_url])
    allow(Project).to receive(:find) { test_project }

    test_pipeline = Struct.new(:has_yaml_errors?, :yaml_errors).new(false, "yaml error description here")
    allow(Ci::Pipeline).to receive(:find) { test_pipeline }
  end

  it 'returns an empty pretext' do
    expect(subject.pretext).to be_empty
  end

  context "when the pipeline failed" do
    it "returns the summary with a 'failed' status" do
      args[:object_attributes][:status] = 'failed'

      expect(subject.attachments).to eq("[project_name](http://example.gitlab.com): Pipeline [#123](http://example." \
        "gitlab.com/-/pipelines/123) of branch [develop](http://example.gitlab." \
        "com/-/commits/develop) by The Hacker (hacker) has failed in 02:00:10")
    end
  end

  context "when the pipeline passed with warnings" do
    it "returns the summary with a 'passed with warnings' status" do
      args[:object_attributes][:detailed_status] = 'passed with warnings'

      expect(subject.attachments).to eq("[project_name](http://example.gitlab.com): Pipeline [#123](http://example." \
        "gitlab.com/-/pipelines/123) of branch [develop](http://example.gitlab.com/-/" \
        "commits/develop) by The Hacker (hacker) has passed with warnings in 02:00:10")
    end
  end

  context "when the pipeline canceled" do
    it "returns the summary with a 'Canceled' status" do
      args[:object_attributes][:status] = 'canceled'

      expect(subject.attachments).to eq("[project_name](http://example.gitlab.com): Pipeline [#123](http://example." \
        "gitlab.com/-/pipelines/123) of branch [develop](http://example.gitlab.com/-/" \
        "commits/develop) by The Hacker (hacker) Canceled in 02:00:10")
    end
  end

  context 'when no user is provided because the pipeline was triggered by the API' do
    it "returns the summary with 'API' as the username" do
      args[:user] = nil
      expect(subject.attachments).to eq("[project_name](http://example.gitlab.com): Pipeline [#123](http://example." \
        "gitlab.com/-/pipelines/123) " \
        "of branch [develop](http://example.gitlab.com/-/commits/develop) " \
        "by API has passed in 02:00:10")
    end
  end

  it 'returns the pipeline summary as the attachments in markdown format' do
    expect(subject.attachments).to eq("[project_name](http://example.gitlab.com): " \
      "Pipeline [#123](http://example.gitlab.com/-/pipelines/123) " \
      "of branch [develop](http://example.gitlab.com/-/commits/develop) " \
      "by The Hacker (hacker) has passed in 02:00:10")
  end

  describe "#template_theme" do
    using RSpec::Parameterized::TableSyntax

    where(:status, :theme) do
      'success' | :success
      'failed' | :error
      'canceled' | :cancel
      'skipped' | :warning
      'created' | :success
    end

    with_them do
      it "return corresponding theme" do
        args[:object_attributes][:status] = status

        expect(subject.template_theme).to eq(Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[theme])
      end
    end

    it 'pass with warning' do
      args[:object_attributes][:status] = 'success'
      args[:object_attributes][:detailed_status] = 'passed with warnings'

      expect(subject.template_theme).to eq(Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:warning])
    end
  end
end
