# frozen_string_literal: true

module QA
  module JH
    module Runtime
      module Fixtures
        FIXTURES_SETTINGS = %w[
          helm_install_package.yaml.erb
          helm_upload_package.yaml.erb
          settings.xml.erb
          settings_with_pat.xml.erb
        ].freeze

        # @override :read_fixture
        def read_fixture(fixture_path, file_name)
          return super unless FIXTURES_SETTINGS.include?(file_name)

          file_path = Pathname
                        .new(__dir__)
                        .join("../fixtures/#{fixture_path}/#{file_name}")
          File.read(file_path)
        end
      end
    end
  end
end
