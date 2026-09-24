# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::ContentBlockedStates, 'Content blocked state', feature_category: :api do
  let_it_be(:user) { create(:user) }
  let_it_be(:admin) { create(:admin) }
  let_it_be(:project) { create(:project, :repository, :public) }

  let(:content_blocked_state_params) do
    attributes_for(:content_blocked_state, container_identifier: "project-#{project.id}")
  end

  let(:content_blocked_state) { create(:content_blocked_state, container: project) }

  before do
    stub_application_setting(admin_mode: false)
  end

  describe "POST /content_blocked_states" do
    context 'as a non-admin user' do
      it "returns 403" do
        post api("/content_blocked_states", user), params: content_blocked_state_params

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'as an admin user' do
      it "returns content_blocked_state" do
        post api("/content_blocked_states", admin), params: content_blocked_state_params

        expect(response).to have_gitlab_http_status(:created)
        expect(json_response).to be_an Hash
        expect(json_response['blob_sha']).to eq(content_blocked_state_params[:blob_sha])
      end
    end

    context 'when state exists' do
      it "returns content_blocked_state" do
        content_blocked_state = create(:content_blocked_state, content_blocked_state_params)

        expect do
          post api("/content_blocked_states", admin), params: content_blocked_state_params
        end.not_to change { ContentValidation::ContentBlockedState.count }

        expect(json_response['id']).to eq(content_blocked_state.id)
      end
    end
  end

  describe "DELETE /content_blocked_states/:id" do
    it "return success" do
      delete api("/content_blocked_states/#{content_blocked_state.id}", admin)

      expect(response).to have_gitlab_http_status(:no_content)
    end
  end

  describe "POST /content_blocked_states/:id/complaint" do
    it "return success" do
      post api("/content_blocked_states/#{content_blocked_state.id}/complaint", user),
        params: { description: "complaint description" }

      expect(response).to have_gitlab_http_status(:no_content)
    end
  end

  describe "POST /project_scan" do
    it "return success" do
      expect(ContentValidation::ProjectScanWorker).to receive(:perform_async).with(project.id, {
        ref: "main",
        scan_path: "",
        recursive: true,
        include_binary: true
      })

      post api("/content_blocked_states/project_scan", admin),
        params: {
          project_id: project.id,
          ref: "main",
          scan_path: "",
          recursive: true,
          include_binary: true
        }

      expect(response).to have_gitlab_http_status(:no_content)
    end
  end
end
