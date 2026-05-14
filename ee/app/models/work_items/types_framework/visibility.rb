# frozen_string_literal: true

module WorkItems
  module TypesFramework
    class Visibility < ApplicationRecord
      include WorkItems::TypesFramework::HasType

      self.table_name = 'work_item_type_visibilities'

      belongs_to :namespace

      validates :namespace, presence: true
      validates :work_item_type_id, presence: true, uniqueness: { scope: :namespace_id }
      validates :enabled, inclusion: { in: [true, false] }
      validates :propagate, inclusion: { in: [true, false] }
    end
  end
end
