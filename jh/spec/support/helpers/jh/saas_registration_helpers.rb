# frozen_string_literal: true

module JH
  module SaasRegistrationHelpers
    extend ::Gitlab::Utils::Override

    override :user_signs_up_with_sso
    def user_signs_up_with_sso(params = {}, provider: 'gitlab', name: 'Registering User')
      # Google OAuth is not configured in the JH test environment.
      provider = 'gitlab' if provider == 'google_oauth2'
      stub_application_setting(
        arkose_labs_public_api_key: 'public_key',
        arkose_labs_private_api_key: 'private_key'
      )

      super(params, provider: provider, name: name) # rubocop:disable Style/SuperArguments -- Forward JH defaults.
    end

    override :user_signs_up_through_trial_with_sso
    def user_signs_up_through_trial_with_sso(params = {}, provider: 'gitlab', name: 'Registering User')
      super(params, provider: provider, name: name) # rubocop:disable Style/SuperArguments -- Forward JH defaults.
    end

    override :user_signs_up_through_subscription_with_sso
    def user_signs_up_through_subscription_with_sso(provider: 'gitlab')
      super(provider: provider) # rubocop:disable Style/SuperArguments -- Forward the JH default.
    end

    override :fill_in_checkout_form
    def fill_in_checkout_form(has_billing_account: false)
      subscription_portal_url = ::Gitlab::Routing.url_helpers.subscription_portal_url

      stub_request(:get, "#{subscription_portal_url}/payment_forms/paid_signup_flow")
        .with(
          headers: {
            'Accept' => 'application/json',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Ruby',
            'X-Admin-Email' => 'gl_com_api@gitlab.com',
            'X-Admin-Token' => 'customer_admin_token'
          })
        .to_return(status: 200, body: "", headers: {})

      if user.onboarding_status_setup_for_company
        within_fieldset('Name of company or organization using GitLab') do
          fill_in with: 'Test company'
        end
      end

      click_button 'Continue to billing'

      unless has_billing_account
        within_fieldset('Country') do
          select 'United States of America'
        end

        within_fieldset('Street address') do
          first("input[type='text']").fill_in with: '123 fake street'
        end

        # SKIP on JH Side
        # within_fieldset('City') do
        #   fill_in with: 'Fake city'
        # end

        within_fieldset('State') do
          select 'Florida'
        end

        # within_fieldset('Zip code') do
        #   fill_in with: 'A1B 2C3'
        # end
      end

      click_button 'Continue to payment'

      stub_confirm_purchase
    end

    override :stub_confirm_purchase
    def stub_confirm_purchase
      allow_next_instance_of(::GitlabSubscriptions::CreateService) do |instance|
        allow(instance).to receive(:execute).and_return({ success: true, data: nil })
      end

      expect(::GitlabSubscriptions::CreateService).to receive(:new).with(
        user,
        group: an_instance_of(::Group),
        customer_params: customer_params,
        subscription_params: subscription_params,
        idempotency_key: a_string_matching(/[0-9a-fA-F-]{36}/) # UUID
      )

      # this is an ad-hoc solution to skip the zuora step and allow 'confirm purchase' button to show up
      page.execute_script <<~JS
        document.querySelector('[data-testid="subscription_app"]').__vue__.$store.dispatch('fetchPaymentMethodDetailsSuccess')
      JS

      accept_privacy_and_terms

      click_button 'Confirm purchase'
    end

    override :customer_params
    def customer_params
      company = user.onboarding_status_setup_for_company ? 'Test company' : nil

      ActionController::Parameters.new(
        country: 'US',
        address_1: '123 fake street',
        address_2: nil,
        city: nil,
        state: 'FL',
        zip_code: nil,
        company: company
      ).permit!
    end

    def jh_fill_in_company_form(with_last_name: false, success: true)
      result = if success
                 ServiceResponse.success
               else
                 ServiceResponse.error(message: '_company_lead_fail_')
               end

      expect(::GitlabSubscriptions::CreateCompanyLeadService).to receive(:new).with(
        user: user,
        params: jh_company_params(user)
      ).and_return(instance_double(::GitlabSubscriptions::CreateCompanyLeadService, execute: result))

      fill_in_company_user_last_name if with_last_name
      jh_fill_company_form_fields
    end

    def jh_company_params(user)
      ActionController::Parameters.new(
        company_name: 'Test Company',
        # company_size: '1-99',
        first_name: user.first_name,
        last_name: 'User',
        phone_number: '+1234567890',
        country: 'CN',
        state: 'BJ',
        # website_url: 'https://gitlab.com',
        # these are the passed through params
        # registration_objective: 'other',
        jobs_to_be_done_other: 'My reason'
      ).permit!
    end

    def jh_fill_company_form_fields
      fill_in 'company_name', with: 'Test Company'
      fill_in 'phone_number', with: '+1234567890'
    end
  end
end
