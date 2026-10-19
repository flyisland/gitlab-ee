# frozen_string_literal: true

module JH
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Config
            module Content
              include ::Gitlab::Utils::StrongMemoize
              extend ::Gitlab::Utils::Override

              private

              override :pipeline_config
              def pipeline_config
                # rubocop:disable Gitlab/StrongMemoizeAttr -- Copy from Upstream
                # rubocop:disable Gitlab/ModuleWithInstanceVariables -- Copy from Upstream
                strong_memoize(:pipeline_config) do
                  ::Gitlab::Ci::ProjectConfig.new(
                    project: project, sha: @pipeline.sha,
                    custom_content: @command.content,
                    pipeline_source: @command.source, pipeline_source_bridge: @command.bridge,
                    triggered_for_branch: @pipeline.branch?,
                    ref: @pipeline.ref,
                    source_branch: @command.merge_request&.source_branch || @pipeline.ref,
                    pipeline_policy_context: @command.pipeline_policy_context,
                    inputs: @command.inputs,
                    ci_config_path: @command.ci_config_path
                  )
                end
                # rubocop:enable Gitlab/ModuleWithInstanceVariables -- Copy from Upstream
                # rubocop:enable Gitlab/StrongMemoizeAttr -- Copy from Upstream
              end
            end
          end
        end
      end
    end
  end
end
