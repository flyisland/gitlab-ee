# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RateLimit::PlanRules, feature_category: :rate_limiting do
  describe '.flags' do
    it 'is the eight flags the design document names' do
      expect(described_class.flags).to contain_exactly(
        :rate_limiter_plan_limits_free_info,
        :rate_limiter_plan_limits_free_enforce,
        :rate_limiter_plan_limits_premium_info,
        :rate_limiter_plan_limits_premium_enforce,
        :rate_limiter_plan_limits_ultimate_info,
        :rate_limiter_plan_limits_ultimate_enforce,
        :rate_limiter_unauthenticated_limits_info,
        :rate_limiter_unauthenticated_limits_enforce
      )
    end

    # An unmatched name silently leaves the real flag on across the suite.
    it 'names only flags with a definition' do
      described_class.flags.each do |flag|
        expect(Feature::Definition.get(flag)).to be_present, "#{flag} has no definition file"
      end
    end
  end

  describe '.active?' do
    context 'on GitLab.com' do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
      end

      it 'is false while every flag is off' do
        expect(described_class.active?).to be(false)
      end

      # Driven off .flags so a flag added there without a matching read fails here.
      described_class.flags.each do |flag|
        it "is true when #{flag} alone is on" do
          stub_feature_flags(flag => true)

          expect(described_class.active?).to be(true)
        end
      end

      it 'reflects a flag flip rather than memoizing' do
        expect(described_class.active?).to be(false)

        stub_feature_flags(rate_limiter_plan_limits_free_info: true)

        expect(described_class.active?).to be(true)
      end

      it 'reads every flag with the request as actor and the derisk type' do
        allow(::Feature).to receive(:enabled?).and_return(false)

        described_class.active?

        described_class.flags.each do |flag|
          expect(::Feature).to have_received(:enabled?)
            .with(flag, ::Feature.current_request, type: :gitlab_com_derisk)
        end
      end
    end

    context 'when not on GitLab.com' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
        stub_feature_flags(described_class.flags.index_with(true))
      end

      it 'is false even with every flag on' do
        expect(described_class.active?).to be(false)
      end

      it 'rules the limits out before reading any flag' do
        expect(::Feature).not_to receive(:enabled?)

        described_class.active?
      end
    end
  end

  describe '.for_limiter' do
    let(:general) { ::Gitlab::RackAttack::LabkitRateLimit::ThrottleRegistry::GENERAL }
    let(:protected_paths) { ::Gitlab::RackAttack::LabkitRateLimit::ThrottleRegistry::PROTECTED }

    context 'on GitLab.com' do
      before do
        stub_saas_features(gitlab_com_subscriptions: true)
      end

      it 'is the two unauthenticated rules for the general limiter' do
        expect(described_class.for_limiter(general).map(&:name)).to eq(
          %w[unauthenticated_traffic_per_ip unauthenticated_traffic_per_ip_log]
        )
      end

      it 'is empty for the protected paths limiter' do
        expect(described_class.for_limiter(protected_paths)).to be_empty
      end

      describe 'the rule pair' do
        let(:enforcing) { described_class.for_limiter(general).find { |rule| rule.action == :limit } }
        let(:logging) { described_class.for_limiter(general).find { |rule| rule.action == :log } }

        it 'is 60 an hour per IP on both, the published unauthenticated ceiling', :aggregate_failures do
          [enforcing, logging].each do |rule|
            expect(rule.limit).to eq(60)
            expect(rule.period).to eq(1.hour)
            expect(rule.characteristics).to eq(%i[ip])
          end
        end

        it 'matches only a request with no requester and no runner', :aggregate_failures do
          [enforcing, logging].each do |rule|
            expect(rule.match[:requester_id].match?(nil)).to be(true)
            expect(rule.match[:requester_id].match?('42')).to be(false)
            expect(rule.match[:runner_id].match?(nil)).to be(true)
            expect(rule.match[:runner_id].match?('7')).to be(false)
          end
        end

        it 'splits on unauthenticated_enforced', :aggregate_failures do
          expect(enforcing.match[:unauthenticated_enforced].match?(true)).to be(true)
          expect(enforcing.match[:unauthenticated_enforced].match?(false)).to be(false)
          expect(logging.match[:unauthenticated_enforced].match?(false)).to be(true)
          expect(logging.match[:unauthenticated_enforced].match?(true)).to be(false)
        end

        it 'requires unauthenticated_limits_active on both', :aggregate_failures do
          [enforcing, logging].each do |rule|
            expect(rule.match[:unauthenticated_limits_active].match?(true)).to be(true)
            expect(rule.match[:unauthenticated_limits_active].match?(false)).to be(false)
          end
        end
      end
    end

    context 'when not on GitLab.com' do
      before do
        stub_saas_features(gitlab_com_subscriptions: false)
      end

      it 'is empty for the general limiter' do
        expect(described_class.for_limiter(general)).to be_empty
      end
    end
  end
end
