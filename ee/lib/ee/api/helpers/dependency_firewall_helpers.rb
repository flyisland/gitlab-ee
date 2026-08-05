# frozen_string_literal: true

module EE
  module API
    module Helpers
      module DependencyFirewallHelpers
        def enforce_dependency_firewall!(project:, pkg_type:, name:, version:, operation:)
          # Exceptions from firewall_check (invalid params, infrastructure failures) are intentionally
          # not rescued here. They propagate as 500s, which will trigger Prometheus alerting and contribute
          # to the error budget. See: https://gitlab.com/gitlab-org/gitlab/-/work_items/593923
          result = ::Security::DependencyFirewall::EnforcementService.firewall_check(
            project: project,
            pkg_type: pkg_type,
            name: name,
            version: version,
            operation: operation,
            current_user: current_user
          )

          return unless result.reason == ::Security::DependencyFirewall::EnforcementService::SUCCESS_BLOCKED

          render_structured_api_error!(
            { message: result.message.presence || 'Dependency Firewall policy violation',
              error: 'Dependency Firewall policy violation' },
            403
          )
        end
      end
    end
  end
end
