# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Config
        module External
          module File
            module Project
              extend ::Gitlab::Utils::Override

              private

              override :project_access_allowed?
              def project_access_allowed?(user, project)
                super ||
                  security_policy_management_project_access_allowed?(project) ||
                  pipeline_execution_policy_bot_file_access_allowed?(project)
              end

              def security_policy_management_project_access_allowed?(project)
                context.logger.instrument(:config_file_project_validate_access_policy) do
                  next false unless policy_management_project_access_allowed?
                  next false unless context.project.affected_by_security_policy_management_project?(project)

                  spp_allows_pipeline_access?(project)
                end
              end

              def spp_allows_pipeline_access?(project)
                ::Gitlab::SafeRequestStore.fetch(
                  ['Ci::Config::External::File::Project', 'spp_allows_pipeline_access', project.id]
                ) do
                  ::Security::OrchestrationPolicyConfiguration.policy_management_project?(project) &&
                    project.project_setting.spp_repository_pipeline_access
                end
              end

              def pipeline_execution_policy_bot_file_access_allowed?(project)
                context.logger.instrument(:config_file_project_validate_bot_access) do
                  next false unless context.user&.security_policy_bot?
                  next false unless policy_management_project_access_allowed?

                  ::Gitlab::SafeRequestStore.fetch(
                    [
                      'Ci::Config::External::File::Project',
                      'pipeline_execution_policy_bot_file_access_allowed',
                      project.id,
                      context.user.id,
                      params[:file].to_s
                    ]
                  ) do
                    bot_project = context.user.security_policy_bot_project
                    next false unless bot_project

                    project.project_setting.allows_pipeline_execution_policy_bot_access?(
                      file_path: params[:file],
                      bot_project: bot_project
                    )
                  end
                end
              end

              def policy_management_project_access_allowed?
                context.pipeline_policy_context&.pipeline_execution_context&.policy_management_project_access_allowed?
              end
            end
          end
        end
      end
    end
  end
end
