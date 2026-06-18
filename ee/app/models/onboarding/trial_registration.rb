# frozen_string_literal: true

module Onboarding
  class TrialRegistration
    extend IdentityVerificationPanelDefaults

    PRODUCT_INTERACTION = 'SaaS Trial'
    private_constant :PRODUCT_INTERACTION
    TRACKING_LABEL = 'trial_registration'
    private_constant :TRACKING_LABEL

    # string methods

    def self.tracking_label
      TRACKING_LABEL
    end

    def self.event_label
      nil
    end

    def self.account_created_product_interaction
      nil
    end

    def self.product_interaction
      PRODUCT_INTERACTION
    end

    # internalization methods

    def self.welcome_submit_button_text
      _('Continue')
    end

    def self.setup_for_company_label_text
      _('Who will be using this GitLab trial?')
    end

    def self.setup_for_company_help_text
      nil
    end

    def self.get_started_subtext
      format(
        s_(
          "InProductMarketing|Start your free %{duration} day trial today, no credit card required. " \
            "You'll have full access to our most advanced features, including GitLab Duo Agent Platform."
        ),
        # rubocop:disable CodeReuse/ServiceClass -- PORO, not an AR model; reuses the canonical trial duration service
        duration: ::GitlabSubscriptions::TrialDurationService.new.execute
        # rubocop:enable CodeReuse/ServiceClass
      )
    end

    # predicate methods

    def self.show_company_form_footer?
      false
    end

    def self.show_company_form_side_column?
      false
    end

    def self.learn_gitlab_redesign?
      true
    end

    def self.redirect_to_company_form?
      true
    end

    def self.eligible_for_iterable_trigger?
      false
    end

    def self.continue_full_onboarding?
      true
    end

    def self.convert_to_automatic_trial?
      false
    end

    def self.show_joining_project?
      false
    end

    def self.apply_trial?
      true
    end

    def self.read_from_stored_user_location?
      false
    end

    def self.preserve_stored_location?
      false
    end

    def self.unification_enabled?
      ::Onboarding.enabled? && ::Feature.enabled?(:trial_unification, :instance)
    end

    def self.redirect_to_customers_portal?
      false
    end
  end
end
