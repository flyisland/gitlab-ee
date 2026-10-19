# frozen_string_literal: true

require 'spec_helper'

RSpec.describe World, feature_category: :subscription_management do
  describe '.supported_countries' do
    it 'does return countries include JH Market and other countries, but no deny list' do
      result = described_class.supported_countries

      country_alpha2_list = result.map(&:alpha2)
      expect(country_alpha2_list).not_to include(*::World::COUNTRY_DENYLIST)
      expect(country_alpha2_list).to include(*::World::JH_MARKET)
    end
  end

  describe '.jh_trial_countries_for_select' do
    it 'only display CN' do
      allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      result = described_class.jh_trial_countries_for_select

      expect(result.first).to eq(%w[China CN 🇨🇳 86])
    end
  end

  describe '.states_for_country' do
    let(:country_code) { 'CN' }

    before do
      described_class.clear_memoization("states_for_country_#{country_code}")
    end

    context 'when it is JH COM' do
      before do
        allow(::Gitlab).to receive_messages(jh?: true, com?: true)
      end

      context 'when country is not CN' do
        let(:country_code) { 'US' }

        it 'returns states in en' do
          expect(described_class.states_for_country(country_code)).to include('Alabama')
        end
      end

      context 'when country is CN' do
        it 'returns states in zh' do
          expect(described_class.states_for_country(country_code)).to include('安徽省')
        end
      end
    end

    context 'when it is not JH COM' do
      context 'when country is CN' do
        it 'returns states in en' do
          expect(described_class.states_for_country(country_code)).to include('Anhui')
        end
      end
    end
  end
end
