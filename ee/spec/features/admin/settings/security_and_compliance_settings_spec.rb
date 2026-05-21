# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin updates security and compliance settings', :with_current_organization, :request_store,
  :enable_admin_mode, feature_category: :software_composition_analysis do
  include Features::SettingsHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:default_organization) { create(:organization) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    sign_in(admin)
    allow(License).to receive(:feature_available?).and_return(true)
    allow(Organizations::Organization).to receive(:default_organization).and_return(default_organization)
  end

  context 'with dependency scanning settings' do
    context 'when dependency_scanning feature is enabled' do
      before do
        stub_licensed_features(dependency_scanning: true)
        visit security_and_compliance_admin_application_settings_path
      end

      it 'allows you to change the dependency_scanning_sbom_scan_api_upload_limit setting' do
        within_testid('admin-dependency-scanning-settings') do
          fill_in 'application_setting[dependency_scanning_sbom_scan_api_upload_limit]', with: 500
        end

        expect_save_settings('admin-dependency-scanning-settings')

        expect(current_settings.dependency_scanning_sbom_scan_api_upload_limit).to be 500
      end

      it 'allows you to change the dependency_scanning_sbom_scan_api_download_limit setting' do
        within_testid('admin-dependency-scanning-settings') do
          fill_in 'application_setting[dependency_scanning_sbom_scan_api_download_limit]', with: 500
        end

        expect_save_settings('admin-dependency-scanning-settings')

        expect(current_settings.dependency_scanning_sbom_scan_api_download_limit).to be 500
      end
    end

    context 'when dependency_scanning feature is disabled' do
      before do
        stub_licensed_features(dependency_scanning: false)
        visit security_and_compliance_admin_application_settings_path
      end

      it 'does not display the dependency scanning settings' do
        expect(page).not_to have_selector('[data-testid="admin-dependency-scanning-settings"]')
      end
    end
  end

  def current_settings
    ApplicationSetting.current_without_cache
  end
end
