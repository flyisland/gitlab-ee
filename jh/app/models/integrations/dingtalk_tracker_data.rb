# frozen_string_literal: true

module Integrations
  class DingtalkTrackerData < ApplicationRecord
    belongs_to :integration, inverse_of: :dingtalk_tracker_data
    delegate :activated?, to: :integration
    validates :integration, presence: true
  end
end
