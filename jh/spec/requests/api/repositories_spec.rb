# frozen_string_literal: true

require 'spec_helper'
require 'mime/types'

RSpec.describe API::Repositories do
  include RepoHelpers

  let(:user) { create(:user) }
  let!(:project) { create(:project, :public, :repository, creator: user) }
  let!(:maintainer) { create(:project_member, :maintainer, user: user, project: project) }

  describe "GET /projects/:id/repository/tree/content_blocked_state" do
    let(:route) { "/projects/#{project.id}/repository/tree/content_blocked_state" }

    context "in content validation" do
      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
      end

      context "with blocked tree" do
        let(:commit) { project.repository.commit }
        let!(:content_blocked_state) do
          create(:content_blocked_state, container: project, commit_sha: commit.id, path: "")
        end

        it "return content blocked state" do
          get api(route, user), params: { ref: commit.id, path: "/" }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response["id"]).to eq(content_blocked_state.id)
        end
      end
    end
  end
end
