# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProvincesController do
  describe 'GET #index' do
    it 'returns list of provinces of China as json' do
      get :index

      expected_json = Gitlab::Json.generate(China.provinces_for_select)

      expect(response).to have_gitlab_http_status(:ok)
      expect(response.body).to eq(expected_json)
    end
  end
end
