# frozen_string_literal: true

module Packages
  module Pypi
    module Upstream
      # EE-only: builds the upstream PyPI Simple API URL for a package. Used solely
      # from the FF-gated EE prepend (EE::API::PypiPackages); never loaded in CE.
      # The base URL is resolved by the caller through
      # DependencyProxyHelpers#registry_base_url(:pypi) so JiHu / mirror overrides are
      # respected, matching the CE dependency-proxy redirect path.
      class Configuration
        def self.simple_url_for(package_name, base_url:)
          normalized = ::Sbom::PackageUrl::Normalizer.new(type: 'pypi', text: package_name.to_s).normalize_name

          "#{base_url}#{normalized}/"
        end
      end
    end
  end
end
