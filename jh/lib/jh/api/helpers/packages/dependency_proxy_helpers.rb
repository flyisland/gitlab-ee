# frozen_string_literal: true

module JH
  module API
    module Helpers
      module Packages
        module DependencyProxyHelpers
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          JH_REGISTRY_BASE_URLS = {
            npm: ENV.fetch('REGISTRY_PROXY_BASE_URL_NPM', 'https://registry.npmjs.org/'),
            pypi: ENV.fetch('REGISTRY_PROXY_BASE_URL_PYPI', 'https://pypi.org/simple/'),
            maven: ENV.fetch('REGISTRY_PROXY_BASE_URL_MAVEN', 'https://repo.maven.apache.org/maven2/')
          }.freeze

          override :registry_base_url
          def registry_base_url(package_type)
            JH_REGISTRY_BASE_URLS[package_type]
          end
        end
      end
    end
  end
end
