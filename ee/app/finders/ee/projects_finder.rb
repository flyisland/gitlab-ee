# frozen_string_literal: true

module EE
  # ProjectsFinder
  #
  # Extends ProjectsFinder
  #
  # Added arguments:
  #   params:
  #     plans: string[]
  #     feature_available: string[]
  #     aimed_for_deletion: Symbol
  #     include_hidden: boolean
  #     filter_expired_saml_session_projects: boolean
  #     active: boolean - Whether to include projects that are neither archived or marked for deletion.
  #     with_duo_eligible: boolean - Whether to include projects that are eligible for Duo features.
  #     duo_licensed_feature: String - Whether to include projects where the specified Duo feature is enabled.
  module ProjectsFinder
    include Gitlab::Auth::Saml::SsoSessionFilterable
    extend ::Gitlab::Utils::Override

    private

    override :filter_projects
    def filter_projects(collection)
      collection = super(collection)
      collection = by_plans(collection)
      collection = by_feature_available(collection)
      collection = by_hidden(collection)
      collection = by_duo_eligible(collection)
      collection = by_duo_licensed_feature(collection)
      by_saml_sso_session(collection)
    end

    def by_plans(collection)
      if names = params[:plans].presence
        collection.for_plan_name(names)
      else
        collection
      end
    end

    def by_feature_available(collection)
      if feature = params[:feature_available].presence
        collection.with_feature_available(feature)
      else
        collection
      end
    end

    def by_hidden(items)
      params[:include_hidden].present? ? items : items.not_hidden
    end

    def by_saml_sso_session(collection)
      filter_by_saml_sso_session(collection, :filter_expired_saml_session_projects)
    end

    def by_duo_eligible(items)
      return items unless ::Gitlab::Utils.to_boolean(params[:with_duo_eligible])

      namespaces_filter = ::Namespace.with_ai_supported_plan(:semantic_code_search)
      if ::Feature.disabled?(:semantic_code_search_saas_ga, :instance)
        namespaces_filter = namespaces_filter.namespace_settings_with_ai_features_enabled
      end

      items.with_duo_features_enabled.joins_namespace.merge(namespaces_filter)
    end

    def by_duo_licensed_feature(items)
      return items if params[:duo_licensed_feature].blank?

      feature = params[:duo_licensed_feature].to_sym

      items = filter_by_maintainer_access(items)

      if ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)
        filter_saas_duo_items(items, feature)
      else
        filter_self_managed_duo_items(items, feature)
      end
    end

    def filter_by_maintainer_access(items)
      return items.none unless current_user

      return items if current_user.can_read_all_resources?

      items.merge(current_user.authorized_projects(::Gitlab::Access::MAINTAINER))
    end

    def filter_saas_duo_items(items, feature)
      # SaaS: project toggle + namespace plan/credits check
      items
        .with_duo_features_enabled
        .joins_namespace
        .merge(::Namespace.with_ai_supported_plan(feature))
    end

    def filter_self_managed_duo_items(items, feature)
      # Self-Managed: instance-level license, no per-namespace filtering
      return items.none unless ::License.feature_available?(feature)

      items.with_duo_features_enabled
    end
  end
end
