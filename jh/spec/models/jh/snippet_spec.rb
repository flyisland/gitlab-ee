# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippet do
  include RepoHelpers

  describe '#content_blocked_states' do
    context 'in content validation' do
      let(:user) { create(:user) }
      let(:snippet) { create(:project_snippet, :repository, :public) }
      let(:commit) { snippet.repository.commit }
      let(:blob) do
        Gitlab::Diff::FileCollection::Base.new(
          commit,
          project: snippet,
          diff_refs: commit.diff_refs
        ).diff_files.first.blob
      end

      let(:content_blocked_state) do
        create(:content_blocked_state, container: snippet, commit_sha: commit.id, path: blob.path)
      end

      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
        allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(commit)
      end

      it "return content blocked states" do
        content_blocked_state
        expect(snippet.content_blocked_states).to eq([content_blocked_state])
      end
    end
  end

  describe 'validations' do
    it_behaves_like "content validation", :project_snippet, :title
    it_behaves_like "content validation", :project_snippet, :description
  end
end
