# frozen_string_literal: true

require 'spec_helper'

# The EE incident-management throttle (throttle_incident_management_notification_web)
# fires only on alerts/notify requests, and alerts_notify? requires web_request?,
# so it always co-fires with the general web throttle. Rack::Attack counts such a
# request under both throttles independently, so the Labkit shadow must too: the
# incident throttle lives in its own limiter (rack_request_incident_management,
# counted by path) while the web throttle stays in rack_request (counted by ip).
#
# This proves one alerts/notify request increments both counters once, in disjoint
# keyspaces, rather than one masking the other (which a shared limiter would cause,
# since the middleware records only the first throttle that fires per limiter).
RSpec.describe 'Labkit::RateLimit rack middleware (EE throttles)', :clean_gitlab_redis_rate_limiting, feature_category: :rate_limiting do
  include RackAttackSpecHelpers

  let(:path) { '/group/project/alerts/notify' }

  before do
    stub_application_setting(
      throttle_unauthenticated_enabled: true,
      throttle_incident_management_notification_enabled: true,
      throttle_incident_management_notification_per_period: 100,
      throttle_incident_management_notification_period_in_seconds: 60
    )

    # spec/support/rate_limiter_labkit_rack_shadow.rb stubs all cohort flags to
    # false globally to keep the shadow out of unrelated specs; re-enable both
    # cohorts here so the middleware actually runs for the throttles under test.
    stub_feature_flags(
      rate_limiter_use_labkit_rack_cohort_1: true,
      rate_limiter_use_labkit_rack_cohort_2: true
    )
  end

  # Sum every labkit counter under a limiter's keyspace. The ':' delimiter after
  # the limiter name keeps rack_request from matching rack_request_protected_paths
  # or rack_request_incident_management, so each limiter is counted in isolation.
  def labkit_total_for(limiter)
    Gitlab::Redis::RateLimiting.with do |redis|
      keys = redis.scan_each(match: "labkit:rl:{#{limiter}:*").to_a
      keys.sum { |key| redis.get(key).to_i }
    end
  end

  it 'counts one alerts/notify request in both the incident and web limiters' do
    post path

    expect(labkit_total_for('rack_request_incident_management')).to eq(1)
    expect(labkit_total_for('rack_request')).to eq(1)
  end

  # The tier-aware rollout must outlive the Rack::Attack migration flags.
  context 'with every migration cohort inactive' do
    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      stub_feature_flags(
        rate_limiter_use_labkit_rack_cohort_1: false,
        rate_limiter_use_labkit_rack_cohort_2: false,
        rate_limiter_use_labkit_rack_cohort_3: false,
        rate_limiter_plan_limits_free_info: true
      )
    end

    it 'still evaluates the rules when a plan flag is on' do
      post path

      expect(labkit_total_for('rack_request')).to eq(1)
    end

    it 'evaluates nothing when the plan flags are off too' do
      stub_feature_flags(rate_limiter_plan_limits_free_info: false)

      post path

      expect(labkit_total_for('rack_request')).to eq(0)
    end

    # The state after the cohort flags are deleted: no cohort to enumerate, so no
    # cohort flag is read at all and the plan flags are the only thing running it.
    context 'when the registry declares no cohorts at all' do
      before do
        allow(Gitlab::RackAttack::LabkitRateLimit::ThrottleRegistry).to receive(:cohorts).and_return([])
      end

      it 'still evaluates the rules' do
        post path

        expect(labkit_total_for('rack_request')).to eq(1)
      end
    end
  end

  describe 'the unauthenticated per-IP throttle' do
    let(:anonymous_path) { '/api/v4/projects' }

    before do
      stub_saas_features(gitlab_com_subscriptions: true)
      stub_feature_flags(
        rate_limiter_use_labkit_rack_cohort_1: false,
        rate_limiter_use_labkit_rack_cohort_2: false,
        rate_limiter_use_labkit_rack_cohort_3: false
      )
      # for_limiter reads the SaaS gate at build time and the rule set is memoized,
      # so it must be rebuilt after the stub or an earlier example's build wins.
      Gitlab::RackAttack::LabkitRateLimit::Limiters.reset!
    end

    after do
      Gitlab::RackAttack::LabkitRateLimit::Limiters.reset!
    end

    it 'counts an anonymous request once the info flag is on' do
      stub_feature_flags(rate_limiter_unauthenticated_limits_info: true)

      get anonymous_path

      expect(labkit_total_for('rack_request')).to eq(1)
    end

    it 'counts nothing while both flags are off' do
      get anonymous_path

      expect(labkit_total_for('rack_request')).to eq(0)
    end

    it 'counts nothing off GitLab.com even with the flag on' do
      stub_saas_features(gitlab_com_subscriptions: false)
      stub_feature_flags(rate_limiter_unauthenticated_limits_info: true)

      get anonymous_path

      expect(labkit_total_for('rack_request')).to eq(0)
    end
  end

  describe 'enforcement and the admin setting toggle' do
    before do
      stub_feature_flags(
        rate_limiter_use_labkit_rack_cohort_1: true,
        rate_limiter_use_labkit_rack_cohort_1_enforce: true
      )
    end

    it 'rejects requests over the rate limit with the full RateLimit-* header set', :aggregate_failures do
      stub_application_setting(
        throttle_incident_management_notification_enabled: true,
        throttle_incident_management_notification_per_period: 1,
        throttle_incident_management_notification_period_in_seconds: 60
      )

      post path
      expect(response).not_to have_gitlab_http_status(:too_many_requests)

      expect_rejection('throttle_incident_management_notification_web') { post path }
    end

    it 'does not block requests over the same limit when the throttle setting is disabled', :aggregate_failures do
      stub_application_setting(
        throttle_incident_management_notification_enabled: false,
        throttle_incident_management_notification_per_period: 1,
        throttle_incident_management_notification_period_in_seconds: 60
      )

      3.times do
        post path
        expect(response).not_to have_gitlab_http_status(:too_many_requests)
      end
    end
  end
end
