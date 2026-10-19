# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Querying a project\'s triage and remediation coverage', feature_category: :security_asset_inventories do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:query) do
    graphql_query_for(:project, { full_path: project.full_path },
      query_graphql_field(:triage_and_remediation_coverage, {}, 'capabilities { triggerType enabled runMode }'))
  end

  let(:coverage_data) { graphql_data_at(:project, :triage_and_remediation_coverage) }

  before do
    stub_licensed_features(security_scan_profiles: true)
  end

  context 'when the project is not licensed for security scan profiles' do
    before do
      stub_licensed_features(security_scan_profiles: false)
    end

    it 'returns null for the field', :aggregate_failures do
      post_graphql(query, current_user: user)

      expect(graphql_errors).to be_nil
      expect(graphql_data_at(:project)).to include('triageAndRemediationCoverage' => nil)
    end
  end

  context 'when the user cannot read security scan profiles' do
    let_it_be(:reporter) { create(:user, reporter_of: project) }

    it 'returns null for the field', :aggregate_failures do
      post_graphql(query, current_user: reporter)

      expect(graphql_errors).to be_nil
      expect(graphql_data_at(:project)).to include('triageAndRemediationCoverage' => nil)
    end
  end

  context 'when the project has no security_inventory_filters row' do
    it 'returns a zero-valued capability for every trigger type' do
      post_graphql(query, current_user: user)

      expect(graphql_errors).to be_nil
      expect(coverage_data['capabilities']).to contain_exactly(
        { 'triggerType' => 'SBOM_INGESTED', 'enabled' => false, 'runMode' => nil },
        { 'triggerType' => 'SAST_FALSE_POSITIVE', 'enabled' => false, 'runMode' => nil },
        { 'triggerType' => 'SAST_VULNERABILITY_RESOLUTION', 'enabled' => false, 'runMode' => nil },
        { 'triggerType' => 'SECRET_DETECTION_FALSE_POSITIVE', 'enabled' => false, 'runMode' => nil },
        { 'triggerType' => 'VULNERABILITY_ENRICHMENT', 'enabled' => false, 'runMode' => nil }
      )
    end
  end

  context 'when the project has capabilities attached' do
    before do
      create(:security_inventory_filters, project: project,
        triage_capabilities: {
          sbom_ingested: [true, false],
          sast_false_positive: [true, true],
          sast_vulnerability_resolution: [true, false]
        })
    end

    it 'returns the enabled state and run mode for each trigger type' do
      post_graphql(query, current_user: user)

      expect(graphql_errors).to be_nil
      expect(coverage_data['capabilities']).to contain_exactly(
        { 'triggerType' => 'SBOM_INGESTED', 'enabled' => true, 'runMode' => nil },
        { 'triggerType' => 'SAST_FALSE_POSITIVE', 'enabled' => true, 'runMode' => 'AUTO' },
        { 'triggerType' => 'SAST_VULNERABILITY_RESOLUTION', 'enabled' => true, 'runMode' => 'MANUAL' },
        { 'triggerType' => 'SECRET_DETECTION_FALSE_POSITIVE', 'enabled' => false, 'runMode' => nil },
        { 'triggerType' => 'VULNERABILITY_ENRICHMENT', 'enabled' => false, 'runMode' => nil }
      )
    end

    it_behaves_like 'authorizing granular token permissions for GraphQL',
      %i[read_project read_security_scan_profiles] do
      let(:boundary_object) { project }
      let(:request) { post_graphql(query, token: { personal_access_token: pat }) }
    end
  end
end
