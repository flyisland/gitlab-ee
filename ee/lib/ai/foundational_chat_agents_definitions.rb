# frozen_string_literal: true

module Ai
  module FoundationalChatAgentsDefinitions
    extend ActiveSupport::Concern

    SYSTEM_PROMPTS_PATH = File.expand_path('foundational_chat_agents/system_prompts', __dir__)

    GITLAB_MAINTAINED = ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained]
    FOUNDATIONAL_AGENT_TYPE = Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE]

    ITEMS = [
      {
        id: 1,
        reference: 'chat',
        global_catalog_id: nil,
        version: '',
        name: 'GitLab Duo',
        avatar: 'gitlab-duo-agent.png',
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        description: "Your general development assistant. Get help with code, planning,
        security, project management, and more."
      },
      {
        id: 2,
        reference: 'orbit_agent',
        version: 'v1',
        name: 'Orbit',
        global_catalog_id: nil,
        avatar: 'gitlab-duo-agent.png',
        public: true,
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
        description: <<~DESCRIPTION
          AI-powered intelligence analyst with Knowledge Graph access. Query your SDLC data as a connected graph to discover relationships between code, work items, merge requests, pipelines, vulnerabilities, and more.
        DESCRIPTION
      },
      {
        id: 3,
        reference: 'duo_planner',
        version: 'v1',
        name: 'Planner',
        global_catalog_id: 348,
        avatar: 'planner-agent.png',
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        tools: %i[
          gitlab_milestone_search
          gitlab__user_search
          gitlab_documentation_search
          get_current_user
          get_work_item
          create_work_item_note
          update_work_item
          list_work_items
          get_work_item_notes
          create_work_item
          get_wiki_page
        ],
        description: <<~DESCRIPTION
          Get help with planning and workflow management. Organize, edit, create, and track work more effectively in GitLab.
        DESCRIPTION
      },
      {
        id: 4,
        global_catalog_id: 356,
        reference: 'security_analyst_agent',
        version: 'v1',
        name: 'Security Analyst',
        avatar: 'security-agent.png',
        ultimate_only: true,
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        tools: %i[
          gitlab_commit_search
          create_issue
          create_issue_note
          create_merge_request
          create_merge_request_note
          edit_file
          get_commit
          get_commit_diff
          get_issue
          get_merge_request
          get_project
          get_repository_file
          grep
          list_all_merge_request_notes
          list_dir
          list_merge_request_diffs
          gitlab_merge_request_search
          read_file
          run_command
          update_issue
          update_merge_request
          create_file_with_contents
          create_vulnerability_issue
          read_files
          revert_to_detected_vulnerability
          update_vulnerability_severity
          link_vulnerability_to_issue
          get_vulnerability_details
          dismiss_vulnerability
          confirm_vulnerability
          create_commit
          list_vulnerabilities
          get_security_finding_details
          list_security_findings
        ],
        description: <<~DESCRIPTION
          Automate vulnerability management and security workflows. The Security Analyst Agent acts as an
          AI team member that can autonomously analyze,
          triage, and remediate security vulnerabilities, reducing manual security tasks while ensuring
          critical exploitable vulnerabilities are immediately surfaced and addressed.
        DESCRIPTION
      },
      {
        id: 5,
        reference: 'analytics_agent',
        global_catalog_id: 1003596,
        version: 'v1',
        name: 'Data Analyst',
        avatar: 'analytics-agent.png',
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        tools: %i[
          create_merge_request_note
          get_current_user
          create_work_item_note
          run_glql_query
        ],
        description: <<~DESCRIPTION
          Get help analyzing your GitLab data (powered by GLQL)
        DESCRIPTION
      },
      {
        id: 6,
        reference: 'ci_expert_agent',
        global_catalog_id: 1004583,
        version: 'v1',
        name: 'CI Expert (beta)',
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        tools: %i[
          gitlab_blob_search
          ci_linter
          create_merge_request
          edit_file
          find_files
          get_job_logs
          get_pipeline_errors
          get_project
          get_repository_file
          grep
          list_dir
          read_file
          create_file_with_contents
          gitlab_documentation_search
          read_files
          create_commit
          get_pipeline_failing_jobs
        ],
        description: <<~DESCRIPTION
          Helps you create, debug, and optimize GitLab CI/CD pipelines. This agent can generate
          .gitlab-ci.yml configurations, explain CI/CD syntax, suggest templates based on your
          project type, and recommend best practices for caching, parallelization, and pipeline efficiency.
        DESCRIPTION
      },
      {
        id: 7,
        reference: 'duo_permissions_assistant',
        version: 'v1',
        name: 'Permissions Assistant (beta)',
        global_catalog_id: nil,
        public: true,
        item_type: FOUNDATIONAL_AGENT_TYPE,
        verification_level: GITLAB_MAINTAINED,
        avatar: 'gitlab-duo-agent.png',
        selectable_in_chat: false,
        # Also needs update_form_permissions which doesn't exist in the monorepo
        tools: %i[
          gitlab_graphql
        ],
        description: <<~DESCRIPTION
          Get help with selecting permissions for fine-grained access tokens, applying the principle of least privilege.
        DESCRIPTION
      }
    ].freeze
  end
end
