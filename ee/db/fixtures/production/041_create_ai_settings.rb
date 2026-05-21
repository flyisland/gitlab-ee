# frozen_string_literal: true

Gitlab::Seeder.quiet do
  ::Ai::Setting.instance
end
