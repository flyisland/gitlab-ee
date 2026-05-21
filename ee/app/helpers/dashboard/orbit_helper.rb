# frozen_string_literal: true

module Dashboard
  module OrbitHelper
    def orbit_app_data
      data = {
        router_base: dashboard_orbit_path,
        agentic_chat_available: agentic_chat_available?
      }

      if admin_orbit_configure_available?
        data[:configure_mode] = 'admin'
        data[:admin_configuration_path] = admin_orbit_path
      elsif saas_orbit_configure_available?
        data[:configure_mode] = 'groups'
      end

      data
    end

    def orbit_page_label
      case params[:vueroute]
      when /\Aschema/ then _('Schema')
      else _('Explore')
      end
    end

    private

    def agentic_chat_available?
      return false unless current_user

      if ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
        current_user.allowed_to_use?(:duo_agent_platform)
      else
        ::Ai::DuoWorkflow.duo_agent_platform_available?(nil)
      end
    end

    def admin_orbit_configure_available?
      can?(current_user, :read_admin_knowledge_graph_settings)
    end

    def saas_orbit_configure_available?
      return false unless ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
      return false unless current_user.present?

      ::Feature.enabled?(:knowledge_graph, current_user)
    end
  end
end
