# frozen_string_literal: true

module Phone
  class VerificationCode < ApplicationRecord
    include CreatedAtFilterable
    include PartitionedTable

    self.primary_key = :phone

    scope :for_visitor, ->(visitor_id_code, phone) {
      where("visitor_id_code = ? and phone = ?", visitor_id_code, phone)
    }

    partitioned_by :created_at, strategy: :monthly, retain_for: 1.month
  end
end
