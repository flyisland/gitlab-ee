# frozen_string_literal: true

module Cd
  module DeployDrivers
    # Two layers: the whole document against the orchestration engine's schema, then
    # driver-owned parts against the driver's. The document layer runs first and stops the
    # pass, since a document the engine rejects has none of the shape the driver walk
    # assumes. Run at rollout start, so a driver rebinding cannot leave a stale config
    # undetected.
    class FlowDefinitionValidator
      def initialize(definition:, driver:)
        @definition = definition
        @driver = driver
      end

      def errors
        @errors ||= collect_errors
      end

      def valid?
        errors.empty?
      end

      private

      attr_reader :definition, :driver

      def collect_errors
        parsed = YAML.safe_load(definition)
        return [] if parsed.nil?

        document_errors = schema_errors(flow_definition_schemer, parsed, 'flow definition')
        return document_errors if document_errors.any?

        [*environment_service_errors(parsed), *step_errors(parsed)]
      rescue Psych::Exception
        # Cd::Rollouts::CreateService already raises on this, earlier.
        []
      end

      def environment_service_errors(parsed)
        parsed.fetch('environments', {}).flat_map do |environment_name, environment_config|
          next [] unless environment_config.is_a?(Hash)

          environment_config.fetch('services', {}).flat_map do |service_name, service_environment|
            schema_errors(application_environment_schemer, service_environment,
              "environment '#{environment_name}' service '#{service_name}'")
          end
        end
      end

      def step_errors(parsed)
        ::Cd::ApplicationFlowDefinitions::Document.new(parsed).driver_steps.flat_map do |step|
          schema_errors(steps_schemer, step, "step targeting environment '#{step['environment']}'")
        end
      end

      # Compiled once, not per step and per service.
      def flow_definition_schemer
        @flow_definition_schemer ||= JSONSchemer.schema(::Cd::DeployDrivers::Registry.orchestrator.flow_definition_schema)
      end

      def application_environment_schemer
        @application_environment_schemer ||= JSONSchemer.schema(driver.application_environment_schema)
      end

      def steps_schemer
        @steps_schemer ||= JSONSchemer.schema(driver.steps_schema)
      end

      def schema_errors(schemer, value, context)
        schemer.validate(value).map { |error| "#{context}: #{error['error']}" }
      end
    end
  end
end
