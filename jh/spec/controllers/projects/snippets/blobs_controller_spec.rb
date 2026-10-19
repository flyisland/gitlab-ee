# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Snippets::BlobsController do
  include JH::ContentValidationMessagesTestHelper
  describe 'GET #raw' do
    let_it_be(:user) { create(:user) }

    context 'with content blockd state' do
      let(:snippet) { create(:personal_snippet, :public, :repository, author: user) }
      let(:blob) { snippet.blobs.first }
      let(:commit) do
        snippet.repository.last_commit_for_path(snippet.default_branch, blob.path, literal_pathspec: false)
      end

      let(:content_blocked_state) do
        create(:content_blocked_state, container: snippet, commit_sha: commit.id, path: blob.path)
      end

      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
        sign_in(user)
      end

      it "return blocked message" do
        content_blocked_state
        get(:raw,
          params: {
            snippet_id: snippet,
            path: blob.path,
            ref: commit.id,
            inline: false
          })
        expect(response.body).to eq(illegal_tips_with_appeal_email)
      end
    end
  end
end
