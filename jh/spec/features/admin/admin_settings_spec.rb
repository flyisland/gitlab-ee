# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin updates settings' do
  include StubENV

  let(:admin) { create(:admin) }
  let(:dot_com?) { false }

  describe 'dingtalk integration' do
    before do
      allow(Gitlab).to receive(:com?).and_return(dot_com?)
      stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      sign_in(admin)
      enable_admin_mode!(admin)
    end

    it 'update dingtalk integration settings' do
      visit general_admin_application_settings_path

      page.within('#js-dingtalk-integration-settings') do
        click_button _('Expand')
        check s_('JH|Integrations|Enable DingTalk Integration')
        fill_in s_('JH|Integrations|DingTalk Corp Id'), with: 'ding-corp-id'
        fill_in s_('JH|Integrations|DingTalk App Key'), with: 'ding-app-key'
        fill_in s_('JH|Integrations|DingTalk App Secret'), with: 'ding-app-secret'
        click_button _('Save changes')
      end

      expect(page).to have_content _('Application settings saved successfully')
      expect(find('#application_setting_dingtalk_integration_enabled')).to be_checked
      expect(find('#application_setting_dingtalk_corpid').value).to eq 'ding-corp-id'
      expect(find('#application_setting_dingtalk_app_key').value).to eq 'ding-app-key'
      expect(find('#application_setting_dingtalk_app_secret').value).to eq 'ding-app-secret'
    end
  end

  describe 'feishu integration' do
    before do
      allow(Gitlab).to receive(:com?).and_return(dot_com?)
      stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      sign_in(admin)
      enable_admin_mode!(admin)
    end

    it 'update feishu integration settings' do
      visit general_admin_application_settings_path

      page.within('#js-feishu-integration-settings') do
        click_button _('Expand')
        check s_('JH|INTEGRATION|Enable FeiShu Integration')
        fill_in s_('JH|INTEGRATION|FeiShu App ID'), with: 'feishu-app-key'
        fill_in s_('JH|INTEGRATION|FeiShu App Secret'), with: 'feishu-app-secret'
        click_button _('Save changes')
      end

      expect(page).to have_content _('Application settings saved successfully')
      expect(find('#application_setting_feishu_integration_enabled')).to be_checked
      expect(find('#application_setting_feishu_app_key').value).to eq 'feishu-app-key'
      expect(find('#application_setting_feishu_app_secret').value).to eq 'feishu-app-secret'
    end
  end

  context 'when testing nav bar', :js do
    before do
      stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
      sign_in(admin)
      enable_admin_mode!(admin)
    end

    it 'shows default help links in nav' do
      default_support_url = "https://#{::Gitlab.promo_host}/support/"

      visit root_dashboard_path

      within_testid('super-sidebar') do
        click_on 'Help'
        expect(page).to have_link(text: 'Help', href: help_path)
        expect(page).to have_link(text: 'Support', href: default_support_url)
      end
    end

    it 'shows custom support url in nav when set' do
      new_support_url = 'http://example.com/help'
      stub_application_setting(help_page_support_url: new_support_url)

      visit root_dashboard_path

      within_testid('super-sidebar') do
        click_on 'Help'
        expect(page).to have_link(text: 'Support', href: new_support_url)
      end
    end
  end
end
