# frozen_string_literal: true

Gitlab::Application.config.to_prepare do
  Gitlab::Database::Partitioning.register_models([
    Phone::VerificationCode
  ])
end
