# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/application_settings/_feishu_integration' do
  let_it_be(:user) { create(:admin) }
  let_it_be(:app_settings) { build(:application_setting) }

  subject { render partial: 'admin/application_settings/feishu_integration' }

  before do
    assign(:application_setting, app_settings)
    allow(view).to receive(:current_user).and_return(user)
  end

  describe 'feishu integration' do
    it 'render form when not com and enable feature flag' do
      expect(subject).to have_css('#js-feishu-integration-settings')
    end

    it 'not render form when com' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect(subject).not_to have_css('#js-feishu-integration-settings')
    end
  end
end
