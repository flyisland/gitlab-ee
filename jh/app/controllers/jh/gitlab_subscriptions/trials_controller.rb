# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module TrialsController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      attr_accessor :result

      prepended do
        prepend_before_action :redirect_temp_email_user_to_profile, only: :new
      end

      private

      def redirect_temp_email_user_to_profile
        return unless ::Gitlab.com?
        return unless ::Feature.enabled?(:jh_redirect_trial_temp_email_to_profile, current_user)

        return unless user_with_temp_email?

        redirect_to user_settings_profile_path(redirected: true)
      end

      override :trial_success_path
      def trial_success_path(namespace)
        if discover_group_security_flow?
          group_security_dashboard_path(namespace)
        else
          # To override upstream ee/app/controllers/gitlab_subscriptions/trials_controller.rb#trial_success_path
          group_path(namespace)
        end
      end

      override :success_flash_message
      def success_flash_message
        if discover_group_security_flow?
          s_("BillingPlans|Congratulations, your free trial is activated.")
        else
          namespace = @result&.payload&.dig(:namespace)

          return super unless namespace&.gitlab_subscription

          safe_format(
            s_(
              "BillingPlans|You have successfully started a GitLab Ultimate trial that will " \
                "expire on %{exp_date}."
            ),
            exp_date: l(namespace.gitlab_subscription.reset.end_date.to_date, format: :long)
          )
        end
      end
    end
  end
end
