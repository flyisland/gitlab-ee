# rubocop:disable Naming/FileName -- Already in a namespace
# frozen_string_literal: true

# rubocop:disable Gitlab/NamespacedClass -- Base in the global namespace
class CreateJHEpicExtends < Gitlab::Database::Migration[2.2]
  milestone '16.10'

  def change
    create_table :jh_epic_extends do |t|
      t.bigint :epic_id, null: true, index: { unique: true }
      t.bigint :milestone_id, index: true, null: true
      t.bigint :sprint_id, index: true, null: true

      t.timestamps_with_timezone null: false
    end

    add_index :jh_epic_extends, [:epic_id, :milestone_id], unique: true
    add_index :jh_epic_extends, [:epic_id, :sprint_id], unique: true
  end
end
# rubocop:enable Gitlab/NamespacedClass
# rubocop:enable Naming/FileName
