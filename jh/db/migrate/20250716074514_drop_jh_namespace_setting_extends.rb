# rubocop:disable Naming/FileName -- Already in a namespace
# frozen_string_literal: true

# rubocop:disable Gitlab/NamespacedClass -- Base in the global namespace
# rubocop:disable Migration/DropTable -- No need for downtime
class DropJHNamespaceSettingExtends < Gitlab::Database::Migration[2.3]
  milestone '18.2'

  def up
    drop_table :jh_namespace_setting_extends
  end

  def down
    create_table :jh_namespace_setting_extends do |t|
      t.bigint :namespace_id, index: true, null: true
      t.text :mr_custom_page_title, null: false, limit: 256
      t.text :mr_custom_page_url, null: false, limit: 2048
      t.timestamps_with_timezone null: false
    end
  end
end
# rubocop:enable Migration/DropTable
# rubocop:enable Gitlab/NamespacedClass
# rubocop:enable Naming/FileName
