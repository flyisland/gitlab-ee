# frozen_string_literal: true

module JH
  class SkipSpecs
    attr_reader :config_path

    def initialize(config_path)
      @config_path = config_path
    end

    def skipped?(example)
      file_path = example.file_path[2..]
      description = example.full_description

      return false if skipped_list[file_path].nil?

      description_prefixes = skipped_list[file_path]["description_prefix"]
      return true if description_prefixes&.any? { |prefix| description.start_with?(prefix) }

      # https://relishapp.com/rspec/rspec-core/docs/subject/one-liner-syntax
      # The `full_description` of one liner syntax will end with " ", need :line_number to locate
      if description.end_with?(" ") && skipped_list[file_path]["line_number"]
        return skipped_list[file_path]["line_number"] == example.metadata[:line_number]
      end

      return true if skipped_list[file_path]["description"].nil? && description_prefixes.nil?
      return false if skipped_list[file_path]["description"].nil?

      skipped_list[file_path]["description"].any? do |skipped_description|
        # https://relishapp.com/rspec/rspec-core/docs/subject/one-liner-syntax
        # The `full_description` of one liner syntax will end with " "
        if description.end_with?(" ")
          delete_index = skipped_description.rindex("is expected") || 0
          skipped_description = skipped_description[0..(delete_index - 1)]
        end

        skipped_description == description
      end
    end

    def skipped_list
      @skipped_list ||= begin
        list = YAML.load_file(config_path) || []
        list.index_by { |item| item["file_path"] }
      end
    end
  end
end
