# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::PagesController, feature_category: :pages do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public) }

  let(:request_params) do
    {
      namespace_id: project.namespace,
      project_id: project
    }
  end

  context 'when ff jh_pages disabled' do
    before do
      stub_config(pages: {
        enabled: true,
        external_https: true,
        access_control: false
      })

      sign_in(user)
      project.add_maintainer(user)

      stub_feature_flags(jh_pages: false)
    end

    describe 'GET new', :saas do
      it 'returns 404 status' do
        get :new, params: request_params

        expect(response).to have_gitlab_http_status(:not_found)
      end

      context 'when the project is in a subgroup' do
        let(:group) { create(:group, :nested) }
        let(:project) { create(:project, namespace: group) }

        it 'returns a 404 status code' do
          get :new, params: request_params

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    describe 'GET show', :saas do
      subject { get :show, params: request_params }

      context 'when the project does have onboarding complete' do
        before do
          project.pages_metadatum.update_attribute(:onboarding_complete, true)
        end

        it 'returns 404 status' do
          expect(subject).to have_gitlab_http_status(:not_found)
        end

        context 'when the project is in a subgroup' do
          let(:group) { create(:group, :nested) }
          let(:project) { create(:project, namespace: group) }

          it 'returns a 404 status code' do
            expect(subject).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'when pages is disabled' do
        let(:project) { create(:project, :pages_disabled) }

        it 'returns 404 status' do
          expect(subject).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end
