# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/application_settings/metrics_and_profiling' do
  include ApplicationSettingsHelper
  let_it_be(:user) { create(:admin) }
  let_it_be(:app_settings) { build(:application_setting) }

  context 'with disable_usage_statistics disable' do
    before do
      allow(view).to receive(:current_user).and_return(user)
      assign(:application_setting, app_settings)
    end

    it 'show usage-statistics' do
      render

      expect(rendered).to have_css('#js-usage-settings')
    end
  end

  context 'with disable_usage_statistics enable' do
    before do
      allow(view).to receive(:current_user).and_return(user)
      assign(:application_setting, app_settings)
      stub_feature_flags(jh_usage_statistics: false)
    end

    it 'hidden usage-statistics' do
      render

      expect(rendered).not_to have_css('#js-usage-settings')
    end
  end
end
