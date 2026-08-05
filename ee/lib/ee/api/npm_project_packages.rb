# frozen_string_literal: true

module EE
  module API
    module NpmProjectPackages
      extend ActiveSupport::Concern

      prepended do
        helpers ::EE::API::Helpers::DependencyFirewallHelpers

        helpers do
          extend ::Gitlab::Utils::Override

          # Name is normalized so policy rules match regardless of how the package
          # was requested; the `package&.project` guard is defensive (the finder
          # returns a package before this runs).
          override :enforce_dependency_firewall_on_download!
          def enforce_dependency_firewall_on_download!(package)
            return unless ::Feature.enabled?(:dependency_firewall_phase1, package&.project)
            return unless package&.project

            enforce_dependency_firewall!(
              project: package.project,
              pkg_type: 'npm',
              name: ::Sbom::PackageUrl::Normalizer.new(type: 'npm', text: package.name).normalize_name,
              version: package.version,
              operation: ::Security::DependencyFirewall::EnforcementService::PACKAGE_DOWNLOAD
            )
          end
        end
      end
    end
  end
end
