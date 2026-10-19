# frozen_string_literal: true

require 'spec_helper'

# Test profile with phone_verification
# Refs:
# - spec/features/uploads/user_uploads_avatar_to_profile_spec.rb
# - spec/features/profiles/user_edit_profile_spec.rb
RSpec.describe 'Profile account page with phone verification',
  :js, :saas, :phone_verification_code_enabled, :with_current_organization,
  feature_category: :user_profile do
  include RandomNumberString

  let_it_be(:avatar_file_path) { Rails.root.join("spec/fixtures/dk.png") }
  let_it_be(:raw_phone) { "+86136#{random_number_string(11 - 3)}" }
  let_it_be(:encrypted_phone) { ::Gitlab::CryptoHelper.aes256_gcm_encrypt(raw_phone) }
  let(:user) { create(:user, :with_namespace, phone: encrypted_phone) }

  before do
    stub_feature_flags(edit_user_profile_vue: false)

    sign_in user
    visit user_settings_profile_path
  end

  it 'their new avatar is immediately visible in the header and setting sidebar' do
    find('.js-user-avatar-input', visible: false).set(avatar_file_path)

    click_button 'Set new profile picture'
    click_button 'Update profile settings'

    within_testid('user-dropdown') do
      expect(page).to have_css('.gl-avatar[src^="blob:"]')
    end
  end

  it 'changes user profile' do
    fill_in 'user_linkedin', with: 'testlinkedin'
    fill_in 'user_twitter', with: 'testtwitter'
    fill_in 'user_website_url', with: 'http://testurl.com'
    fill_in 'user_location', with: 'Ukraine'
    fill_in 'user_bio', with: 'I <3 GitLab :tada:'
    fill_in 'user_job_title', with: 'Frontend Engineer'
    fill_in 'user_company', with: 'GitLab'

    click_button 'Update profile settings'

    expect(page).to have_content('Profile was successfully updated')

    expect(user.reset).to have_attributes(
      linkedin: 'testlinkedin',
      twitter: 'testtwitter',
      website_url: 'http://testurl.com',
      bio: 'I <3 GitLab :tada:',
      job_title: 'Frontend Engineer'
    )

    expect(find('#user_location').value).to eq 'Ukraine'
  end
end
