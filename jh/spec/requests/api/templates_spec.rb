# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Templates do
  context 'on GET templates/licenses' do
    it 'returns a list of available license templates', :aggregate_failures do
      get api('/templates/licenses')

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to include_pagination_headers
      expect(json_response).to be_an Array
      expect(json_response.size).to eq(20)
      expect(json_response.map { |l| l['key'] }).to include('agpl-3.0')
    end
  end
end
