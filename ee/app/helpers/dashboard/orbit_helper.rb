# frozen_string_literal: true

module Dashboard
  module OrbitHelper
    def orbit_app_data
      gql_queries_enabled = ::Analytics::KnowledgeGraph.gql_enabled_for?(current_user)
      duo_accessible = duo_accessible?

      data = {
        router_base: dashboard_orbit_path,
        gql_queries_enabled: gql_queries_enabled.to_s,
        duo_accessible: duo_accessible.to_s,
        can_ask_duo_for_queries: (duo_accessible && gql_queries_enabled).to_s,
        orbit_settings_enabled: orbit_settings_enabled?.to_s,
        trial_available: orbit_trial_available?.to_s,
        default_group_missing: orbit_default_group_missing?.to_s,
        preferences_path: profile_preferences_path(anchor: 'orbit-default-group')
      }

      data[:admin_configuration_path] = admin_orbit_path if admin_orbit_configure_available?

      data
    end

    private

    # SaaS only. `read_orbit_trial` applies the per-group `orbit_trial` flag on Group.orbitTrial.
    def orbit_trial_available?
      current_user.present? && ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
    end

    # True only when the user must pick a governing group. `with_fallback` is nil for 0 or 2+
    # candidates, and the ability needs SaaS, billing, and candidates, so together they mean
    # "2+ candidates, none chosen". Off SaaS the ability is false.
    def orbit_default_group_missing?
      return false unless current_user

      can?(current_user, :update_governing_knowledge_graph_namespace) &&
        current_user.user_preference.knowledge_graph_governing_namespace_with_fallback.nil?
    end

    # Can the user reach Duo at all from this dashboard? Independent of
    # whether Orbit is enabled in Duo (that's `orbit_settings_enabled?`).
    # The dashboard sits outside any group scope, so Duo access must
    # resolve against the user's default namespace rather than a
    # surrounding subject.
    def duo_accessible?
      return false unless current_user

      namespace = current_user.user_preference.duo_default_namespace_with_fallback
      return false unless namespace

      current_user.can?(:access_duo_features, namespace) &&
        current_user.can?(:access_duo_entry_point)
    end

    def orbit_settings_enabled?
      ::Ai::Orbit::Settings.orbit_in_duo_on?(current_user)
    end

    def admin_orbit_configure_available?
      can?(current_user, :read_knowledge_graph_setting)
    end
  end
end
