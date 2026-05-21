# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin updates CI/CD settings', :with_current_organization, :request_store, :enable_admin_mode,
  feature_category: :pipeline_composition do
  include Features::SettingsHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:default_organization) { create(:organization) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    sign_in(admin)
    allow(License).to receive(:feature_available?).and_return(true)
    allow(Organizations::Organization).to receive(:default_organization).and_return(default_organization)
    visit ci_cd_admin_application_settings_path
  end

  describe 'CI/CD Catalog settings' do
    it 'changes CI/CD Catalog projects allowlist' do
      within_testid('catalog-settings') do
        fill_in 'application_setting_ci_cd_catalog_projects_allowlist_raw',
          with: "gitlab-org/project1\ngitlab-org/.*"
      end

      expect_save_settings('catalog-settings')

      expect(current_settings.ci_cd_catalog_projects_allowlist)
        .to match_array(['gitlab-org/project1', 'gitlab-org/.*'])
    end
  end

  describe 'package registry settings', feature_category: :package_registry do
    it 'allows you to change the maven_forwarding setting' do
      within_testid('forward-package-requests-form') do
        check 'Forward Maven package requests'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.maven_package_requests_forwarding).to be true
    end

    it 'allows you to change the maven_lock setting' do
      within_testid('forward-package-requests-form') do
        check 'Enforce Maven setting for all subgroups'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.lock_maven_package_requests_forwarding).to be true
    end

    it 'allows you to change the npm_forwarding setting' do
      within_testid('forward-package-requests-form') do
        check 'Forward npm package requests'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.npm_package_requests_forwarding).to be true
    end

    it 'allows you to change the npm_lock setting' do
      within_testid('forward-package-requests-form') do
        check 'Enforce npm setting for all subgroups'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.lock_npm_package_requests_forwarding).to be true
    end

    it 'allows you to change the pypi_forwarding setting' do
      within_testid('forward-package-requests-form') do
        check 'Forward PyPI package requests'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.pypi_package_requests_forwarding).to be true
    end

    it 'allows you to change the pypi_lock setting' do
      within_testid('forward-package-requests-form') do
        check 'Enforce PyPI setting for all subgroups'
      end

      expect_save_settings('forward-package-requests-form')

      expect(current_settings.lock_pypi_package_requests_forwarding).to be true
    end
  end

  context 'with virtual registries settings', feature_category: :virtual_registry do
    let(:dependency_proxy_feature_enabled) { true }

    before do
      stub_config(dependency_proxy: { enabled: dependency_proxy_feature_enabled })
      visit ci_cd_admin_application_settings_path
    end

    it 'allows you to change the virtual_registries_endpoints_api_limit setting' do
      within_testid('virtual-registries-form') do
        fill_in 'application_setting[virtual_registries_endpoints_api_limit]', with: 500
      end

      expect_save_settings('virtual-registries-form')

      expect(current_settings.virtual_registries_endpoints_api_limit).to be 500
    end

    context 'when dependency_proxy feature is disabled' do
      let(:dependency_proxy_feature_enabled) { false }

      it 'does not display the virtual registry settings' do
        expect(page).not_to have_selector('[data-testid="virtual-registries-form"]')
      end
    end
  end

  def current_settings
    ApplicationSetting.current_without_cache
  end
end
