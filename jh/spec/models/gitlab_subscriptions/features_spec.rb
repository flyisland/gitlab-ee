# frozen_string_literal: true

require 'spec_helper'

JH_STARTER_AI_FEATURES = %i[
  ai_chat
  ai_catalog
  ai_workflows
  code_suggestions
  agentic_chat
  self_hosted_models
].freeze

RSpec.describe GitlabSubscriptions::Features, feature_category: :subscription_management do
  describe '.minimum_plan_for' do
    it 'preserves Team as the minimum plan for a legacy Starter feature' do
      expect(described_class.minimum_plan_for(:iterations)).to eq(License::TEAM_PLAN)
    end
  end

  describe '.plans_with_feature' do
    subject { described_class.plans_with_feature(describe) }

    it 'starter feature is in all plans' do
      (described_class::STARTER_FEATURES - described_class::GLOBAL_FEATURES).each do |feature|
        expectd_plans = described_class.plans_with_feature(feature)
        expect(expectd_plans).to contain_exactly(
          License::STARTER_PLAN, License::TEAM_PLAN, License::PREMIUM_PLAN, License::ULTIMATE_PLAN)
      end
    end

    context 'with JH starter AI features' do
      it 'includes them in JH_STARTER_FEATURES' do
        expect(described_class::JH_STARTER_FEATURES).to include(*JH_STARTER_AI_FEATURES)
      end

      it 'does not include them in EE starter features' do
        expect(described_class::EE_STARTER_FEATURES).not_to include(*JH_STARTER_AI_FEATURES)
      end
    end
  end

  describe '.saas_plans_with_feature' do
    subject { described_class.saas_plans_with_feature(feature) }

    describe 'a Premium feature' do
      let(:feature) { :epics }

      it 'is present in all Premium+ plans' do
        expected_plans = ::Plan::PAID_HOSTED_PLANS - [::Plan::BRONZE, ::Plan::TEAM]
        expect(subject).to match_array(expected_plans)
      end
    end

    describe 'an Ultimate feature' do
      let(:feature) { :dast }

      it 'is present in all top plans' do
        expected_plans = ::Plan::PAID_HOSTED_PLANS - [
          ::Plan::BRONZE, ::Plan::SILVER, ::Plan::PREMIUM, ::Plan::PREMIUM_TRIAL, ::Plan::TEAM
        ]
        expect(subject).to match_array(expected_plans)
      end
    end
  end

  describe 'JH specific license features' do
    let(:plan) {} # rubocop:disable Lint/EmptyBlock

    subject(:features) do
      described_class.features(plan: plan, add_ons: {})
    end

    context 'with starter plan' do
      let(:plan) { License::STARTER_PLAN }

      it "includes JH specific starter feature" do
        expect(features).to match_array(described_class::ALL_STARTER_FEATURES)

        expect(features).not_to include(*described_class::JH_PREMIUM_ADDITION)

        unless described_class::JH_ULTIMATE_ADDITION.empty?
          expect(features).not_to include(*described_class::JH_ULTIMATE_ADDITION)
        end
      end
    end

    context 'with premium plan' do
      let(:plan) { License::PREMIUM_PLAN }

      it "includes JH specific premium feature" do
        expect(features).to match_array(described_class::ALL_PREMIUM_FEATURES)
        expect(features).to include(*described_class::ALL_STARTER_FEATURES)

        expect(features).to include(*described_class::JH_STARTER_FEATURES)
        expect(features).to include(*described_class::EE_STARTER_FEATURES)
        expect(features).to include(*described_class::JH_PREMIUM_ADDITION)

        unless described_class::JH_ULTIMATE_ADDITION.empty?
          expect(features).not_to include(*described_class::JH_ULTIMATE_ADDITION)
        end
      end
    end

    context 'with ultimate plan' do
      let(:plan) { License::ULTIMATE_PLAN }

      it "includes JH specific ultimate feature" do
        expect(features).to include(*described_class::ALL_STARTER_FEATURES)
        expect(features).to include(*described_class::ALL_PREMIUM_FEATURES)
        expect(features).to match_array(described_class::ALL_ULTIMATE_FEATURES)
        expect(features).to include(*described_class::ULTIMATE_FEATURES_WITH_USAGE_PING)

        expect(features).to include(*described_class::JH_PREMIUM_ADDITION)

        unless described_class::JH_ULTIMATE_ADDITION.empty?
          expect(features).to include(*described_class::JH_ULTIMATE_ADDITION)
        end
      end
    end

    context 'for password_expiration' do
      it 'JH_STARTER_FEATURES should contain password_expiration' do
        expect(described_class::JH_STARTER_FEATURES).to include(:password_expiration)
      end
    end

    context 'for JH starter AI features' do
      context 'with premium plan' do
        let(:plan) { License::PREMIUM_PLAN }

        it 'includes JH starter AI features' do
          expect(features).to include(*JH_STARTER_AI_FEATURES)
        end
      end
    end
  end

  it 'ensures that there is no same names between licensed features and feature flags', :aggregate_failures do
    all_features = GitlabSubscriptions::Features::FEATURES_BY_PLAN.values.flatten
    skipped = %i[group_protected_branches password_expiration performance_analytics]

    all_features.each do |licensed_feature|
      next if licensed_feature.in?(skipped)

      expect { Feature.enabled?(licensed_feature) }.to raise_error(Feature::InvalidFeatureFlagError),
        "Licensed feature '#{licensed_feature}' has a matching feature flag. Please rename the feature or the FF"
    end
  end
end
