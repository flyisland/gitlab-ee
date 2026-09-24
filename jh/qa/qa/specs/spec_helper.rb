# frozen_string_literal: true

require_relative '../../../lib/jh/skip_specs'

AVAILABLE_ENV_TYPES = %w[self-managed staging production staging-canary].freeze

if ENV["QA_JH_ENV"].present?
  unless AVAILABLE_ENV_TYPES.include?(ENV["QA_JH_ENV"])
    raise "Invalid `QA_JH_ENV`, optional: #{AVAILABLE_ENV_TYPES.join(', ')}."
  end

  config_path = File.expand_path("config/e2e_skip_specs_#{ENV['QA_JH_ENV']}.yml", __dir__)
  skip_specs = JH::SkipSpecs.new(config_path)
end

RSpec.configure do |config|
  if skip_specs&.skipped_list&.any?
    config.around do |example|
      example.run unless skip_specs.skipped?(example)
    end
  end

  config.before(:suite) do |_suite|
    if ENV['QA_ROOT_LANGUAGE'].present?
      root_language = ENV['QA_ROOT_LANGUAGE']
      QA::Flow::JhSetLanguage.set_language(root_language)
    end
  end
end
