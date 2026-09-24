# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "What's new placement experiment", :js,
  feature_category: :onboarding do
  let_it_be(:user) { create(:user) }

  before do
    stub_experiments(whats_new_placement: variant.to_sym)
    sign_in(user)
    visit root_path
  end

  shared_examples 'tracking the placement funnel' do
    it 'emits every event the journey declares for its variant', :capture_snowplow_events do
      find_by_testid(menu_toggle_testid).click

      expect(page).to have_testid(menu_item_testid)

      find_by_testid(menu_item_testid).click

      expect_snowplow_tracking_journey('whats_new_placement', variant: variant)
    end
  end

  context 'when assigned the candidate variant' do
    let(:variant) { 'candidate' }
    let(:menu_toggle_testid) { 'user-menu-toggle' }
    let(:menu_item_testid) { 'whats-new-for-you-profile-menu-item' }

    it_behaves_like 'tracking the placement funnel'

    it 'does not offer the item in the help menu' do
      find_by_testid('sidebar-help-button').click

      expect(page).to have_testid('disclosure-content')

      expect(page).to have_no_testid('whats-new-for-you-help-menu-item')
    end
  end

  context 'when assigned the control variant' do
    let(:variant) { 'control' }
    let(:menu_toggle_testid) { 'sidebar-help-button' }
    let(:menu_item_testid) { 'whats-new-for-you-help-menu-item' }

    it_behaves_like 'tracking the placement funnel'

    it 'does not offer the item in the profile menu' do
      find_by_testid('user-menu-toggle').click

      expect(page).to have_testid('edit-profile-item')

      expect(page).to have_no_testid('whats-new-for-you-profile-menu-item')
    end
  end
end
