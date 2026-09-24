# frozen_string_literal: true

require 'support/helpers/listbox_helpers'
require_relative '../../../../../ee/spec/support/helpers/subscription_portal_helpers'

module JH
  module Features
    module TrialHelpers
      include ListboxHelpers
      include SubscriptionPortalHelpers

      def expect_to_be_on_namespace_selection_with_errors
        expect_to_be_on_namespace_selection
        expect(page).to have_content('could not be created because our system did not respond successfully')
        expect(page).to have_content('Please reach out to GitLab Support for assistance')
        expect(page).to have_link('GitLab Support', href: 'https://support.gitlab.cn')
      end

      # def fill_in_trial_form_for_new_group(name: 'gitlab')
      #   fill_in 'new_group_name', with: name
      # end

      # def jh_expect_to_be_on_lead_form_with_errors
      #   expect(page).to have_content('could not be created because our system did not respond successfully')
      #   expect(page).to have_content('_lead_fail_')

      #   # This is needed to ensure the countries and regions selector has time to populate
      #   # This only happens on the duo trial and not the regular trial. Probably due to the added time for full page
      #   # to load with background on duo trial. However, this wait should be present anyway
      #    # to avoid possible flakiness.
      #   wait_for_all_requests
      # end

      # def form_data
      #   {
      #     phone_number: '+1 23 456-78-90',
      #     company_name: 'GitLab',
      #     country: { id: 'US', name: 'United States of America' },
      #     state: { id: 'CA', name: 'California' }
      #   }
      # end

      def form_data
        {
          company_name: 'GitLab',
          phone_number: '+1 23 456-78-90',
          country: { id: 'CN', name: 'China' }
          # state: { id: 'BJ', name: 'Beijing' }
        }
      end

      def fill_in_form_fields
        fill_in 'company_name', with: form_data[:company_name]
        fill_in 'phone_number', with: form_data[:phone_number]
      end

      def fill_in_form_fields_with_last_name(last_name)
        fill_in 'last_name', with: last_name
        fill_in_form_fields
      end

      def jh_fill_in_company_information
        fill_in 'company_name', with: form_data[:company_name]
        fill_in 'phone_number', with: form_data[:phone_number]
        select_from_listbox form_data.dig(:country, :name), from: 'country'
        # select_from_listbox form_data.dig(:state, :name), from: 'state'
      end

      def jh_fill_in_company_information_single_step
        fill_in 'company_name', with: form_data[:company_name]
        fill_in 'phone_number', with: form_data[:phone_number]
        select_from_listbox form_data.dig(:country, :name), from: 'Select a country or region'
        # select_from_listbox form_data.dig(:state, :name), from: 'Select state or province'
      end

      def jh_fill_in_company_information_with_last_name(last_name)
        fill_in 'last_name', with: last_name
        jh_fill_in_company_information
      end

      def jh_fill_in_company_information_single_step_with_last_name(last_name)
        fill_in 'last_name', with: last_name
        jh_fill_in_company_information_single_step
      end

      # def expect_to_be_on_namespace_creation
      #   expect(page).to have_content('New group name')
      #   expect(page).not_to have_content('This trial is for')
      # end

      # def expect_to_be_on_namespace_creation_without_company_question
      #   expect(page).to have_content('New group name')
      #   expect(page).not_to have_content('This trial is for')
      # end

      def expect_to_be_on_namespace_selection
        expect(page).to have_content('This trial is for')
      end

      def submit_single_namespace_trial_company_form(**kwargs)
        submit_trial_form(**kwargs, button_text: 'Activate my trial')
      end

      def expect_to_be_on_group_page(path: 'gitlab', name: 'gitlab')
        expect(page).to have_current_path("/#{path}")
        within_testid('super-sidebar') do
          expect(page).to have_selector('a[aria-current="page"]', text: name)
        end
      end

      # upstream: ee/spec/support/helpers/features/trial_helpers.rb
      def jh_expect_lead_submission(lead_result, glm:, last_name: user.last_name)
        premium = defined?(group) && group.premium_plan?

        trial_user_params = {
          company_name: form_data[:company_name],
          first_name: user.first_name,
          last_name: last_name,
          phone_number: form_data[:phone_number],
          country: form_data.dig(:country, :id),
          work_email: user.email,
          uid: user.id,
          namespace_id: kind_of(Integer),
          trial_type: premium ? ::GitlabSubscriptions::Trials::PREMIUM_TRIAL_TYPE_V2 : ::GitlabSubscriptions::Trials::FREE_TRIAL_TYPE_V2,
          setup_for_company: user.onboarding_status_setup_for_company,
          skip_email_confirmation: true,
          existing_plan: defined?(group) ? group.actual_plan_name : 'free',
          gitlab_com_trial: true,
          provider: 'gitlab'
          # state: form_data.dig(:state, :id)
        }.merge(glm)

        expect_next_instance_of(::GitlabSubscriptions::CreateLeadService) do |service|
          expect(service).to receive(:execute).with({ trial_user: trial_user_params }).and_return(lead_result)
        end
      end
    end
  end
end
