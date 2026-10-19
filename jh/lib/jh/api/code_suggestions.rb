# frozen_string_literal: true

module JH
  module API
    module CodeSuggestions
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          override :code_suggestions_disallowed?
          def code_suggestions_disallowed?(project_path)
            return super unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
            return super unless ::Feature.enabled?(:jh_saas_enable_billing_code_suggestions)

            credit_check_response = ::Ai::UsageQuotaService.new(
              user: current_user,
              namespace: project_path.present? ? project(project_path)&.namespace : nil
            ).execute

            if credit_check_response.error?
              ::Gitlab::AppLogger.info(
                message: 'JH code suggestions credit check',
                class: 'JH::API::CodeSuggestions',
                reason: credit_check_response.reason,
                user_id: current_user.id,
                project_path: project_path
              )
              return true
            end

            super
          end
        end
      end
    end
  end
end
