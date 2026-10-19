# frozen_string_literal: true

module JH
  module RspecMetadataValidator
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      private

      override :known_keys
      def known_keys
        @known_keys ||= YAML.load_file(jh_known_keys_file) + super
      end

      def jh_known_keys_file
        File.join(__dir__, 'known_rspec_metadata_keys.yml')
      end
    end
  end
end
