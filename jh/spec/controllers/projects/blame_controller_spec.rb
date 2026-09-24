# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BlameController do
  include JH::ContentValidationMessagesTestHelper
  let(:user)    { create(:user, :with_namespace) }
  let(:project) { create(:project, :repository, :public) }

  describe "GET show" do
    render_views

    context "with content blocked state" do
      let(:commit) { project.repository.commit }
      let(:blob) { commit.diffs.diff_files.first.blob }
      let!(:content_blocked_state) do
        create(:content_blocked_state, container: project, commit_sha: commit.id, path: blob.path)
      end

      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
        allow(Gitlab::Git::Commit).to receive(:last_for_path).and_return(commit.raw)
        sign_in(user)
        project.add_maintainer(user)
      end

      it "return blocked message" do
        get(:show,
          params: {
            namespace_id: project.namespace,
            project_id: project,
            id: "#{commit.id}/#{blob.path}"
          })

        expect(response.body).to include(illegal_tips)
        expect(response.body).to include(illegal_appeal_tips)
      end
    end
  end
end
