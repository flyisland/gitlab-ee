# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippet do
  include RepoHelpers

  describe 'repository diffs', feature_category: :snippets do
    [:personal_snippet, :project_snippet].each do |snippet_type|
      context "with a #{snippet_type}" do
        let(:snippet) { create(snippet_type, :repository) }

        it 'uses the global look-ahead flag', :aggregate_failures do
          expect(Gitlab::GitalyClient::DiffStitcher)
            .to receive(:new).with(anything, lookahead: true).and_call_original

          expect(snippet.repository.raw_repository.diff(nil, snippet.repository.commit.id).to_a).not_to be_empty
        end

        context 'when the look-ahead flag is disabled' do
          before do
            stub_feature_flags(diff_stitcher_single_file_lookahead: false)
          end

          it 'disables look-ahead', :aggregate_failures do
            expect(Gitlab::GitalyClient::DiffStitcher)
              .to receive(:new).with(anything, lookahead: false).and_call_original

            expect(snippet.repository.raw_repository.diff(nil, snippet.repository.commit.id).to_a).not_to be_empty
          end
        end
      end
    end
  end

  describe '#content_blocked_states' do
    context 'in content validation' do
      let(:user) { create(:user) }
      let(:snippet) { create(:project_snippet, :repository, :public) }
      let(:commit) { snippet.repository.commit }
      let(:blob) { snippet.repository.blob_at(commit.id, snippet.list_files.first) }

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
