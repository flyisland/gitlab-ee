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
        # exclusion categories).
        #
        # The partner_{aws,gcp,postman}_api keys (cohort_6) have 1-second
        # intervals. They share the cohort_6 flag pair with the EE
        # registry corrections, but their rollout playbook flips both
        # cohort_6 flags simultaneously for these three keys rather than
        # running the standard 24h shadow window, because the labkit
        # adapter's window-boundary-noise filter marks every 1-second
        # check as boundary=true, producing no usable shadow-divergence
        # signal for narrow intervals.
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
                container_scanning_for_registry_scans: {
                  limiter_name: 'applimiter_container_scanning_for_registry_scans',
                  rule_name: 'limit_container_scanning_for_registry_scans_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
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
                dependency_scanning_sbom_scan_api_download: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_download',
                  rule_name: 'limit_dependency_scanning_sbom_scan_api_downloads_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
                },
                dependency_scanning_sbom_scan_api_throttling: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_throttling',
                  rule_name: 'limit_sbom_scan_api_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_2
                },
                dependency_scanning_sbom_scan_api_upload: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_upload',
                  rule_name: 'limit_dependency_scanning_sbom_scan_api_uploads_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
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
                partner_aws_api: {
                  limiter_name: 'applimiter_partner_aws_api',
                  rule_name: 'limit_partner_aws_api_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
                },
                partner_gcp_api: {
                  limiter_name: 'applimiter_partner_gcp_api',
                  rule_name: 'limit_partner_gcp_api_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
                },
                partner_postman_api: {
                  limiter_name: 'applimiter_partner_postman_api',
                  rule_name: 'limit_partner_postman_api_by_project',
                  characteristics: %i[project],
                  action: :block,
                  flag_scope: :cohort_6
                },
                semantic_code_search_ad_hoc_indexing: {
                  limiter_name: 'applimiter_semantic_code_search_ad_hoc_indexing',
                  rule_name: 'limit_semantic_code_search_ad_hoc_indexing_by_namespace',
                  characteristics: %i[namespace],
                  action: :block,
                  flag_scope: :cohort_6
                },
                semantic_search_rate_limit: {
                  limiter_name: 'applimiter_semantic_search_rate_limit',
                  rule_name: 'limit_semantic_searches_by_user',
                  characteristics: %i[user],
                  action: :block,
                  flag_scope: :cohort_6
                },
                soft_phone_verification_transactions_limit: {
                  limiter_name: 'applimiter_soft_phone_verification_transactions_limit',
                  rule_name: 'limit_soft_phone_verification_transactions_by_scope',
                  characteristics: %i[scope],
                  action: :block,
                  flag_scope: :cohort_3
                },
                # Cohort 4: set-based unique-cardinality rate limits.
                # `count_distinct: :project_id` flips the rule from INCR to
                # SADD/SCARD on labkit; the SET member is the downloaded
                # project's id, set explicitly by the adapter (not class-routed
                # through characteristics, hence the `_id` suffix to make the
                # bare assignment unambiguous).
                #
                # Set-mode entries (those with `count_distinct:`) also opt out
                # of the adapter's threshold/interval override short-circuit
                # and route per-call `threshold:`/`interval:` through labkit's
                # `rule_context:` keyword. The namespace key carries
                # placeholder threshold/interval in the rate_limits registry
                # (real values live on namespace_settings and arrive per-call),
                # so this plumbing is load-bearing for it. Cohort 6 will
                # extend override-via-rule_context to INCR-mode keys that
                # need it via a separate signal.
                unique_project_downloads_for_application: {
                  limiter_name: 'applimiter_unique_project_downloads_for_application',
                  rule_name: 'limit_unique_project_downloads_by_user',
                  characteristics: %i[user],
                  count_distinct: :project_id,
                  action: :block,
                  flag_scope: :cohort_4
                },
                unique_project_downloads_for_namespace: {
                  limiter_name: 'applimiter_unique_project_downloads_for_namespace',
                  rule_name: 'limit_unique_project_downloads_by_user_namespace',
                  characteristics: %i[user namespace],
                  count_distinct: :project_id,
                  action: :block,
                  flag_scope: :cohort_4
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
