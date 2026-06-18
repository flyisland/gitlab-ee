# frozen_string_literal: true

module Ai
  module Catalog
    class FoundationalFlow
      include ActiveRecord::FixedItemsModel::Model
      include GlobalID::Identification
      include Gitlab::Utils::StrongMemoize

      CODE_REVIEW_FLOW_REFERENCE = 'code_review/v1'
      private_constant :CODE_REVIEW_FLOW_REFERENCE

      auto_generate_ids!

      DEFAULT_FLOW_VERSION = '1.0.0'

      attribute :display_name, :string
      attribute :ai_feature, :string, default: "duo_agent_platform"
      attribute :agent_privileges, default: []
      attribute :pre_approved_agent_privileges, default: []
      attribute :allow_agent_to_request_user, :boolean, default: false
      attribute :environment, :string, default: "ambient"
      attribute :foundational_flow_reference, :string
      attribute :feature_maturity, :string
      attribute :description, :string
      attribute :triggers, default: []
      attribute :supported_events, default: []
      attribute :precondition, default: {}
      attribute :avatar, :string
      attribute :ultimate_only, :boolean, default: false
      attribute :goal_templates
      attribute :resolve_noteable
      attribute :flow_version, :string, default: DEFAULT_FLOW_VERSION

      validates :display_name,
        :foundational_flow_reference,
        :ai_feature,
        :feature_maturity,
        :description,
        presence: true

      def self.fixed_items
        # Make sure static data is always loaded in English and let `translated_display_name` and
        # `translated_description` deal with translations when required.
        # This ensures catalog items records are created in English and translated on the fly depending on user locale.
        Gitlab::I18n.with_locale(:en) do
          [
            {
              foundational_flow_reference: CODE_REVIEW_FLOW_REFERENCE,
              display_name: s_(
                "FoundationalFlow|Code Review"
              ),
              # Editing this string? Update `NEW_DESCRIPTION` in
              # db/post_migrate/20260518152600_update_code_review_foundational_flow_description.rb
              # so existing rows backfill the same text on deploy.
              description: s_(
                "FoundationalFlow|Streamline code reviews by analyzing code changes and relevant codebase context. " \
                  "[How can I use this flow](https://docs.gitlab.com/user/duo_agent_platform/flows/foundational_flows/code_review/#use-the-flow)?"
              ),
              avatar: "code-review-flow.png",
              feature_maturity: "ga",
              ai_feature: "review_merge_request",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              triggers: []
            },
            {
              foundational_flow_reference: "sast_fp_detection/v1",
              display_name: s_(
                "FoundationalFlow|SAST False Positive Detection"
              ),
              description: s_(
                "FoundationalFlow|Analyze critical SAST vulnerabilities."
              ),
              avatar: "security-flow.png",
              feature_maturity: "ga",
              ai_feature: "sast_vulnerability_fp_detection",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: [],
              ultimate_only: true
            },
            {
              foundational_flow_reference: "resolve_sast_vulnerability/v1",
              display_name: s_(
                "FoundationalFlow|Resolve SAST Vulnerability"
              ),
              description: s_(
                "FoundationalFlow|Resolve critical SAST vulnerabilities."
              ),
              feature_maturity: "ga",
              ai_feature: "sast_vulnerability_resolution",
              avatar: "security-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: [],
              ultimate_only: true
            },
            {
              foundational_flow_reference: "developer/v1",
              display_name: s_(
                "FoundationalFlow|Developer"
              ),
              description: s_(
                "FoundationalFlow|Turn feedback into actionable merge requests or issues."
              ),
              feature_maturity: "ga",
              avatar: "gitlab-duo-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: [
                ::Ai::FlowTrigger::EVENT_TYPES[:assign],
                ::Ai::FlowTrigger::EVENT_TYPES[:mention]
              ],
              goal_templates: ::Ai::Catalog::GoalTemplates::Developer,
              flow_version: '^2.0.0'
            },
            {
              foundational_flow_reference: "fix_pipeline/v1",
              display_name: s_(
                "FoundationalFlow|Fix CI/CD Pipeline"
              ),
              description: s_(
                "FoundationalFlow|Diagnose and fix issues in your GitLab CI/CD pipeline."
              ),
              feature_maturity: "ga",
              avatar: "fix-pipeline-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: [],
              supported_events: [::Ai::FlowTrigger::EVENT_TYPES[:pipeline_hooks]],
              precondition: {
                'match' => 'all',
                'rules' => [
                  { 'field' => 'object_attributes.status', 'operator' => 'eq', 'value' => 'failed' }
                ]
              },
              resolve_noteable: ->(project:, goal:) do
                return unless Feature.enabled?(:fix_pipeline_next, project) ||
                  Feature.enabled?(:fix_pipeline_next, project.root_namespace)

                pipeline_id = goal.to_s.match(%r{/-/pipelines/(\d+)})&.captures&.first&.to_i
                return unless pipeline_id&.positive?

                pipeline = Ci::Pipeline.for_project(project).find_by_id(pipeline_id)
                pipeline&.merge_request
              end
            },
            {
              foundational_flow_reference: "convert_to_gl_ci/v1",
              display_name: s_(
                "FoundationalFlow|Convert to GitLab CI/CD"
              ),
              description: s_(
                "FoundationalFlow|Migrate your Jenkins pipelines to GitLab CI/CD."
              ),
              feature_maturity: "ga",
              avatar: "convert-ci-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: []
            },
            {
              foundational_flow_reference: "recommend_reviewers/v1",
              display_name: s_(
                "FoundationalFlow|Recommend Reviewers"
              ),
              description: s_(
                "FoundationalFlow|Recommend reviewers for merge requests based on availability, workload, and timezone."
              ),
              feature_maturity: "beta",
              avatar: "gitlab-duo-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
              ],
              triggers: []
            },
            {
              foundational_flow_reference: "secrets_fp_detection/v1",
              display_name: s_(
                "FoundationalFlow|Secret Detection False Positive Detection"
              ),
              description: s_(
                "FoundationalFlow|Analyze critical Secret Detection vulnerabilities."
              ),
              feature_maturity: "ga",
              ai_feature: "secret_vulnerability_fp_detection",
              avatar: "security-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "web",
              triggers: [],
              ultimate_only: true
            },
            {
              foundational_flow_reference: "resolve_dependency_bump/experimental",
              display_name: s_(
                "FoundationalFlow|Resolve Dependency Bump Breaking Changes"
              ),
              description: s_(
                "FoundationalFlow|Analyze and fix breaking changes caused by dependency bumps."
              ),
              feature_maturity: "beta",
              ai_feature: "resolve_dependency_bump",
              avatar: "security-flow.png",
              pre_approved_agent_privileges: [
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::RUN_COMMANDS,
                ::Ai::DuoWorkflows::Workflow::AgentPrivileges::USE_GIT
              ],
              environment: "ambient",
              triggers: [],
              ultimate_only: true
            }
          ]
        end
      end

      def self.find_by_reference(reference)
        find_by(foundational_flow_reference: reference)
      end

      def self.[](key)
        definition = find_by(foundational_flow_reference: key) || find_by(display_name: key)

        definition&.tap do |def_obj|
          def_obj.agent_privileges = def_obj.pre_approved_agent_privileges if def_obj.agent_privileges.empty?
        end
      end

      def self.beta?(foundational_flow_reference)
        flow = find_by(foundational_flow_reference: foundational_flow_reference)
        flow&.feature_maturity == 'beta'
      end

      def self.ultimate_only?(foundational_flow_reference)
        flow = find_by(foundational_flow_reference: foundational_flow_reference)
        !!flow&.ultimate_only
      end

      def self.ga
        where(feature_maturity: 'ga')
      end

      def self.code_review
        find_by!(foundational_flow_reference: CODE_REVIEW_FLOW_REFERENCE)
      end

      def agent_privileges
        privileges = super

        return pre_approved_agent_privileges if privileges.empty?

        privileges
      end

      def agent_privileges=(value)
        super(Array(value).map { |v| Integer(v) })
      end

      def pre_approved_agent_privileges=(value)
        super(Array(value).map { |v| Integer(v) })
      end

      def resolve_noteable_for(project:, goal:)
        return unless resolve_noteable

        resolve_noteable.call(project: project, goal: goal)
      end

      def translated_display_name
        # rubocop:disable Gettext/StaticIdentifier -- Translations available in `fixed_items`.
        s_("FoundationalFlow|#{display_name}") if display_name
        # rubocop:enable Gettext/StaticIdentifier
      end

      def translated_description
        # rubocop:disable Gettext/StaticIdentifier -- Translations available in `fixed_items`.
        s_("FoundationalFlow|#{description}") if description
        # rubocop:enable Gettext/StaticIdentifier
      end

      def catalog_item
        return if foundational_flow_reference.nil?

        Ai::Catalog::Item.with_foundational_flow_reference(foundational_flow_reference).first
      end
      strong_memoize_attr :catalog_item
    end
  end
end
