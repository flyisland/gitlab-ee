# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Recaptcha.configuration do
  describe '.api_server_url' do
    it 'returns global api server url available in China' do
      expect(described_class.api_server_url).to eq('https://www.recaptcha.net/recaptcha/api.js')
    end
  end

  describe '.verify_url' do
    it 'returns global verify url available in China' do
      expect(described_class.verify_url).to eq('https://www.recaptcha.net/recaptcha/api/siteverify')
    end
  end
end
