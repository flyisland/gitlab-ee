# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class WorkflowContextGenerationService
      include ::Gitlab::Utils::StrongMemoize

      AI_WORKFLOWS_SCOPES = (::Gitlab::Auth::AI_WORKFLOW_SCOPES + [::Gitlab::Auth::MCP_SCOPE]).to_set.freeze

      def initialize(current_user:, organization:, workflow_definition: nil, container: nil, service_account: nil)
        @current_user = current_user
        @container = container
        @organization = organization
        @service_account = service_account
        @workflow_definition = workflow_definition
      end

      def generate_oauth_token
        ::Ai::DuoWorkflows::CreateOauthAccessTokenService.new(
          current_user: current_user,
          organization: organization,
          workflow_definition: workflow_definition
        ).execute
      end

      def generate_composite_oauth_token
        ::Ai::DuoWorkflows::CreateCompositeOauthAccessTokenService.new(
          current_user: current_user,
          organization: organization,
          service_account: service_account,
          container: container
        ).execute
      end

      def generate_workflow_token
        feature_setting = duo_agent_platform_feature_setting

        ::Ai::DuoWorkflow::DuoWorkflowService::Client.new(
          duo_workflow_service_url: Gitlab::DuoWorkflow::Client.url_for(
            feature_setting: feature_setting,
            user: current_user
          ),
          current_user: current_user,
          secure: Gitlab::DuoWorkflow::Client.secure?(feature_setting: feature_setting)
        ).generate_token
      end

      def generate_oauth_token_with_composite_identity_support
        if composite_identity_enabled?
          generate_composite_oauth_token
        else
          generate_oauth_token
        end
      end

      # Returns true when the given access_token already carries all required AI workflow
      # scopes, so a new OAuth token does not need to be created for this request.
      def already_scoped_for_ai_workflows?(access_token)
        return false unless access_token&.scopes

        token_scopes = access_token.scopes.map(&:to_sym).to_set

        expected_scopes = if composite_identity_enabled?
                            (AI_WORKFLOWS_SCOPES + [:"user:#{current_user.id}"]).to_set
                          else
                            AI_WORKFLOWS_SCOPES
                          end

        token_scopes == expected_scopes
      end

      def duo_agent_platform_feature_setting
        ::Ai::FeatureSettingSelectionService
          .new(current_user, ai_feature, container&.root_ancestor)
          .execute.payload
      end
      strong_memoize_attr :duo_agent_platform_feature_setting

      private

      attr_reader :current_user, :container, :organization, :workflow_definition, :service_account

      def composite_identity_enabled?
        @service_account&.composite_identity_enforced && Feature.enabled?(:duo_workflow_use_composite_identity,
          current_user)
      end

      def ai_feature
        code_review_v1 = ::Ai::Catalog::FoundationalFlow['code_review/v1'].foundational_flow_reference
        sast_fp_detection_v1 = ::Ai::Catalog::FoundationalFlow['sast_fp_detection/v1'].foundational_flow_reference
        secrets_fp_detection_v1 = ::Ai::Catalog::FoundationalFlow['secrets_fp_detection/v1'].foundational_flow_reference
        resolve_sast_vuln_v1 =
          ::Ai::Catalog::FoundationalFlow['resolve_sast_vulnerability/v1'].foundational_flow_reference

        return :review_merge_request if workflow_definition == code_review_v1
        return :sast_vulnerability_fp_detection if workflow_definition == sast_fp_detection_v1
        return :secret_vulnerability_fp_detection if workflow_definition == secrets_fp_detection_v1
        return :sast_vulnerability_resolution if workflow_definition == resolve_sast_vuln_v1

        :duo_agent_platform
      end
    end
  end
end
