# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Promo site URLs', 'about', feature_category: :shared do
  describe 'promo_url' do
    subject { promo_url }

    it { is_expected.to eq('https://about.gitlab.cn') }

    context 'with query parameters' do
      subject { promo_url(query: { utm_source: 'gitlab', utm_medium: 'web' }) }

      it { is_expected.to eq('https://about.gitlab.cn?utm_source=gitlab&utm_medium=web') }
    end
  end

  describe 'promo_pricing_url' do
    subject { promo_pricing_url }

    it { is_expected.to eq('https://about.gitlab.cn/pricing') }
  end
end
