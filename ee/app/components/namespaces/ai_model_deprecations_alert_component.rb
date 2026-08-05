# frozen_string_literal: true

module Namespaces
  class AiModelDeprecationsAlertComponent < ViewComponent::Base
    def initialize(group: nil)
      @group = group
    end

    attr_reader :group

    def render?
      selected_deprecated_models.any?
    end

    private

    def model_selection_path
      if Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) && @group.present?
        group_settings_gitlab_duo_model_selection_index_path(@group)
      else
        admin_gitlab_duo_model_selection_index_path
      end
    end

    def selected_deprecated_models
      result = []

      feature_settings = if Gitlab::Saas.feature_available?(:gitlab_com_subscriptions) && @group.present?
                           ::Ai::ModelSelection::NamespaceFeatureSetting
                             .for_namespace(@group.id)
                             .non_default
                         else
                           ::Ai::ModelSelection::InstanceModelSelectionFeatureSetting
                             .non_default
                         end

      return [] if deprecated_models.blank?

      deprecated_models_by_id = deprecated_models.index_by { |model| model["identifier"] }
      return [] if deprecated_models_by_id.empty?

      feature_settings.each do |feature_setting|
        deprecated_model = deprecated_models_by_id[feature_setting.offered_model_ref]
        result << deprecated_model if deprecated_model.present? && result.exclude?(deprecated_model)
      end

      result
    end

    def deprecated_models
      @deprecated_models ||= fetch_deprecated_models
    end

    def fetch_deprecated_models
      catalog = ::Ai::ModelSelection::ModelDefinitions.fetch

      return [] unless catalog.success? && catalog.parser

      catalog.parser.deprecated_models
    end
  end
end
