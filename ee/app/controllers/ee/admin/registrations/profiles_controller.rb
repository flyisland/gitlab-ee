# frozen_string_literal: true

module EE
  module Admin
    module Registrations
      module ProfilesController
        extend ::Gitlab::Utils::Override

        override :new
        def new
          super

          return unless current_user.user_detail.onboarding_status_email_opt_in.nil?

          current_user.user_detail.onboarding_status_email_opt_in = true
        end

        private

        override :verify_available!
        def verify_available!
          return render_404 if ::Gitlab::Saas.feature_available?(:subscriptions_trials)

          super
        end

        override :user_detail_params_attributes
        def user_detail_params_attributes
          super + [:onboarding_status_country, :onboarding_status_email_opt_in]
        end
      end
    end
  end
end
