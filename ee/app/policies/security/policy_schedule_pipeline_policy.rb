# frozen_string_literal: true

module Security
  class PolicySchedulePipelinePolicy < BasePolicy
    delegate { @subject.project }
  end
end
