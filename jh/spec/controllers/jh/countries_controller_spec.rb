# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CountriesController do
  describe 'GET #index' do
    before do
      stub_feature_flags(jh_filter_countries: true)
    end

    it 'does include JH Market and other countries but no denied countries' do
      get :index

      resultant_countries = json_response.map { |row| row[1] }

      expect(resultant_countries).not_to include(*World::COUNTRY_DENYLIST)
      expect(resultant_countries).to include(*World::JH_MARKET)
    end

    it 'does not include list of denied countries when JH is not enabled' do
      allow(::Gitlab).to receive_messages(jh?: false, com?: false)
      get :index

      resultant_countries = json_response.map { |row| row[1] }

      expect(resultant_countries).not_to include(*World::COUNTRY_DENYLIST)
      expect(resultant_countries).to include(*World::JH_MARKET)
    end

    it 'referer is not trials/new' do
      allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      request.headers['Referer'] = 'https://gitlab.com/-/trials/new?'

      get :index

      resultant_countries = json_response.map { |row| row[1] }
      expect(resultant_countries).to eq(['CN'])
    end
  end
end
