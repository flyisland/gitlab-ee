# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::CommitServiceWorker do
  include AfterNextHelpers
  let_it_be(:user) { create(:user) }
  let_it_be(:project, freeze: false) { create(:project, :repository) }

  subject(:perform) { described_class.new.perform(commit.id, container_identifier, user.id) }

  context "when container is not exists" do
    subject(:perform) { described_class.new.perform("commit_id", "project-111111", user.id) }

    it "not init ContentValidation::CommitService" do
      expect(ContentValidation::CommitService).not_to receive(:new)
      perform
    end
  end

  context "when container is an empty wiki" do
    let(:project) { create(:project, :wiki_repo, :repository) }
    let(:container_identifier) { "project-#{project.id}-wiki" }
    let(:commit) { project.repository.commit(project.default_branch) }

    it "call ContentValidation::CommitService#execute" do
      expect_next(ContentValidation::CommitService).to receive(:execute)
      perform
    end
  end

  context "when user is not exists" do
    let(:container_identifier) { "project-#{project.id}" }
    let(:commit) { project.repository.commit(project.default_branch) }

    subject(:perform) { described_class.new.perform(commit.id, container_identifier, "not_exists_user_id") }

    it "not init ContentValidation::CommitService" do
      expect(ContentValidation::CommitService).not_to receive(:new)
      perform
    end
  end

  context "for project commit" do
    let(:container_identifier) { "project-#{project.id}" }
    let(:commit) { project.repository.commit(project.default_branch) }

    it "init ContentValidation::CommitService" do
      expect(ContentValidation::CommitService).to receive(:new)
        .with(hash_including(commit: commit,
          container: project,
          project: project,
          repo_type: ::Gitlab::GlRepository::PROJECT,
          user: user))
        .and_call_original
      perform
    end

    it "call ContentValidation::CommitService#execute" do
      expect_next(ContentValidation::CommitService).to receive(:execute)
      perform
    end
  end

  context "for wiki commit" do
    let(:wiki) { create(:project_wiki, :empty_repo, project: project) }
    let!(:wiki_page) { create(:wiki_page, wiki: wiki, container: project) }
    let(:commit) { wiki.repository.commit(wiki.default_branch) }
    let(:container_identifier) { "project-#{project.id}-wiki" }

    it "init ContentValidation::CommitService" do
      expect(ContentValidation::CommitService).to receive(:new)
        .with(hash_including(commit: commit,
          container: wiki,
          project: project,
          repo_type: ::Gitlab::GlRepository::WIKI,
          user: user))
        .and_call_original
      perform
    end

    it "call ContentValidation::CommitService#execute" do
      expect_next(ContentValidation::CommitService).to receive(:execute)
      perform
    end
  end

  context "for snippet commit" do
    let(:snippet) { create(:project_snippet, :repository, project: project) }
    let(:commit) { snippet.repository.commit(snippet.default_branch) }
    let(:container_identifier) { "snippet-#{snippet.id}" }

    it "init ContentValidation::CommitService" do
      expect(ContentValidation::CommitService).to receive(:new)
        .with(hash_including(commit: commit,
          container: snippet,
          project: project,
          repo_type: ::Gitlab::GlRepository::SNIPPET,
          user: user))
        .and_call_original
      perform
    end

    it "call ContentValidation::CommitService#execute" do
      expect_next(ContentValidation::CommitService).to receive(:execute)
      perform
    end
  end
end
