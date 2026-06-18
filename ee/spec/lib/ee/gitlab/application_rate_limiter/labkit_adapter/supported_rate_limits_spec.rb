# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::ApplicationRateLimiter::LabkitAdapter::SupportedRateLimits,
  :clean_gitlab_redis_rate_limiting, :prometheus, feature_category: :system_access do
  subject(:all) { Gitlab::ApplicationRateLimiter::LabkitAdapter::SupportedRateLimits.all }

  describe '.entries' do
    it 'merges EE-only keys on top of the CE registry' do
      expect(all).to include(
        :ai_catalog_item_report,
        :code_suggestions_connection_details,
        :code_suggestions_direct_access,
        :code_suggestions_x_ray_dependencies,
        :code_suggestions_x_ray_scan,
        :container_scanning_for_registry_scans,
        :create_duo_otel_workflow,
        :credit_card_verification_check_for_reuse,
        :dependency_scanning_sbom_scan_api_download,
        :dependency_scanning_sbom_scan_api_throttling,
        :dependency_scanning_sbom_scan_api_upload,
        :duo_workflow_direct_access,
        :hard_phone_verification_transactions_limit,
        :orbit_query,
        :package_metadata,
        :partner_aws_api,
        :partner_gcp_api,
        :partner_postman_api,
        :semantic_code_search_ad_hoc_indexing,
        :semantic_search_rate_limit,
        :soft_phone_verification_transactions_limit,
        :virtual_registries_endpoints_api_limit
      )
    end

    it 'preserves CE entries' do
      expect(all).to include(:pipelines_create, :ai_action, :web_hook_test)
    end

    it 'lets the labkit adapter dispatch an EE key through run!' do
      user = build_stubbed(:user)

      Gitlab::ApplicationRateLimiter::LabkitAdapter.run!(:ai_catalog_item_report, scope: user)

      expected_key = "labkit:rl:applimiter_ai_catalog_item_report:limit_ai_catalog_item_reports_by_user:user:#{user.id}"
      count = Gitlab::Redis::RateLimiting.with { |r| r.get(expected_key) }

      expect(count.to_i).to eq(1)
    end

    it 'tags every cohort-2 EE entry with flag_scope: :cohort_2' do
      ee_keys = %i[
        ai_catalog_item_report
        code_suggestions_connection_details
        code_suggestions_direct_access
        code_suggestions_x_ray_dependencies
        code_suggestions_x_ray_scan
        create_duo_otel_workflow
        credit_card_verification_check_for_reuse
        dependency_scanning_sbom_scan_api_throttling
        duo_workflow_direct_access
        orbit_query
        package_metadata
        virtual_registries_endpoints_api_limit
      ]

      ee_keys.each do |key|
        expect(all[key][:flag_scope]).to eq(:cohort_2), "expected #{key} to be flag_scope: :cohort_2"
      end
    end

    it 'tags every cohort-3 EE entry with flag_scope: :cohort_3' do
      cohort_3_keys = %i[
        hard_phone_verification_transactions_limit
        soft_phone_verification_transactions_limit
      ]

      cohort_3_keys.each do |key|
        expect(all[key][:flag_scope]).to eq(:cohort_3), "expected #{key} to be flag_scope: :cohort_3"
      end
    end

    it 'routes a cohort-4 application key end-to-end as SADD/SCARD' do
      user = build_stubbed(:user)
      project_a = build_stubbed(:project)
      project_b = build_stubbed(:project)

      Gitlab::ApplicationRateLimiter::LabkitAdapter.run!(:unique_project_downloads_for_application,
        scope: user, context: { resource_id: project_a.id, threshold: 5, interval: 600 })
      Gitlab::ApplicationRateLimiter::LabkitAdapter.run!(:unique_project_downloads_for_application,
        scope: user, context: { resource_id: project_b.id, threshold: 5, interval: 600 })

      expected_key = "labkit:rl:applimiter_unique_project_downloads_for_application" \
        ":limit_unique_project_downloads_by_user:user:#{user.id}"
      members = Gitlab::Redis::RateLimiting.with { |r| r.smembers(expected_key) }

      expect(members).to contain_exactly(project_a.id.to_s, project_b.id.to_s)
    end

    # The cohort-1/2/3 equivalents live in the CE adapter spec; cohort 4 keys
    # are EE-only, so the cohort-4 flag-basis assertion belongs here where the
    # registry merges them in.
    it 'reads the cohort-wide flag for cohort 4 entries' do
      expect(Gitlab::ApplicationRateLimiter::LabkitAdapter.shadow_or_enforce?(
        :unique_project_downloads_for_application, context: {})).to be(true)

      stub_feature_flags(rate_limiter_use_labkit_cohort_4: false)
      expect(Gitlab::ApplicationRateLimiter::LabkitAdapter.shadow_or_enforce?(
        :unique_project_downloads_for_application, context: {})).to be(false)
    end

    # Regression guard for the BaseThrottleService flow: initialize calls
    # rate_limited?(peek: true) and execute calls rate_limited?, so every
    # request invokes the same key twice. If peek accidentally SADDed, the
    # Redis SET would carry 2x cardinality per request and ban users at
    # half the configured threshold.
    it 'does not SADD on peek when both peek and check share the same call site' do
      user = build_stubbed(:user)
      project = build_stubbed(:project)
      stub_feature_flags(rate_limiter_use_labkit_cohort_4: true,
        rate_limiter_use_labkit_cohort_4_enforce: false)
      allow(Gitlab::CurrentSettings.current_application_settings).to receive_messages(
        max_number_of_repository_downloads: 10,
        max_number_of_repository_downloads_within_time_period: 600
      )

      Gitlab::ApplicationRateLimiter.throttled?(:unique_project_downloads_for_application,
        scope: user, resource: project, threshold: 10, interval: 600, peek: true)
      Gitlab::ApplicationRateLimiter.throttled?(:unique_project_downloads_for_application,
        scope: user, resource: project, threshold: 10, interval: 600)

      expected_key = "labkit:rl:applimiter_unique_project_downloads_for_application" \
        ":limit_unique_project_downloads_by_user:user:#{user.id}"
      members = Gitlab::Redis::RateLimiting.with { |r| r.smembers(expected_key) }

      expect(members).to contain_exactly(project.id.to_s)
    end

    it 'routes a cohort-4 namespace key with a user+namespace bucket' do
      user = build_stubbed(:user)
      namespace = build_stubbed(:group)
      project = build_stubbed(:project)

      Gitlab::ApplicationRateLimiter::LabkitAdapter.run!(:unique_project_downloads_for_namespace,
        scope: [user, namespace],
        context: { resource_id: project.id, threshold: 10, interval: 600 })

      expected_key = "labkit:rl:applimiter_unique_project_downloads_for_namespace" \
        ":limit_unique_project_downloads_by_user_namespace" \
        ":user:#{user.id}:namespace:#{namespace.id}"
      members = Gitlab::Redis::RateLimiting.with { |r| r.smembers(expected_key) }

      expect(members).to contain_exactly(project.id.to_s)
    end

    it 'tags every cohort-6 EE entry with flag_scope: :cohort_6' do
      cohort_6_keys = %i[
        container_scanning_for_registry_scans
        dependency_scanning_sbom_scan_api_download
        dependency_scanning_sbom_scan_api_upload
        semantic_code_search_ad_hoc_indexing
        semantic_search_rate_limit
      ]

      cohort_6_keys.each do |key|
        expect(all[key][:flag_scope]).to eq(:cohort_6), "expected #{key} to be flag_scope: :cohort_6"
      end
    end

    it 'lets the labkit adapter peek-dispatch an EE cohort-3 key with a Symbol :global scope' do
      Gitlab::ApplicationRateLimiter::LabkitAdapter.run!(:hard_phone_verification_transactions_limit, scope: :global)

      expect(
        Gitlab::ApplicationRateLimiter::LabkitAdapter.run_peek!(
          :hard_phone_verification_transactions_limit, scope: :global
        )
      ).to be(false)

      expected_key = "labkit:rl:applimiter_hard_phone_verification_transactions_limit" \
        ":limit_hard_phone_verification_transactions_by_scope:scope:global"
      count = Gitlab::Redis::RateLimiting.with { |r| r.get(expected_key) }

      expect(count.to_i).to eq(1)
    end
  end
end
