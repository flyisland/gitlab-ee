# frozen_string_literal: true

Gitlab::Application.config.to_prepare do
  Gitlab::Database::Partitioning.register_models([
    Phone::VerificationCode
  ])

  Gitlab::Database::Partitioning.sync_partitions_ignore_db_error
end
