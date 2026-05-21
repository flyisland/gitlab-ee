# frozen_string_literal: true

FactoryBot.define do
  factory :project_secrets_manager_maintenance_task,
    class: 'SecretsManagement::ProjectSecretsManagerMaintenanceTask' do
    user
    project_secrets_manager

    action { :provision }
    last_processed_at { Time.zone.now }
    retry_count { 0 }
    project_id { project_secrets_manager&.project_id }
    organization_id { project_secrets_manager&.project&.organization_id }
    root_namespace_id { project_secrets_manager&.project&.root_ancestor&.id }
    parent_group_id { project_secrets_manager&.project&.namespace_id }

    trait :provision do
      action { :provision }
    end

    trait :deprovision do
      action { :deprovision }
    end

    trait :processing do
      last_processed_at { 1.minute.ago }
    end

    trait :stale do
      last_processed_at { 7.minutes.ago }
    end
  end
end
