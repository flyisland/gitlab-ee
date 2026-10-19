# frozen_string_literal: true

module JH
  module SaasRegistrationHelpers
    extend ::Gitlab::Utils::Override

    override :user_signs_up
    def user_signs_up(params = {}, password: User.random_password)
      new_user = build(:user, name: 'Registering User', email: user_email, password: password)

      visit new_user_registration_path(params)

      fill_in_jh_sign_up_form(new_user)
    end

    # override :user_signs_up_through_trial_registration
    # def user_signs_up_through_trial_registration
    #   new_user = build(:user, name: 'Registering User', email: user_email)

    #   perform_enqueued_jobs do
    #     fill_in_jh_sign_up_form(new_user)
    #   end
    # end

    private

    # Copy from spec/support/helpers/sign_up_helpers.rb#fill_in_sign_up_form
    def jh_fill_in_sign_up_form(new_user, invite: false)
      fill_in 'new_user_first_name', with: new_user.first_name
      fill_in 'new_user_last_name', with: new_user.last_name
      fill_in 'new_user_username', with: new_user.username
      fill_in 'new_user_email', with: new_user.email unless invite
      fill_in 'new_user_password', with: new_user.password

      expect_username_to_be_validated

      # JH accept terms
      terms_checkbox = find("input[data-testid='new-user-terms-accepted']")
      terms_checkbox.set(true)

      yield if block_given?

      click_button _('Continue')
    end

    # For https://jihulab.com/gitlab-cn/gitlab/-/issues/3622
    # This method is meant to replace spec/support/helpers/sign_up_helpers.rb#fill_in_sign_up_form
    # Since there were no prepend_mod existing for this module, so the method is moved here.
    # Consider adding a prepend_mod to this module if more methods are added.
    def fill_in_jh_sign_up_form(new_user, submit_button_text = 'Continue')
      fill_in 'new_user_first_name', with: new_user.first_name
      fill_in 'new_user_last_name', with: new_user.last_name

      fill_in 'new_user_username', with: new_user.username
      fill_in 'new_user_email', with: new_user.email
      fill_in 'new_user_password', with: new_user.password

      terms_checkbox = find("input[data-testid='new-user-terms-accepted']")
      terms_checkbox.set(true)

      expect_username_to_be_validated

      yield if block_given?

      click_button submit_button_text
    end
  end
end
