# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PreferredLanguageSwitcher do
  controller(ActionController::Base) do
    include PreferredLanguageSwitcher # rubocop:disable RSpec/DescribedClass -- for testing purposes

    before_action :init_preferred_language, only: :new

    def new
      render html: 'new page'
    end
  end

  context 'with feature flag qa_enforce_locale_to_en' do
    let(:preferred_language) { 'zh_CN' }

    before do
      allow(::Gitlab::CurrentSettings).to receive(:default_preferred_language).and_return(preferred_language)
      stub_feature_flags(disable_preferred_language_cookie: false)
    end

    subject do
      get :new

      cookies[:preferred_language]
    end

    context 'when turn it on' do
      before do
        stub_feature_flags(qa_enforce_locale_to_en: true)
      end

      it 'sets preferred_language to en' do
        is_expected.to eq 'en'
      end
    end

    context 'when turn it off as default' do
      before do
        stub_feature_flags(qa_enforce_locale_to_en: false)
      end

      it 'sets preferred_language to the setting of admin' do
        is_expected.to eq preferred_language
      end
    end
  end
end
