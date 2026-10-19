# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Performance::PerformanceMeasurementController, feature_category: :groups_and_projects do
  shared_examples 'successful response' do
    context 'when user is signed in' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'renders 200 OK' do
        gitlab_request

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  shared_examples 'action disabled by `jh_new_performance_measurement` feature flag' do
    context 'when `jh_new_performance_measurement` feature flag is disabled' do
      before do
        stub_feature_flags(jh_new_performance_measurement: false)
      end

      context 'when user is not logged in' do
        it 'renders 304' do
          gitlab_request

          expect(response).to have_gitlab_http_status(:redirect)
        end
      end

      context 'when user is logged in' do
        let(:user) { create(:user) }

        before do
          sign_in(user)
        end

        it 'renders 404 when user is logged in' do
          gitlab_request

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  describe 'GET #index' do
    subject(:gitlab_request) { get performance_measurement_index_path }

    it_behaves_like 'successful response'
    it_behaves_like 'action disabled by `jh_new_performance_measurement` feature flag'
  end
end
