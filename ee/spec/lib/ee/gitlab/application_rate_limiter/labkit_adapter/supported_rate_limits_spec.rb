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
        :create_duo_otel_workflow,
        :credit_card_verification_check_for_reuse,
        :dependency_scanning_sbom_scan_api_throttling,
        :duo_workflow_direct_access,
        :hard_phone_verification_transactions_limit,
        :orbit_query,
        :package_metadata,
        :soft_phone_verification_transactions_limit,
        :virtual_registries_endpoints_api_limit
      )
    end

    it 'preserves CE entries' do
      expect(all).to include(:pipelines_create, :ai_action, :web_hook_test)
    end

    it 'lets the labkit adapter dispatch an EE key through run!' do
      user = create(:user)

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
