# frozen_string_literal: true

module JH
  module JsonSchemaValidator
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    override :schema
    def schema
      upstream_schema = super
      return upstream_schema unless base_directory == %w[app validators json_schemas ai_catalog] &&
        options[:filename] == 'third_party_flow_v1'

      JSONSchemer.schema(
        upstream_schema.value.deep_merge('properties' => {
          'useAgentConfigImage' => {
            'type' => 'boolean',
            'description' => 'Prefer the image in the project .gitlab/duo/agent-config.yml over the agent image.'
          }
        }),
        base_uri: upstream_schema.base_uri
      )
    end
    strong_memoize_attr :schema
  end
end
