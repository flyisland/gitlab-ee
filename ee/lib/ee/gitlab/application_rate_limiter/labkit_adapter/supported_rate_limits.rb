# frozen_string_literal: true

module EE
  module Gitlab
    module ApplicationRateLimiter
      module LabkitAdapter
        # EE-only entries for the labkit rate-limit adapter, merged into
        # the CE registry via prepend. Mirrors the EE override of
        # Gitlab::ApplicationRateLimiter#rate_limits in
        # ee/lib/ee/gitlab/application_rate_limiter.rb so the registry
        # keys (and their limit/period) track the rate-limits map shape.
        #
        # See lib/gitlab/application_rate_limiter/labkit_adapter/supported_rate_limits.rb
        # for the conventions (AR-typed characteristics, limit/period, the
        # exclusion categories).
        module SupportedRateLimits
          extend ActiveSupport::Concern

          class_methods do
            extend ::Gitlab::Utils::Override

            override :entries
            def entries
              ce_entries = super

              ce_entries.merge(
                ai_catalog_item_report: {
                  limiter_name: 'applimiter_ai_catalog_item_report',
                  rule_name: 'limit_ai_catalog_item_reports_by_user',
                  characteristics: %i[user],
                  limit: 10,
                  period: 1.minute,
                  action: :block
                },
                code_suggestions_connection_details: {
                  limiter_name: 'applimiter_code_suggestions_connection_details',
                  rule_name: 'limit_code_suggestions_connection_details_by_user',
                  characteristics: %i[user],
                  limit: 10,
                  period: 1.minute,
                  action: :block
                },
                code_suggestions_direct_access: {
                  limiter_name: 'applimiter_code_suggestions_direct_access',
                  rule_name: 'limit_code_suggestions_direct_access_by_user',
                  characteristics: %i[user],
                  limit: 50,
                  period: 1.minute,
                  action: :block
                },
                container_scanning_for_registry_scans: {
                  limiter_name: 'applimiter_container_scanning_for_registry_scans',
                  rule_name: 'limit_container_scanning_for_registry_scans_by_project',
                  characteristics: %i[project],
                  limit: 50,
                  period: 1.day,
                  action: :block
                },
                create_duo_otel_workflow: {
                  limiter_name: 'applimiter_create_duo_otel_workflow',
                  rule_name: 'limit_duo_otel_workflow_creates_by_user',
                  characteristics: %i[user],
                  limit: 5,
                  period: 1.minute,
                  action: :block
                },
                credit_card_verification_check_for_reuse: {
                  limiter_name: 'applimiter_credit_card_verification_check_for_reuse',
                  rule_name: 'limit_credit_card_verification_reuse_checks_by_ip',
                  characteristics: %i[ip],
                  limit: 10,
                  period: 1.hour,
                  action: :block
                },
                dependency_scanning_sbom_scan_api_download: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_download',
                  rule_name: 'limit_dependency_scanning_sbom_scan_api_downloads_by_project',
                  characteristics: %i[project],
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.dependency_scanning_sbom_scan_api_download_limit
                  },
                  period: 1.hour,
                  action: :block
                },
                dependency_scanning_sbom_scan_api_throttling: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_throttling',
                  rule_name: 'limit_sbom_scan_api_by_project',
                  characteristics: %i[project],
                  limit: 50,
                  period: 1.hour,
                  action: :block
                },
                dependency_scanning_sbom_scan_api_upload: {
                  limiter_name: 'applimiter_dependency_scanning_sbom_scan_api_upload',
                  rule_name: 'limit_dependency_scanning_sbom_scan_api_uploads_by_project',
                  characteristics: %i[project],
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.dependency_scanning_sbom_scan_api_upload_limit
                  },
                  period: 1.hour,
                  action: :block
                },
                duo_workflow_direct_access: {
                  limiter_name: 'applimiter_duo_workflow_direct_access',
                  rule_name: 'limit_duo_workflow_direct_access_by_user',
                  characteristics: %i[user],
                  limit: 50,
                  period: 1.minute,
                  action: :block
                },
                hard_phone_verification_transactions_limit: {
                  limiter_name: 'applimiter_hard_phone_verification_transactions_limit',
                  rule_name: 'limit_hard_phone_verification_transactions_by_scope',
                  characteristics: %i[scope],
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.hard_phone_verification_transactions_daily_limit
                  },
                  period: 1.day,
                  action: :block
                },
                orbit_query: {
                  limiter_name: 'applimiter_orbit_query',
                  rule_name: 'limit_orbit_queries_by_user',
                  characteristics: %i[user],
                  limit: 60,
                  period: 1.minute,
                  action: :block
                },
                package_metadata: {
                  limiter_name: 'applimiter_package_metadata',
                  rule_name: 'limit_package_metadata_queries_by_user',
                  characteristics: %i[user],
                  limit: 1000,
                  period: 1.hour,
                  action: :block
                },
                partner_aws_api: {
                  limiter_name: 'applimiter_partner_aws_api',
                  rule_name: 'limit_partner_aws_api_by_project',
                  characteristics: %i[project],
                  limit: 400,
                  period: 1.second,
                  action: :block
                },
                partner_gcp_api: {
                  limiter_name: 'applimiter_partner_gcp_api',
                  rule_name: 'limit_partner_gcp_api_by_project',
                  characteristics: %i[project],
                  limit: 500,
                  period: 1.second,
                  action: :block
                },
                partner_postman_api: {
                  limiter_name: 'applimiter_partner_postman_api',
                  rule_name: 'limit_partner_postman_api_by_project',
                  characteristics: %i[project],
                  limit: 4,
                  period: 1.second,
                  action: :block
                },
                semantic_code_search_ad_hoc_indexing: {
                  limiter_name: 'applimiter_semantic_code_search_ad_hoc_indexing',
                  rule_name: 'limit_semantic_code_search_ad_hoc_indexing_by_namespace',
                  characteristics: %i[namespace],
                  limit: 10,
                  period: 1.hour,
                  action: :block
                },
                semantic_search_rate_limit: {
                  limiter_name: 'applimiter_semantic_search_rate_limit',
                  rule_name: 'limit_semantic_searches_by_user',
                  characteristics: %i[user],
                  limit: 10,
                  period: 1.minute,
                  action: :block
                },
                soft_phone_verification_transactions_limit: {
                  limiter_name: 'applimiter_soft_phone_verification_transactions_limit',
                  rule_name: 'limit_soft_phone_verification_transactions_by_scope',
                  characteristics: %i[scope],
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.soft_phone_verification_transactions_daily_limit
                  },
                  period: 1.day,
                  action: :block
                },
                # Set-based unique-cardinality rate limits.
                # `count_distinct: :project_id` flips the rule from INCR to
                # SADD/SCARD on labkit; the SET member is the downloaded
                # project's id, set explicitly by the adapter (not class-routed
                # through characteristics, hence the `_id` suffix to make the
                # bare assignment unambiguous).
                #
                # Per-call `threshold:`/`interval:` overrides route through
                # labkit's `rule_context:` keyword for every key. The namespace
                # key carries placeholder limit/period (0/0, matching the legacy
                # registry); real values live on namespace_settings and arrive
                # per-call, so this plumbing is load-bearing for it.
                unique_project_downloads_for_application: {
                  limiter_name: 'applimiter_unique_project_downloads_for_application',
                  rule_name: 'limit_unique_project_downloads_by_user',
                  characteristics: %i[user],
                  count_distinct: :project_id,
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.max_number_of_repository_downloads
                  },
                  period: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.max_number_of_repository_downloads_within_time_period
                  },
                  action: :block
                },
                unique_project_downloads_for_namespace: {
                  limiter_name: 'applimiter_unique_project_downloads_for_namespace',
                  rule_name: 'limit_unique_project_downloads_by_user_namespace',
                  characteristics: %i[user namespace],
                  count_distinct: :project_id,
                  limit: 0,
                  period: 0,
                  action: :block
                },
                virtual_registries_endpoints_api_limit: {
                  limiter_name: 'applimiter_virtual_registries_endpoints_api_limit',
                  rule_name: 'limit_virtual_registries_endpoints_api_by_ip_group',
                  characteristics: %i[ip group],
                  limit: -> {
                    ::Gitlab::CurrentSettings.current_application_settings.virtual_registries_endpoints_api_limit
                  },
                  period: 15.seconds,
                  action: :block
                }
              ).merge(
                # EE overrides the threshold/interval of these two CE keys
                # (see the EE override of ApplicationRateLimiter#rate_limits),
                # so override only their registry limit/period here, keeping the
                # CE structural fields (limiter_name/rule_name/characteristics)
                # as the single definition.
                code_suggestions_api_endpoint: ce_entries.fetch(:code_suggestions_api_endpoint).merge(
                  limit: 60,
                  period: 1.minute
                ),
                geo_proxy: ce_entries.fetch(:geo_proxy).merge(
                  limit: 3600,
                  period: 1.minute
                )
              )
            end
          end
        end
      end
    end
  end
end
