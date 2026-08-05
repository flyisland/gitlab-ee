# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying available security scan profiles', feature_category: :security_testing_configuration do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let_it_be(:scan_profile) do
    create(:security_scan_profile, :dependency_scanning_post_processing,
      namespace: group,
      configuration: { 'auto_remediation' => { 'severity_level' => 'critical' } })
  end

  let(:profiles_field) do
    query_graphql_field(
      :available_security_scan_profiles,
      { type: :DEPENDENCY_SCANNING_POST_PROCESSING },
      'configuration'
    )
  end

  let(:query) do
    graphql_query_for(:group, { full_path: group.full_path }, profiles_field)
  end

  before_all do
    group.add_developer(user)
  end

  before do
    stub_licensed_features(security_scan_profiles: true)
  end

  it 'returns the effective configuration, merging the persisted override with defaults' do
    post_graphql(query, current_user: user)

    configuration = graphql_data_at(:group, :available_security_scan_profiles, 0, :configuration)

    expect(configuration).to include(
      'auto_remediation' => a_hash_including(
        'severity_level' => 'critical',
        'cooldown' => 7
      )
    )
  end
end
