# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetBlobPresenter do
  include JH::ContentValidationMessagesTestHelper
  let_it_be(:snippet) { create(:personal_snippet, :repository, :public) }

  let(:commit) { snippet.repository.commit }
  let(:blob) do
    Gitlab::Diff::FileCollection::Base.new(
      commit,
      project: snippet,
      diff_refs: commit.diff_refs
    ).diff_files.first.blob
  end

  context "in content validation" do
    before do
      allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
      allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(commit)
    end

    let!(:content_blocked_state) do
      create(:content_blocked_state, container: snippet, commit_sha: commit.id, path: blob.path)
    end

    describe "#plain_data" do
      it "return blocked message when content blocked" do
        expect(described_class.new(blob).plain_data).to include(illegal_tips)
        expect(described_class.new(blob).plain_data).to include(illegal_appeal_tips)
      end
    end

    describe "#raw_plain_data" do
      it "return blocked message when content blocked" do
        expect(described_class.new(blob).raw_plain_data).to include(illegal_tips_with_appeal_email)
      end
    end

    describe "#rich_data" do
      it "return blocked message when content blocked" do
        expect(described_class.new(blob).rich_data).to include(illegal_tips)
        expect(described_class.new(blob).rich_data).to include(illegal_appeal_tips)
      end
    end
  end
end
