# frozen_string_literal: true

module EE
  module Gitlab
    module ApplicationRateLimiter
      module LabkitAdapter
        # EE-only entries for the labkit rate-limit adapter, merged into
        # the CE registry via prepend. Mirrors the EE override of
        # Gitlab::ApplicationRateLimiter#rate_limits in
        # ee/lib/ee/gitlab/application_rate_limiter.rb so the registry
        # keys track the rate-limits map shape.
        #
        # See lib/gitlab/application_rate_limiter/labkit_adapter/supported_rate_limits.rb
        # for the conventions (flag_scope, AR-typed characteristics, the
        # exclusion categories). EE-only keys without current call sites
        # (container_scanning_for_registry_scans,
        # dependency_scanning_sbom_scan_api_{download,upload},
        # semantic_code_search_ad_hoc_indexing, semantic_search_rate_limit)
        # are deliberately not registered until a call site lands; the
        # partner_{aws,gcp,postman}_api keys have sub-second intervals
        # and are deferred to a separate rollout.
        module SupportedRateLimits
          extend ActiveSupport::Concern

          class_methods do
            extend ::Gitlab::Utils::Override

            override :entries
            def entries
              super.merge({
                ai_catalog_item_report: {
                  limiter_name: 'applimiter_ai_catalog_item_report',
                  rule_name: 'limit_ai_catalog_item_reports_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                code_suggestions_connection_details: {
                  limiter_name: 'applimiter_code_suggestions_connection_details',
                  rule_name: 'limit_code_suggestions_connection_details_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                code_suggestions_direct_access: {
                  limiter_name: 'applimiter_code_suggestions_direct_access',
                  rule_name: 'limit_code_suggestions_direct_access_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                code_suggestions_x_ray_dependencies: {
                  limiter_name: 'applimiter_code_suggestions_x_ray_dependencies',
                  rule_name: 'limit_code_suggestions_x_ray_dependencies_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_2
                },
                code_suggestions_x_ray_scan: {
                  limiter_name: 'applimiter_code_suggestions_x_ray_scan',
                  rule_name: 'limit_code_suggestions_x_ray_scans_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_2
                },
                create_duo_otel_workflow: {
                  limiter_name: 'applimiter_create_duo_otel_workflow',
                  rule_name: 'limit_duo_otel_workflow_creates_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                credit_card_verification_check_for_reuse: {
                  limiter_name: 'applimiter_credit_card_verification_check_for_reuse',
                  rule_name: 'limit_credit_card_verification_reuse_checks_by_ip',
                  characteristics: %i[ip],
                  action: :block,
                  flag_scope: :cohort_2
                },
                dependency_scanning_sbom_scan_api_throttling: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_throttling',
                  rule_name: 'limit_sbom_scan_api_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_2
                },
                duo_workflow_direct_access: {
                  limiter_name: 'applimiter_duo_workflow_direct_access',
                  rule_name: 'limit_duo_workflow_direct_access_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                hard_phone_verification_transactions_limit: {
                  limiter_name: 'applimiter_hard_phone_verification_transactions_limit',
                  rule_name: 'limit_hard_phone_verification_transactions_by_scope',
                  characteristics: %i[scope],
                  action: :block,
                  flag_scope: :cohort_3
                },
                orbit_query: {
                  limiter_name: 'applimiter_orbit_query',
                  rule_name: 'limit_orbit_queries_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                package_metadata: {
                  limiter_name: 'applimiter_package_metadata',
                  rule_name: 'limit_package_metadata_queries_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_2
                },
                soft_phone_verification_transactions_limit: {
                  limiter_name: 'applimiter_soft_phone_verification_transactions_limit',
                  rule_name: 'limit_soft_phone_verification_transactions_by_scope',
                  characteristics: %i[scope],
                  action: :block,
                  flag_scope: :cohort_3
                },
                virtual_registries_endpoints_api_limit: {
                  limiter_name: 'applimiter_virtual_registries_endpoints_api_limit',
                  rule_name: 'limit_virtual_registries_endpoints_api_by_ip_group',
                  characteristics: %i[ip group],
                  action: :block,
                  flag_scope: :cohort_2
                }
              })
            end
          end
        end
      end
    end
  end
end
