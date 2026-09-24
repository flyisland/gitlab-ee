# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentValidation::ContentBlockedState do
  include RepoHelpers

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:wiki, freeze: false) { create(:project_wiki) }
  let_it_be(:snippet) { create(:project_snippet, :repository, :public) }

  let(:project_content_blocked_state) { create(:content_blocked_state, container: project) }
  let(:wiki_content_blocked_state)    { create(:content_blocked_state, container: wiki) }
  let(:snippet_content_blocked_state) { create(:content_blocked_state, container: snippet) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:container_identifier) }
    it { is_expected.to validate_presence_of(:commit_sha) }
    it { is_expected.to validate_presence_of(:blob_sha) }
    it { is_expected.to allow_value("").for(:path) }
    it { is_expected.not_to allow_value(nil).for(:path) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:full_path).to(:project).with_prefix.allow_nil }
  end

  describe "#identifier" do
    it "return a instance of Gitlab::Repositories::Identifier" do
      expect(project_content_blocked_state.identifier).to be_a(Gitlab::Repositories::Identifier)
    end
  end

  describe "#container" do
    it "return project if container is a project" do
      expect(project_content_blocked_state.container).to eq(project)
    end

    it "return wiki if container is a wiki" do
      expect(wiki_content_blocked_state.container).to eq(wiki)
    end

    it "return snippet if container is a snippet" do
      expect(snippet_content_blocked_state.container).to eq(snippet)
    end
  end

  describe "#repo_type" do
    it "return PROJECT if container is a project" do
      expect(project_content_blocked_state.repo_type).to eq(Gitlab::GlRepository::PROJECT)
    end

    it "return WIKI if container is a wiki" do
      expect(wiki_content_blocked_state.repo_type).to eq(Gitlab::GlRepository::WIKI)
    end

    it "return SNIPPET if container is a snippet" do
      expect(snippet_content_blocked_state.repo_type).to eq(Gitlab::GlRepository::SNIPPET)
    end
  end

  describe "#project" do
    it "return project self if container is a project" do
      expect(project_content_blocked_state.project).to eq(project)
    end

    it "return wiki project if container is a wiki" do
      expect(wiki_content_blocked_state.project).to eq(wiki.project)
    end

    it "return snippet project if container is a snippet" do
      expect(snippet_content_blocked_state.project).to eq(snippet.project)
    end
  end

  describe ".blocked?" do
    it "return true if find content blocked state" do
      expect(described_class.blocked?(container_identifier: project_content_blocked_state.container_identifier,
        commit_sha: project_content_blocked_state.commit_sha,
        path: project_content_blocked_state.path)).to be(true)
    end

    it "return false if not find content blocked state" do
      expect(described_class.blocked?(container_identifier: "project-none",
        commit_sha: "commit-sha-none",
        path: "path-none")).to be(false)
    end
  end

  describe ".find_by_container_commit_path" do
    it "find blocked state by commit_sha and path" do
      expect(described_class.find_by_container_commit_path(
        project,
        project_content_blocked_state.commit_sha,
        project_content_blocked_state.path)
            ).to eq(project_content_blocked_state)
    end
  end

  describe ".find_by_wiki_page" do
    let(:wiki_page) { create(:wiki_page, wiki: wiki) }
    let(:content_blocked_state) do
      create(:content_blocked_state, container: wiki, commit_sha: wiki_page.version.commit.id, path: wiki_page.path)
    end

    it "return wiki page blocked state" do
      content_blocked_state
      expect(described_class.find_by_wiki_page(wiki_page)).to eq(content_blocked_state)
    end
  end

  context "for snippet" do
    let(:commit) { sample_commit }
    let(:content_blocked_state) do
      create(:content_blocked_state, container: snippet, commit_sha: commit.id, path: snippet.file_name)
    end

    before do
      allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(commit)
    end

    describe ".find_by_snippet_path" do
      it "return snippet path blocked state" do
        expect(described_class.find_by_snippet_path(snippet, content_blocked_state.path)).to eq(content_blocked_state)
      end
    end

    describe ".find_by_snippet" do
      before do
        allow_any_instance_of(::Snippet).to receive(:list_files).and_return([snippet.file_name])

        content_blocked_state
      end

      it "return snippet paths blocked state" do
        expect(described_class.find_by_snippet(snippet)).to eq([content_blocked_state])
      end
    end
  end
end
