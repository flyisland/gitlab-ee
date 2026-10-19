# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::CommitController do
  include JH::ContentValidationMessagesTestHelper
  render_views
  let(:project) { create(:project, :repository, :public) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  describe 'GET diff_files' do
    context 'with content blocked state' do
      let(:commit) { repository.commit }
      let!(:content_blocked_state) do
        create(:content_blocked_state, container: project, commit_sha: commit.id, path: commit.raw_diffs.first.new_path)
      end

      subject do
        params = {
          namespace_id: project.namespace.to_param,
          project_id: project,
          id: commit.id
        }

        get :diff_files, params: params
      end

      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
      end

      it "render blocked message" do
        subject

        expect(response.body).to include(illegal_tips)
        expect(response.body).to include(illegal_appeal_tips)
      end
    end
  end
end
