# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      module FoundationalFlow
        extend ActiveSupport::Concern

        JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE = 'jh_advanced_code_review/v1'
        DINGTALK_ASSISTANT_FLOW_REFERENCE = 'dingtalk_assistant/v1'
        FEISHU_ASSISTANT_FLOW_REFERENCE = 'feishu_assistant/v1'

        # Items are cached on first read, and on Puma boot config/initializers/zz_metrics.rb loads every API, whose
        # StartDuoSessionService::DEFAULT_FLOW reads them before any JH initializer runs. Drop that JH-less cache.
        prepended do
          remove_instance_variable(:@raw_items) if instance_variable_defined?(:@raw_items)
          storage.clear
        end

        class_methods do
          extend ::Gitlab::Utils::Override

          def jh_advanced_code_review_v1
            find_by(foundational_flow_reference: JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE)
          end

          def dingtalk_assistant_v1
            find_by(foundational_flow_reference: DINGTALK_ASSISTANT_FLOW_REFERENCE)
          end

          def feishu_assistant_v1
            find_by(foundational_flow_reference: FEISHU_ASSISTANT_FLOW_REFERENCE)
          end

          override :fixed_items
          def fixed_items
            super + [
              {
                foundational_flow_reference: JH_ADVANCED_CODE_REVIEW_FLOW_REFERENCE,
                display_name: s_('JH|FoundationalFlow|JH Advanced Code Review'),
                description: s_(
                  'JH|FoundationalFlow|Review merge requests with related Issue and Pipeline context.'
                ),
                avatar: 'code-review-flow.png',
                feature_maturity: 'experimental',
                ai_feature: 'duo_agent_platform',
                agent_privileges: [
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
                ],
                suppress_mention_progress_note: true,
                triggers: [
                  ::Ai::FlowTrigger::EVENT_TYPES[:assign_reviewer],
                  ::Ai::FlowTrigger::EVENT_TYPES[:mention]
                ],
                goal_templates: ::JH::Ai::Catalog::GoalTemplates::JHAdvancedCodeReview
              },
              {
                foundational_flow_reference: DINGTALK_ASSISTANT_FLOW_REFERENCE,
                display_name: s_('JH|FoundationalFlow|GitLab Duo for DingTalk'),
                description: s_('JH|FoundationalFlow|Answers questions when GitLab Duo is messaged in DingTalk.'),
                avatar: 'gitlab-duo-flow.png',
                feature_maturity: 'experimental',
                feature_flag: 'jh_dingtalk_duo_chat',
                ai_feature: 'duo_agent_platform',
                # READ_WRITE_GITLAB is all-or-nothing, so what actually limits the bot is the
                # flow config's toolset. Keep it to reversible writes: the adapter keeps this
                # privilege and START_FLOWS out of pre_approved_agent_privileges, so every
                # write and every delegation to a CI flow still needs user approval.
                agent_privileges: [
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
                ],
                environment: 'ambient',
                coding_environment: 'none',
                triggers: [],
                supported_events: [],
                # Resolves to the JH-owned config at
                # duo_workflow_service/agent_platform/v1/flows/configs/dingtalk_assistant/
                # in the Duo Workflow Service, matched by reference name. It carries the
                # read tools, the note and issue write tools, and start_flow. Each run ends
                # after one turn, so the session finishes like slack_assistant's does.
                # coding_environment 'none' is also what routes the flow to Workhorse
                # (Ai::DuoWorkflows::ExecuteRunService.runtime_for).
                flow_version: '^1.0.0'
              },
              {
                foundational_flow_reference: FEISHU_ASSISTANT_FLOW_REFERENCE,
                display_name: s_('JH|FoundationalFlow|GitLab Duo for Feishu'),
                description: s_('JH|FoundationalFlow|Answers questions when GitLab Duo is messaged in Feishu.'),
                avatar: 'gitlab-duo-flow.png',
                feature_maturity: 'experimental',
                feature_flag: 'jh_feishu_duo_chat',
                ai_feature: 'duo_agent_platform',
                # Same privileges and approval rule as the DingTalk flow above.
                agent_privileges: [
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                  ::Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
                ],
                environment: 'ambient',
                coding_environment: 'none',
                triggers: [],
                supported_events: [],
                # Resolves to the JH-owned config at
                # ai/features/chat_integrations/feishu_assistant/ in the Duo Workflow Service.
                flow_version: '^1.0.0'
              }
            ]
          end
        end
      end
    end
  end
end
