# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Organization.workItemTypes', :with_current_organization, feature_category: :team_planning do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user, organizations: [current_organization]) }
  let_it_be(:all_system_defined_types) { ::WorkItems::TypesFramework::Provider.new.all }
  let_it_be(:all_system_defined_type_names) { all_system_defined_types.map(&:name) }

  let(:query_param) { { 'id' => current_organization.to_gid } }
  let(:query) do
    graphql_query_for('organization', query_param,
      'workItemTypes { nodes { id name widgetDefinitions { type } } }')
  end

  before do
    stub_licensed_features(configurable_work_item_types: true)
  end

  it 'returns work item types for the organization' do
    post_graphql(query, current_user: current_user)
    expect(graphql_data_at('organization', 'workItemTypes', 'nodes')).not_to be_empty
  end

  it 'returns system-defined work item types' do
    post_graphql(query, current_user: current_user)

    returned_types = graphql_data_at('organization', 'workItemTypes', 'nodes')
    type_names = returned_types.pluck('name')

    expect(type_names).to all(be_in(all_system_defined_type_names))

    expect(returned_types.size).to eq(all_system_defined_types.count)
  end

  context 'with custom work item types' do
    let!(:custom_work_item_type) do
      create(:work_item_custom_type, :with_organization, organization: current_organization)
    end

    it 'returns system-defined and custom work item types' do
      post_graphql(query, current_user: current_user)

      returned_types = graphql_data_at('organization', 'workItemTypes', 'nodes')
      type_names = returned_types.pluck('name')

      expect(type_names).to include(*all_system_defined_type_names)
      expect(type_names).to include(custom_work_item_type.name)

      expected_count = all_system_defined_types.count + 1
      expect(returned_types.size).to eq(expected_count)
    end

    context 'with converted work item types' do
      let!(:converted_custom_work_item_type) do
        create(:work_item_custom_type, :with_organization, :converted_from_issue,
          organization: current_organization, name: 'Issue V2')
      end

      it 'returns system-defined, custom and converted work item types' do
        post_graphql(query, current_user: current_user)

        returned_types = graphql_data_at('organization', 'workItemTypes', 'nodes')
        type_names = returned_types.pluck('name')

        converted_type_name = converted_custom_work_item_type.converted_from_system_defined_type.name
        system_defined_type_names = all_system_defined_type_names - [converted_type_name]

        expect(type_names).to include(*system_defined_type_names)
        expect(type_names).to include(custom_work_item_type.name, converted_custom_work_item_type.name)

        expected_count = all_system_defined_types.count + 1
        expect(returned_types.size).to eq(expected_count)
      end
    end

    context 'when work_item_configurable_types is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
        post_graphql(query, current_user: current_user)
      end

      it 'returns system-defined work item types' do
        returned_types = graphql_data_at('organization', 'workItemTypes', 'nodes')
        type_names = returned_types.pluck('name')

        expect(type_names).to all(be_in(all_system_defined_type_names))

        expect(type_names).not_to include(custom_work_item_type.name)

        expect(returned_types.size).to eq(all_system_defined_types.count)
      end
    end
  end

  context 'when organization id is not set' do
    let(:query_param) { {} }

    it 'returns work item types for the organization' do
      post_graphql(query, current_user: current_user)
      expect(graphql_data_at('organization', 'workItemTypes', 'nodes')).not_to be_empty
    end
  end
end
