# frozen_string_literal: true

module Ai
  module ModelSelection
    class BaseUpdateAllowlistService
      def initialize(user, feature:, enabled:, model_refs:)
        @user = user
        @feature = feature
        @enabled = enabled
        @model_refs = model_refs
      end

      def execute
        return feature_not_supported_error(feature_setting) unless feature_setting.model_allowlist_supported?

        fetch_model_definition = ::Ai::ModelSelection::FetchModelDefinitionsService
                                   .new(user, model_selection_scope: model_selection_scope)
                                   .execute

        return ServiceResponse.error(message: fetch_model_definition.message) if fetch_model_definition.error?

        model_definition_parser = ::Gitlab::Ai::ModelSelection::ModelDefinitionResponseParser
                                     .new(fetch_model_definition.payload)

        normalized_refs = feature_setting.normalize_allowlist_model_refs(
          model_refs,
          enabled: enabled,
          model_definition_parser: model_definition_parser
        )

        update_params = {
          model_allowlist_enabled: enabled,
          model_allowlist_gitlab_model_refs: normalized_refs,
          model_definitions: fetch_model_definition.payload
        }

        if feature_setting.update(update_params)
          ServiceResponse.success(payload: feature_setting)
        else
          ServiceResponse.error(payload: feature_setting, message: feature_setting.errors.full_messages.join(", "))
        end
      end

      private

      attr_reader :user, :feature, :enabled, :model_refs

      def feature_setting
        raise ::Gitlab::AbstractMethodError
      end

      def model_selection_scope
        raise ::Gitlab::AbstractMethodError
      end

      def feature_not_supported_error(setting)
        ServiceResponse.error(
          payload: setting,
          message: format(
            _("Model allowlists are not supported for the feature '%{feature}'."),
            feature: feature
          )
        )
      end
    end
  end
end
