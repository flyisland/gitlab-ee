# frozen_string_literal: true

module JH
  module Gitlab
    module Ci
      module ProjectConfig
        extend ::Gitlab::Utils::Override

        attr_reader :ci_config_path

        override :initialize
        def initialize(ci_config_path: nil, scan_profile_context: nil, **options)
          @ci_config_path = ci_config_path
          unless ci_config_path
            super(**options, scan_profile_context: scan_profile_context)
            return
          end

          project, sha, custom_content, pipeline_source, pipeline_source_bridge, triggered_for_branch,
          ref, pipeline_policy_context, inputs = options.values_at(
            :project, :sha, :custom_content, :pipeline_source,
            :pipeline_source_bridge, :triggered_for_branch, :ref, :pipeline_policy_context, :inputs)

          @config = nil

          unless pipeline_policy_context&.pipeline_execution_context&.applying_config_override?
            @config = find_source(project: project,
              sha: sha,
              custom_content: custom_content,
              pipeline_source: pipeline_source,
              pipeline_source_bridge: pipeline_source_bridge,
              triggered_for_branch: triggered_for_branch,
              ref: ref,
              inputs: inputs,
              scan_profile_context: scan_profile_context,
              ci_config_path: ci_config_path
            )

            return if @config
          end

          fallback_config = ::Gitlab::Ci::ProjectConfig::FALLBACK_POLICY_SOURCE.new(
            project: project,
            pipeline_source: pipeline_source,
            triggered_for_branch: triggered_for_branch,
            ref: ref,
            source_branch: source_branch,
            pipeline_policy_context: pipeline_policy_context,
            ci_config_path: ci_config_path,
            scan_profile_eligibility_service: scan_profile_eligibility_service
          )

          @config = fallback_config if fallback_config.exists?
        end

        private

        override :find_source
        def find_source(**args)
          super(**args, ci_config_path: ci_config_path)
        end
      end
    end
  end
end
