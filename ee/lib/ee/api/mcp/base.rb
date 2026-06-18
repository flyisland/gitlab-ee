# frozen_string_literal: true

module EE
  module API
    module Mcp
      module Base
        extend ActiveSupport::Concern

        prepended do
          helpers do
            extend ::Gitlab::Utils::Override

            override :feature_available?
            def feature_available?
              # On SaaS the instance setting does not gate access; the namespace-level
              # check below is the authority. Skip CE's super on the SaaS path.
              return false unless saas? || super
              return false unless instance_allows_experiment_and_beta_features
              return false unless gitlab_com_namespace_enables_experiment_and_beta_features

              true
            end

            def instance_allows_experiment_and_beta_features
              return true if saas?
              return true if ::Feature.enabled?(:mcp_server_availability_setting, :instance)

              ::Gitlab::CurrentSettings.duo_features_enabled? &&
                ::Gitlab::CurrentSettings.instance_level_ai_beta_features_enabled?
            end

            def gitlab_com_namespace_enables_experiment_and_beta_features
              # namespace-level settings check is only relevant for .com
              return true unless saas?

              current_user.any_group_with_mcp_server_enabled?
            end

            def saas?
              ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)
            end
          end
        end
      end
    end
  end
end
