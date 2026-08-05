# frozen_string_literal: true

module Ai
  class Setting < ApplicationRecord
    self.table_name = "ai_settings"

    include SingletonRecord
    include HasRolePermissions
    include CustomizablePermission
    include NormalizesDomainLists

    ignore_column :duo_nano_features_enabled, remove_with: '18.3', remove_after: '2025-07-15'
    jsonb_accessor :feature_settings,
      ai_audit_events_streaming_enabled: [:boolean, { default: false }],
      duo_agent_platform_enabled: [:boolean, { default: true }],
      duo_cli_enabled: [:boolean, { default: true }]

    validates :feature_settings,
      json_schema: { filename: "ai_setting_feature_settings", size_limit: 64.kilobytes }

    validates :amazon_q_role_arn, length: { maximum: 2048 }, allow_nil: true

    validates :duo_core_features_enabled,
      inclusion: { in: [true, false] },
      if: :will_save_change_to_duo_core_features_enabled?

    belongs_to :organization, class_name: 'Organizations::Organization', optional: true
    validates :organization_id, uniqueness: true, allow_nil: true

    belongs_to :amazon_q_oauth_application, class_name: 'Authn::OauthApplication', optional: true
    belongs_to :amazon_q_service_account_user, class_name: 'User', optional: true

    belongs_to :duo_workflow_oauth_application, class_name: 'Authn::OauthApplication', optional: true
    belongs_to :duo_workflow_service_account_user, class_name: 'User', optional: true

    after_commit :trigger_todo_creation, on: :update, if: :saved_change_to_duo_core_features_enabled?

    def self.for_organization(organization)
      raise ArgumentError, 'organization is required' unless organization

      # rubocop:disable Performance/ActiveRecordSubtransactionMethods -- creates at most one row per organization
      safe_find_or_create_by(organization_id: organization.id) do |setting|
        setting.assign_attributes(defaults)
      end
      # rubocop:enable Performance/ActiveRecordSubtransactionMethods
    end

    def self.self_hosted?
      ::Ai::SelfHostedModel.any?
    end

    def self.duo_core_features_enabled?
      !!instance.duo_core_features_enabled
    end

    def self.amazon_q_service_account?(user)
      instance.amazon_q_service_account_user_id == user.id
    end

    private

    def trigger_todo_creation
      return if ::Gitlab::Saas.feature_available?(:gitlab_duo_saas_only)
      return unless duo_core_features_enabled?

      GitlabSubscriptions::SelfManaged::DuoCoreTodoNotificationWorker
        .perform_in(GitlabSubscriptions::DuoCore::DELAY_TODO_NOTIFICATION)
    end

    def resolve_ai_settings
      self
    end
  end
end
