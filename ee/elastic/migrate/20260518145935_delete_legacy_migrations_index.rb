# frozen_string_literal: true

class DeleteLegacyMigrationsIndex < Elastic::Migration
  include ::Search::Elastic::MigrationHelper

  retry_on_failure

  def migrate
    unless helper.index_exists?(index_name: old_index_name)
      log "Legacy migrations index #{old_index_name} does not exist, skipping"
      return
    end

    log "Starting migration to delete #{old_index_name}"

    helper.delete_index(index_name: old_index_name)

    log "Migration complete. Index #{old_index_name} has been deleted"
  end

  def completed?
    !helper.index_exists?(index_name: old_index_name)
  end

  private

  def old_index_name
    @old_index_name ||= helper.legacy_migrations_index_name
  end
end
