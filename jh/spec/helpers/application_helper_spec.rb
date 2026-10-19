# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe '#support_url' do
    context 'when alternate support url is specified' do
      let(:alternate_url) { 'http://company.example.com/support' }

      it 'returns the alternate support url' do
        stub_application_setting(help_page_support_url: alternate_url)

        expect(helper.support_url).to eq(alternate_url)
      end
    end

    context 'when alternate support url is not specified' do
      it 'builds the support url from the promo_url' do
        expect(helper.support_url).to eq("#{helper.promo_url}/support/")
      end
    end
  end

  describe '#page_class' do
    let(:current_user) { nil }

    before do
      allow(helper).to receive(:current_user) { current_user }
    end

    it 'in jihu environment' do
      expect(helper.page_class).to include('jh-page-wrapper')
    end
  end
end
