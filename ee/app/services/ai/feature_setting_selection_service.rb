# frozen_string_literal: true

module Ai
  class FeatureSettingSelectionService
    MISSING_DEFAULT_NAMESPACE = "missing_default_namespace"

    def initialize(current_user, feature, root_namespace)
      @current_user = current_user
      @feature = feature
      @root_namespace = root_namespace
    end

    def execute
      return success(payload: nil) if ::Ai::AmazonQ.connected?
      return select_for_saas if ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)

      select_for_self_managed
    end

    private

    attr_reader :current_user, :feature, :root_namespace

    def select_for_saas
      feature_setting = model_selection_namespace_setting

      return success(payload: feature_setting) if feature_setting
      return error_missing_default_namespace if default_duo_namespace_required?

      success(payload: nil)
    end

    def select_for_self_managed
      # First check if a self-hosted model is defined for the feature
      feature_setting = self_hosted_feature_setting

      return success(payload: feature_setting) if prefer_self_hosted_feature_setting?(feature_setting)

      instance_setting = instance_level_setting

      # When a Self-hosted AI Gateway has been configured (for the instance), then we don't default to vendored
      # vendored becomes the default only on pure cloud-connected SM/dedicated instances. The same for offline
      # cloud license, since there's no connection to vendored models
      return success(payload: nil) if suppress_default_vendored_setting?(instance_setting)

      # Instance level is fetched either when we don't have a feature_setting, or when it is set to vendored
      success(payload: instance_setting)
    end

    def suppress_default_vendored_setting?(instance_setting)
      ::License.current&.offline_cloud_license? ||
        (instance_setting.set_to_gitlab_default? && Gitlab::AiGateway.has_self_hosted_ai_gateway?)
    end

    def prefer_self_hosted_feature_setting?(feature_setting)
      feature_setting && !feature_setting.vendored?
    end

    def model_selection_namespace_setting
      namespace = model_selection_namespace

      return if namespace.nil?

      ::Ai::ModelSelection::NamespaceFeatureSetting.find_or_initialize_by_feature(namespace, feature)
    end

    def model_selection_namespace
      current_user.governing_namespace(root_namespace)
    end

    def instance_level_setting
      ::Ai::ModelSelection::InstanceModelSelectionFeatureSetting.find_or_initialize_by_feature(feature)
    end

    def self_hosted_feature_setting
      ::Ai::FeatureSetting.find_by_feature(feature)
    end

    def default_duo_namespace
      current_user.user_preference.duo_default_namespace_with_fallback
    end

    def default_duo_namespace_required?
      # we need to return the default namespace only when there is multiple seats assigned to the user.
      # Otherwise, we might have error in undesirable cases
      # e.g. when self-hosted feature setting are not correctly set
      return false if default_duo_namespace

      # if any of the assigned seat has a namespace with model switching enable
      # it is required for the user to have a default namespace to be selected.
      # This logic is in EE::GlobalPolicy#can_assign_default_duo_group?
      Ability.allowed?(current_user, :assign_default_duo_group)
    end

    def success(payload:)
      ServiceResponse.success(payload: payload)
    end

    def error_missing_default_namespace
      ServiceResponse.error(payload: nil, message: MISSING_DEFAULT_NAMESPACE)
    end
  end
end
