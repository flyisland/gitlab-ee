# frozen_string_literal: true

module JH
  module Ai
    module FlowTriggers
      module RunService
        extend ::Gitlab::Utils::Override

        private

        override :execute_workload
        def execute_workload(flow_definition, params, ref)
          return super unless flow_definition['useAgentConfigImage'] == true

          config = ::Gitlab::DuoAgentPlatform::Config.new(project)
          if config.config_present? && !config.valid_format?
            config_file = ::Gitlab::DuoAgentPlatform::Config::CONFIG_FILE_NAME
            errors = config.validation_errors.join('; ').first(2000)
            return ServiceResponse.error(
              message: "Invalid config file #{config_file} -> #{errors}",
              reason: :unprocessable_entity)
          end

          image = config.default_image.presence || flow_definition['image']
          super(flow_definition.merge('image' => image), params, ref)
        end

        override :build_variables
        def build_variables(params)
          variables = super
          return variables unless params.key?(:token)

          variables[:AI_GATEWAY_BASE_URL] = "#{::Gitlab::AiGateway.url}/v1/proxy/openai/v1"

          model_ref = external_agent_model_ref
          variables[:AI_FLOW_MODEL_REF] = model_ref if model_ref.present?

          variables
        end

        def external_agent_model_ref
          selection = ::Ai::FeatureSettingSelectionService.new(
            sa_or_human_user, :duo_agent_platform, project.root_ancestor
          ).execute
          return unless selection.success?

          setting = selection.payload
          return if setting.nil? || setting.disabled? || setting.self_hosted?
          return setting.offered_model_ref if setting.offered_model_ref.present?

          ::Ai::ModelSelection::ModelDefinitions.fetch(sa_or_human_user)
            .parser&.default_model_ref_for_feature(:duo_agent_platform)
        end
      end
    end
  end
end
