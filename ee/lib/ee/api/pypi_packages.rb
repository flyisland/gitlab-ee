# frozen_string_literal: true

module EE
  module API
    module PypiPackages
      extend ActiveSupport::Concern

      ALLOWED_UPSTREAM_FILE_HOSTS = %w[files.pythonhosted.org].freeze

      prepended do
        helpers ::EE::API::Helpers::DependencyFirewallHelpers

        helpers do
          extend ::Gitlab::Utils::Override

          # Name is PEP 503-normalized so policy rules match regardless of how the
          # package was published; the `package&.project` guard is defensive (the
          # finder raises before this runs).
          override :enforce_dependency_firewall_on_download!
          def enforce_dependency_firewall_on_download!(package)
            return unless package&.project
            return unless ::Feature.enabled?(:dependency_firewall_phase1, package.project)

            enforce_dependency_firewall!(
              project: package.project,
              pkg_type: 'pypi',
              name: package.normalized_pypi_name,
              version: package.version,
              operation: ::Security::DependencyFirewall::EnforcementService::PACKAGE_DOWNLOAD
            )
          end

          # No package record exists yet, so the raw upload name is normalized via the
          # shared Sbom::PackageUrl::Normalizer (PEP 503 for pypi), matching the read
          # path's Packages::Pypi::Package#normalized_pypi_name.
          override :enforce_dependency_firewall_on_upload!
          def enforce_dependency_firewall_on_upload!(project, name, version)
            return if name.blank? || version.blank?
            return unless ::Feature.enabled?(:dependency_firewall_phase1, project)

            enforce_dependency_firewall!(
              project: project,
              pkg_type: 'pypi',
              name: ::Sbom::PackageUrl::Normalizer.new(type: 'pypi', text: name).normalize_name,
              version: version,
              operation: ::Security::DependencyFirewall::EnforcementService::PACKAGE_UPLOAD
            )
          end

          # Called from the project file route when no local file matches. Returns truthy
          # only when it issues the 302 to the upstream artifact; a firewall block halts
          # with 403 before returning. Any gate failure returns false so the route 404s.
          override :handle_pypi_upstream_file_redirect!
          def handle_pypi_upstream_file_redirect!(project)
            return false unless ::Feature.enabled?(:dependency_firewall_phase1, project)
            return false unless redirect_registry_request_available?(:pypi, project)
            return false if [:package_name, :version, :upstream_url].any? { |key| params[key].blank? }

            upstream_url = params[:upstream_url]
            return false unless allowed_upstream_file_url?(upstream_url)

            enforce_dependency_firewall!(
              project: project,
              pkg_type: 'pypi',
              name: ::Sbom::PackageUrl::Normalizer.new(type: 'pypi', text: params[:package_name]).normalize_name,
              version: params[:version],
              operation: ::Security::DependencyFirewall::EnforcementService::PACKAGE_DOWNLOAD
            )

            track_package_event('pull_package', :pypi, project: project, namespace: project.namespace)

            redirect(upstream_url)

            true
          end

          def allowed_upstream_file_url?(url)
            uri = URI.parse(url.to_s)
            uri.scheme == 'https' &&
              EE::API::PypiPackages::ALLOWED_UPSTREAM_FILE_HOSTS.include?(uri.host&.downcase)
          rescue URI::InvalidURIError
            false
          end

          override :present_simple_package
          def present_simple_package(group_or_project)
            return super unless forward_pypi_simple_candidate?(group_or_project)

            authorize_read_package!(group_or_project)

            return super unless package_missing_locally?(group_or_project)

            result = ::Packages::Pypi::Upstream::Client.new.fetch_simple(
              params[:package_name], base_url: registry_base_url(:pypi)
            )

            if result.success?
              present_forwarded_simple_package(group_or_project, result.payload[:files])
            elsif result.reason == :not_found
              not_found!('Package')
            else
              render_api_error!('Failed to fetch package metadata from the upstream PyPI registry', 502)
            end
          end

          private

          def forward_pypi_simple_candidate?(group_or_project)
            group_or_project.is_a?(::Project) &&
              ::Feature.enabled?(:dependency_firewall_phase1, group_or_project) &&
              redirect_registry_request_available?(:pypi, group_or_project)
          end

          def package_missing_locally?(group_or_project)
            ::Packages::Pypi::PackagesFinder
              .new(current_user, group_or_project, { package_name: params[:package_name] })
              .execute
              .empty?
          end

          def present_forwarded_simple_package(project, files)
            track_simple_event(project, 'list_package')

            if pep_691_json_enabled?(project) && json_format_requested?
              presenter = ::Packages::Pypi::ForwardedSimplePackageVersionsJsonPresenter.new(
                package_name: params[:package_name],
                files: files,
                project: project,
                allowed_hosts: EE::API::PypiPackages::ALLOWED_UPSTREAM_FILE_HOSTS
              )
              present_simple_json(presenter.body)
            else
              presenter = ::Packages::Pypi::ForwardedSimplePackageVersionsPresenter.new(
                package_name: params[:package_name],
                files: files,
                project: project,
                allowed_hosts: EE::API::PypiPackages::ALLOWED_UPSTREAM_FILE_HOSTS
              )
              present_pypi_html_with_vary(presenter.body)
            end
          end
        end
      end
    end
  end
end
