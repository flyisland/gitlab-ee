# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin page', :js do
  let_it_be(:admin) { create(:admin) }

  shared_examples "renders I18n supported license name" do |license_code, license_name|
    let!(:license) { create(:license, plan: license_code) }

    before do
      sign_in(admin)
      enable_admin_mode!(admin)
      visit admin_root_path
    end

    it "renders current license name of #{license_code}" do
      page.within(find('.license-panel .gl-card-body strong', match: :first)) do
        expect(page).to have_content(license_name)
      end
    end
  end

  ::GitlabSubscriptions::Features.plan_names.each do |license_code, license_name|
    it_behaves_like "renders I18n supported license name", license_code, license_name
  end
end
