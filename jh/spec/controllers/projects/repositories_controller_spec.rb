# frozen_string_literal: true

require "spec_helper"

RSpec.describe Projects::RepositoriesController do
  let_it_be(:project) { create(:project, :repository) }

  context "with `disable_download_button enabled`" do
    before do
      stub_licensed_features(disable_download_button: true)
      stub_application_setting(disable_download_button: true)
    end

    describe "GET archive" do
      let_it_be(:user) { create(:user) }
      let(:archive_name) { "#{project.path}-master" }

      before_all do
        project.add_developer(user)
      end

      before do
        sign_in(user)
      end

      it 'return not found' do
        get :archive, params: { namespace_id: project.namespace, project_id: project, id: "master" }, format: "zip"

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
