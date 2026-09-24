# rubocop:disable Naming/FileName -- Already in a namespace
# frozen_string_literal: true

# rubocop:disable Gitlab/NamespacedClass -- Base in the global namespace
class CreateJHNamespaceSettingExtends < Gitlab::Database::Migration[2.2]
  milestone '17.1'

  def change
    create_table :jh_namespace_setting_extends do |t|
      t.bigint :namespace_id, index: true, null: true
      t.text :mr_custom_page_title, null: false, limit: 256
      t.text :mr_custom_page_url, null: false, limit: 2048
      t.timestamps_with_timezone null: false
    end
  end
end
# rubocop:enable Gitlab/NamespacedClass
# rubocop:enable Naming/FileName
