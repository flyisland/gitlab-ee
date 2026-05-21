# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Standard flow for user picking just me and joining a project', :js, :saas_registration, :with_current_organization, feature_category: :onboarding do
  where(:case_name, :sign_up_method) do
    [
      ['with regular sign up', -> { regular_sign_up }],
      ['with sso sign up', -> { sso_sign_up }]
    ]
  end

  with_them do
    it 'registers the user and sends them to a project listing page' do
      sign_up_method.call

      expect_to_see_welcome_form

      fills_in_welcome_form
      click_on 'Continue'

      expect_to_be_on_projects_dashboard_with_zero_authorized_projects
    end
  end

  context 'when trial_first_registration experiment is control', experiment_tracking: 2 do
    it 'goes through the experiment standard registration flow' do
      allow(Gitlab::Experiment::Configuration).to receive(:cache).and_call_original
      stub_feature_flags(trial_first_registration: true)
      allow(Feature).to receive(:enabled?).and_call_original
      allow(Feature)
        .to receive(:enabled?).with('trial_first_registration', anything, type: :experiment).and_return(false)

      visit new_user_session_path

      click_on 'Register now'

      expect_to_be_on_standard_user_registration

      user_signs_up_through_registration

      expect_to_see_account_confirmation_page

      confirm_account

      expect_to_see_welcome_form

      fills_in_welcome_form
      click_on 'Continue'

      expect_to_be_on_projects_dashboard_with_zero_authorized_projects

      is_expected.to have_tracked_experiment(:trial_first_registration, [
        :render_signup,
        :assignment,
        :created_user,
        :render_verification
      ])
    end
  end

  def fills_in_welcome_form
    select 'Software Developer', from: 'user_onboarding_status_role'
    select 'A different reason', from: 'user_onboarding_status_registration_objective'
    fill_in 'Why are you signing up? (optional)', with: 'My reason'

    choose 'Just me'
    choose 'Join an existing project'
  end

  def expect_to_see_welcome_form
    expect(page).to have_content('Welcome to GitLab, Registering!')

    page.within(welcome_form_selector) do
      expect(page).to have_content('Role')
      expect(page).to have_field('user_onboarding_status_role', valid: false)
      expect(page).to have_field('user_onboarding_status_setup_for_company_true', valid: false)
      expect(page).to have_content('I\'m signing up for GitLab because:')
      expect(page).to have_content('Who will be using GitLab?')
      expect(page)
        .to have_content(_(
          'Try GitLab Ultimate for free and automate tasks with GitLab Duo Agent Platform ' \
            'when you create a new project.'
        ))
      expect(page).to have_content('What would you like to do?')
    end
  end
end
