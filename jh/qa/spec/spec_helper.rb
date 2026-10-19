# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative '../qa'
require_relative '../../lib/jh/skip_specs'

config_path = File.expand_path("config/skip_specs.yml", __dir__)
skip_specs = JH::SkipSpecs.new(config_path)

RSpec.configure do |config|
  if skip_specs&.skipped_list&.any?
    config.around do |example|
      example.run unless skip_specs.skipped?(example)
    end
  end
end
