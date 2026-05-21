# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.complianceFrameworkTemplates', feature_category: :compliance_management do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  let(:fields) do
    <<~FIELDS
      id
      templateVersion
      name
      description
      color
      json
    FIELDS
  end

  let(:query) do
    graphql_query_for('complianceFrameworkTemplates', {}, fields)
  end

  context 'when compliance_framework_templates feature flag is disabled' do
    before do
      stub_feature_flags(compliance_framework_templates: false)
      post_graphql(query, current_user: current_user)
    end

    it 'returns a resource not available error' do
      expect(graphql_errors).to include(
        a_hash_including('message' => include("you don't have permission"))
      )
    end
  end

  context 'when user is not authenticated' do
    it 'returns an error' do
      post_graphql(query, current_user: nil)

      expect(graphql_errors).to be_present
    end
  end

  context 'when user is authenticated' do
    before do
      post_graphql(query, current_user: current_user)
    end

    it_behaves_like 'a working graphql query'

    it 'returns all templates' do
      templates = graphql_data['complianceFrameworkTemplates']

      expect(templates).to be_an(Array)
      expect(templates.size).to be >= 2
    end

    it 'returns expected fields for each template' do
      soc2_gid = "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
      template = graphql_data['complianceFrameworkTemplates'].find { |t| t['id'] == soc2_gid }

      expect(template['id']).to eq(soc2_gid)
      expect(template['templateVersion']).to eq(1)
      expect(template['name']).to eq('SOC 2')
      expect(template['description']).to be_present
      expect(template['color']).to be_present
      expect(template['json']).to be_present
      expect(Gitlab::Json.safe_parse(template['json'])).to be_a(Hash)
    end
  end

  context 'when filtering by id' do
    let(:query) do
      graphql_query_for('complianceFrameworkTemplates', {
        id: "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
      }, fields)
    end

    before do
      post_graphql(query, current_user: current_user)
    end

    it 'returns only the matching template' do
      templates = graphql_data['complianceFrameworkTemplates']

      expect(templates.size).to eq(1)
      expect(templates.first['id']).to eq(
        "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/soc2"
      )
    end
  end

  context 'when filtering by non-existent id' do
    let(:query) do
      graphql_query_for('complianceFrameworkTemplates', {
        id: "gid://gitlab/ComplianceManagement::Frameworks::TemplateRegistry::Template/nonexistent"
      }, fields)
    end

    before do
      post_graphql(query, current_user: current_user)
    end

    it 'returns an empty array' do
      templates = graphql_data['complianceFrameworkTemplates']

      expect(templates).to eq([])
    end
  end
end
