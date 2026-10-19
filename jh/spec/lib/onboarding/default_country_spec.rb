# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Onboarding::DefaultCountry, feature_category: :onboarding do
  let(:user) { build_stubbed(:user) }
  let(:request) { instance_double(ActionDispatch::Request, headers: { 'Cf-Ipcountry' => country_code }) }

  subject(:code) { described_class.new(request, user).code }

  context 'when China is resolved' do
    let(:country_code) { 'CN' }

    it 'selects the country offered in JH' do
      expect(code).to eq('CN')
    end
  end

  context 'when a country denied in JH is resolved' do
    let(:country_code) { 'IR' }

    it 'does not offer a default country' do
      expect(code).to be_nil
    end
  end
end
