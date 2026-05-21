# frozen_string_literal: true

module Ai
  module FoundationalChatAgentsDefinitions
    extend ActiveSupport::Concern

    ITEMS = [
      {
        id: 1,
        reference: 'chat',
        global_catalog_id: nil,
        version: '',
        name: 'GitLab Duo',
        avatar: 'gitlab-duo-agent.png',
        public: true,
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
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
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
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
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
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
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
        description: <<~DESCRIPTION
          Get help analyzing your GitLab data (powered by GLQL)
        DESCRIPTION
      },
      {
        id: 6,
        reference: 'ci_expert_agent',
        global_catalog_id: 1004583,
        version: 'v1',
        name: 'CI Expert',
        public: true,
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
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
        name: 'Permissions Assistant',
        global_catalog_id: nil,
        public: true,
        item_type: Ai::Catalog::Item.item_types[Ai::Catalog::Item::FOUNDATIONAL_AGENT_TYPE],
        verification_level: ::Namespaces::VerifiedNamespace::VERIFICATION_LEVELS[:gitlab_maintained],
        avatar: 'gitlab-duo-agent.png',
        selectable_in_chat: false,
        description: <<~DESCRIPTION
          Get help with selecting permissions for fine-grained access tokens, applying the principle of least privilege.
        DESCRIPTION
      }
    ].freeze
  end
end
