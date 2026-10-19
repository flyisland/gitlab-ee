# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.group.orbitAccess', :saas, :clean_gitlab_redis_rate_limiting,
  feature_category: :knowledge_graph do
  include GraphqlHelpers

  let_it_be(:group) { create(:group, :private) }
  let_it_be(:owner) { create(:user, owner_of: group) }
  let_it_be(:member) { create(:user, developer_of: group) }
  let_it_be(:admin) { create(:admin) }

  let(:current_user) { owner }
  let(:trial) do
    Gitlab::SubscriptionPortal::ProductTrialResponse.new(
      state: :trial, trial_expires_at: Time.utc(2026, 10, 29, 23, 59, 59), credits_remaining: 120.0
    )
  end

  let(:access_fields) do
    'orbitAccess { state reason turnOnDenialReason trial { state } }'
  end

  let(:query) do
    graphql_query_for(:group, { full_path: group.full_path }, access_fields)
  end

  before do
    stub_config(knowledge_graph: { 'enabled' => true })
    stub_licensed_features(orbit: true)
    stub_feature_flags(orbit_trial: group)
    allow(Gitlab::SubscriptionPortal::Client).to receive(:product_trial).and_return(trial)
  end

  context 'as the group owner' do
    it 'returns the access state and the trial' do
      post_graphql(query, current_user: owner)

      expect(graphql_data_at(:group, :orbit_access)).to include(
        'state' => 'TRIAL_ACTIVE', 'reason' => nil, 'trial' => { 'state' => 'ACTIVE' }
      )
    end
  end

  context 'when the group can start a trial' do
    let(:trial) do
      Gitlab::SubscriptionPortal::ProductTrialResponse.new(
        state: :trial_eligible, offer_duration_days: 30, offer_credits: 100.0
      )
    end

    let(:access_fields) { 'orbitAccess { trial { offer { durationDays initialCredits } } }' }

    it 'returns the terms of the trial' do
      post_graphql(query, current_user: owner)

      expect(graphql_data_at(:group, :orbit_access, :trial, :offer)).to eq(
        'durationDays' => 30, 'initialCredits' => 100.0
      )
    end
  end

  context 'as an instance admin', :enable_admin_mode do
    it 'reads the state like an owner' do
      post_graphql(query, current_user: admin)

      expect(graphql_data_at(:group, :orbit_access, :state)).to eq('TRIAL_ACTIVE')
    end
  end

  context 'as a group member below owner' do
    it 'returns no access state and never calls CustomersDot' do
      expect(Gitlab::SubscriptionPortal::Client).not_to receive(:product_trial)

      post_graphql(query, current_user: member)

      expect(graphql_data_at(:group, :orbit_access)).to be_nil
    end
  end

  context 'when CustomersDot does not answer and Orbit is on' do
    let_it_be(:enabled_namespace) do
      create(:knowledge_graph_enabled_namespace, namespace: group)
    end

    let(:error) { Gitlab::SubscriptionPortal::ProductTrialResponse::UnavailableError.new('HTTP 503') }
    let(:query) do
      graphql_query_for(:group, { full_path: group.full_path }, 'knowledgeGraphEnabled orbitAccess { state }')
    end

    before do
      allow(Gitlab::SubscriptionPortal::Client).to receive(:product_trial).and_raise(error)
    end

    it 'reports the trial status as unavailable without an error' do
      expect(Gitlab::ErrorTracking).to receive(:track_exception).with(error, gl_namespace_id: group.id)

      post_graphql(query, current_user: owner)

      expect(graphql_errors).to be_nil
      expect(graphql_data_at(:group)).to eq(
        'knowledgeGraphEnabled' => true, 'orbitAccess' => { 'state' => 'TRIAL_STATUS_UNAVAILABLE' }
      )
    end
  end
end
