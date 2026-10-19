# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Repository::BlobType, feature_category: :source_code_management do
  include JH::ContentValidationMessagesTestHelper
  include GraphqlHelpers

  context "with content validation state" do
    let(:user)    { create(:user) }
    let(:project) { create(:project, :repository, :public) }
    let(:commit) { project.repository.commit }
    let(:blob) { commit.diffs.diff_files.first.blob }
    let!(:content_blocked_state) do
      create(:content_blocked_state, container: project, commit_sha: commit.id, path: blob.path)
    end

    before do
      allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
      allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(commit.raw)
    end

    it 'return blocked message' do
      expect(resolve_field(:raw_text_blob, blob)).to eq(illegal_tips_with_appeal_email)
    end
  end
end
