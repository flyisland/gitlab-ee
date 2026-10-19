# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppearancesHelper do
  describe '#default_brand_title' do
    it 'returns the default brand title for JH Edition' do
      expect(helper.default_brand_title).to eq('JiHu GitLab')
    end
  end
end
