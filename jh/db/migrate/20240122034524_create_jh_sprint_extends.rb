# rubocop:disable Naming/FileName -- Already in a namespace
# frozen_string_literal: true

# rubocop:disable Gitlab/NamespacedClass -- Base in the global namespace
class CreateJHSprintExtends < Gitlab::Database::Migration[2.2]
  milestone '16.10'

  def change
    create_table :jh_sprint_extends do |t|
      t.bigint :sprint_id, index: true, null: true

      t.timestamps_with_timezone null: false
    end
  end
end
# rubocop:enable Gitlab/NamespacedClass
# rubocop:enable Naming/FileName
