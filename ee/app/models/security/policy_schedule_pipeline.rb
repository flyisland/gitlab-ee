# frozen_string_literal: true

module Security
  class PolicySchedulePipeline < ApplicationRecord
    self.table_name = 'security_policy_schedule_pipelines'

    belongs_to :security_policy, class_name: 'Security::Policy'
    belongs_to :pipeline, class_name: 'Ci::Pipeline'
    belongs_to :project

    validates :security_policy, :pipeline, :project, presence: true
    validates :pipeline, uniqueness: true

    def self.safe_create(security_policy:, pipeline:, project:)
      create!(security_policy: security_policy, pipeline: pipeline, project: project)
    rescue ActiveRecord::RecordNotUnique
      nil
    rescue ActiveRecord::RecordInvalid => e
      Gitlab::ErrorTracking.track_exception(e,
        security_policy_id: security_policy.id,
        pipeline_id: pipeline.id
      )
    end
  end
end
