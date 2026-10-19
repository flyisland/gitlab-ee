# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::WikisController do
  include JH::ContentValidationMessagesTestHelper
  describe 'GET #show' do
    render_views

    let_it_be(:user) { create(:user) }
    let_it_be(:project, freeze: false) { create(:project, :public, :repository) }
    let_it_be(:wiki, freeze: false) { create(:project_wiki, project: project) }
    let_it_be(:wiki_page, freeze: false) { create(:wiki_page, wiki: wiki) }

    shared_examples 'forbidden to view' do
      it "render blocked message" do
        get :show, params: {
          namespace_id: project.namespace,
          project_id: project,
          id: wiki_page.path
        }

        expect(response.body).to include(illegal_tips_with_appeal_email)
      end
    end

    context "in content validation" do
      before do
        allow(ContentValidation::Setting).to receive(:block_enabled?).and_return(true)
        sign_in(user)
      end

      context "with blocked file blob" do
        let!(:content_blocked_state) do
          create(:content_blocked_state, container: wiki, commit_sha: wiki_page.version.commit.id, path: wiki_page.path)
        end

        it_behaves_like 'forbidden to view'

        context "when commit sha is not the latest one" do
          before do
            content_blocked_state.update!(commit_sha: "this-is-a-random-sha")
          end

          it_behaves_like 'forbidden to view'
        end
      end
    end
  end
end
