# frozen_string_literal: true

module SecretsManagement
  class BaseSecretsManagerMaintenanceTask < ApplicationRecord
    self.abstract_class = true

    enum :action, {
      provision: 0,
      deprovision: 1
    }

    belongs_to :user
    belongs_to :root_namespace,
      class_name: 'Namespace'

    validates :action, presence: true
    validates :user_id, presence: true
    validates :root_namespace_id, presence: true
    validates :retry_count,
      numericality: {
        greater_than_or_equal_to: 0,
        only_integer: true
      }

    scope :stale, ->(threshold) {
      where(last_processed_at: ...threshold.ago)
    }

    scope :retryable, ->(max_retries) {
      where(retry_count: ...max_retries)
    }
  end
end
