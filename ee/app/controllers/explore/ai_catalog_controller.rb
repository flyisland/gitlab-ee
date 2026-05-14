# frozen_string_literal: true

module Explore
  class AiCatalogController < Explore::ApplicationController
    feature_category :workflow_catalog
    before_action :authenticate_user!
    before_action :authorize_read_ai_catalog!
    before_action :set_instance_beta_features_enabled
    before_action do
      push_frontend_feature_flag(:ai_catalog_third_party_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_create_third_party_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_flows, current_user)
      push_frontend_feature_flag(:ai_catalog_mcp_servers, current_user)
      push_frontend_feature_flag(:ai_catalog_synthetic_foundational_items, current_user)
      push_frontend_feature_flag(:mcp_catalog_agent_tools, current_user)
      push_frontend_ability(ability: :read_ai_catalog_mcp_server, resource: ::Current.organization, user: current_user)
      push_frontend_ability(ability: :create_ai_catalog_mcp_server, resource: ::Current.organization,
        user: current_user)
      push_frontend_ability(ability: :update_ai_catalog_mcp_server, resource: ::Current.organization,
        user: current_user)
    end

    private

    def authorize_read_ai_catalog!
      render_404 unless can?(current_user, :read_ai_catalog)
    end

    def set_instance_beta_features_enabled
      @instance_beta_features_enabled = ::Ai::Catalog.user_can_access_experimental_and_beta_features?(current_user)
    end
  end
end
