# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mcp::Tools::WorkItems::GetSavedViewWorkItemsTool, feature_category: :mcp_server do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:params) { { group_id: group.id.to_s, filters: {}, sort: nil } }
  let(:tool) { described_class.new(current_user: user, params: params) }

  before_all do
    group.add_developer(user)
  end

  describe '.filter_definitions' do
    it 'includes EE-specific filter definitions' do
      keys = described_class.filter_definitions.pluck(:key)

      expect(keys).to include(
        'healthStatusFilter', 'iterationId', 'iterationWildcardId',
        'iterationCadenceId', 'weight', 'weightWildcardId',
        'status', 'customField'
      )
    end

    it 'preserves CE filter definitions' do
      keys = described_class.filter_definitions.pluck(:key)

      expect(keys).to include(
        'assigneeUsernames', 'labelName', 'milestoneTitle', 'state'
      )
    end

    it 'includes correct types for EE filters' do
      ee_filter_keys = %w[healthStatusFilter iterationId weight status customField]
      ee_filters = described_class.filter_definitions.select do |f|
        ee_filter_keys.include?(f[:key])
      end

      type_map = ee_filters.to_h { |f| [f[:key], f[:type]] }

      expect(type_map['healthStatusFilter']).to eq('HealthStatusFilter')
      expect(type_map['iterationId']).to eq('[ID]')
      expect(type_map['weight']).to eq('String')
      expect(type_map['status']).to eq('WorkItemWidgetStatusFilterInput')
      expect(type_map['customField']).to eq('[WorkItemWidgetCustomFieldFilterInputType!]')
    end
  end

  describe '.widget_fragments' do
    it 'includes EE-specific widget fragments' do
      fragments = described_class.widget_fragments
      combined = fragments.join

      expect(combined).to include('WorkItemWidgetHealthStatus')
      expect(combined).to include('WorkItemWidgetIteration')
      expect(combined).to include('WorkItemWidgetWeight')
      expect(combined).to include('WorkItemWidgetStatus')
      expect(combined).to include('WorkItemWidgetCustomFields')
    end

    it 'preserves CE widget fragments' do
      fragments = described_class.widget_fragments
      combined = fragments.join

      expect(combined).to include('WorkItemWidgetAssignees')
      expect(combined).to include('WorkItemWidgetLabels')
      expect(combined).to include('WorkItemWidgetMilestone')
    end
  end

  describe '.build_query' do
    it 'includes EE filter variables and arguments in the composed query' do
      query = described_class.build_query

      expect(query).to include('$healthStatusFilter: HealthStatusFilter')
      expect(query).to include('$iterationId: [ID]')
      expect(query).to include('$weight: String')
      expect(query).to include('$status: WorkItemWidgetStatusFilterInput')
      expect(query).to include('$customField: [WorkItemWidgetCustomFieldFilterInputType!]')

      expect(query).to include('healthStatusFilter: $healthStatusFilter')
      expect(query).to include('iterationId: $iterationId')
      expect(query).to include('weight: $weight')
      expect(query).to include('status: $status')
      expect(query).to include('customField: $customField')
    end

    it 'includes EE widget fragments' do
      query = described_class.build_query

      expect(query).to include('WorkItemWidgetHealthStatus')
      expect(query).to include('WorkItemWidgetIteration')
      expect(query).to include('WorkItemWidgetWeight')
      expect(query).to include('WorkItemWidgetStatus')
      expect(query).to include('WorkItemWidgetCustomFields')
    end
  end

  describe '#build_variables' do
    context 'with healthStatusFilter' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: { 'healthStatusFilter' => 'on_track' },
          sort: nil
        }
      end

      it 'transforms snake_case value to camelCase for the GraphQL enum' do
        variables = tool.build_variables

        expect(variables[:healthStatusFilter]).to eq('onTrack')
      end

      it 'does not report healthStatusFilter as unsupported' do
        tool.build_variables

        expect(tool.unsupported_filters).not_to include('healthStatusFilter')
      end
    end

    context 'with iteration filters' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'iterationId' => ['gid://gitlab/Iteration/1', 'gid://gitlab/Iteration/2'],
            'iterationWildcardId' => 'CURRENT',
            'iterationCadenceId' => ['gid://gitlab/Iterations::Cadence/10']
          },
          sort: nil
        }
      end

      it 'maps iteration filters to GraphQL variables' do
        variables = tool.build_variables

        expect(variables[:iterationId]).to match_array(%w[gid://gitlab/Iteration/1 gid://gitlab/Iteration/2])
        expect(variables[:iterationWildcardId]).to eq('CURRENT')
        expect(variables[:iterationCadenceId]).to eq(['gid://gitlab/Iterations::Cadence/10'])
      end

      it 'does not report iteration filters as unsupported' do
        tool.build_variables

        expect(tool.unsupported_filters).not_to include('iterationId', 'iterationWildcardId', 'iterationCadenceId')
      end
    end

    context 'with weight filters' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'weight' => '3',
            'weightWildcardId' => 'ANY'
          },
          sort: nil
        }
      end

      it 'maps weight filters to GraphQL variables' do
        variables = tool.build_variables

        expect(variables[:weight]).to eq('3')
        expect(variables[:weightWildcardId]).to eq('ANY')
      end

      it 'does not report weight filters as unsupported' do
        tool.build_variables

        expect(tool.unsupported_filters).not_to include('weight', 'weightWildcardId')
      end
    end

    context 'with status filter' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'status' => { 'name' => 'In Progress' }
          },
          sort: nil
        }
      end

      it 'maps status filter to GraphQL variables' do
        variables = tool.build_variables

        expect(variables[:status]).to eq({ 'name' => 'In Progress' })
      end

      it 'does not report status as unsupported' do
        tool.build_variables

        expect(tool.unsupported_filters).not_to include('status')
      end
    end

    context 'with customField filter' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'customField' => [
              {
                'customFieldId' => 'gid://gitlab/Issuables::CustomField/1',
                'selectedOptionIds' => ['gid://gitlab/Issuables::CustomFieldSelectOption/10']
              }
            ]
          },
          sort: nil
        }
      end

      it 'maps customField filter to GraphQL variables' do
        variables = tool.build_variables

        expect(variables[:customField]).to eq([
          {
            'customFieldId' => 'gid://gitlab/Issuables::CustomField/1',
            'selectedOptionIds' => ['gid://gitlab/Issuables::CustomFieldSelectOption/10']
          }
        ])
      end

      it 'does not report customField as unsupported' do
        tool.build_variables

        expect(tool.unsupported_filters).not_to include('customField')
      end
    end

    context 'with combined CE and EE filters' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'labelName' => ['bug'],
            'state' => 'opened',
            'healthStatusFilter' => 'needs_attention',
            'weight' => '5',
            'iterationWildcardId' => 'CURRENT'
          },
          sort: 'CREATED_DESC'
        }
      end

      it 'maps both CE and EE filters to GraphQL variables' do
        variables = tool.build_variables

        expect(variables[:labelName]).to eq(['bug'])
        expect(variables[:state]).to eq('opened')
        expect(variables[:healthStatusFilter]).to eq('needsAttention') # transformed from 'needs_attention'
        expect(variables[:weight]).to eq('5')
        expect(variables[:iterationWildcardId]).to eq('CURRENT')
        expect(variables[:sort]).to eq('CREATED_DESC')
      end

      it 'reports no unsupported filters' do
        tool.build_variables

        expect(tool.unsupported_filters).to be_empty
      end
    end

    context 'with negated healthStatusFilter' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'not' => { 'healthStatusFilter' => %w[on_track needs_attention] }
          },
          sort: nil
        }
      end

      it 'transforms snake_case values to camelCase inside not filter' do
        variables = tool.build_variables

        expect(variables[:not]).to eq({ 'healthStatusFilter' => %w[onTrack needsAttention] })
      end
    end

    context 'with negated filter containing non-transformable values' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'not' => {
              'healthStatusFilter' => 'at_risk',
              'weight' => '3'
            }
          },
          sort: nil
        }
      end

      it 'transforms only values with a defined transform' do
        variables = tool.build_variables

        expect(variables[:not]).to eq({
          'healthStatusFilter' => 'atRisk',
          'weight' => '3'
        })
      end
    end

    context 'with negated filter containing unknown nested keys' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'not' => {
              'healthStatusFilter' => ['on_track'],
              'unknownNestedFilter' => 'someValue'
            }
          },
          sort: nil
        }
      end

      it 'passes unknown nested keys through unchanged' do
        variables = tool.build_variables

        expect(variables[:not]).to eq({
          'healthStatusFilter' => ['onTrack'],
          'unknownNestedFilter' => 'someValue'
        })
      end
    end

    context 'with unsupported filters in EE context' do
      let(:params) do
        {
          group_id: group.id.to_s,
          filters: {
            'labelName' => ['bug'],
            'healthStatusFilter' => 'on_track',
            'someUnknownFilter' => 'value'
          },
          sort: nil
        }
      end

      it 'detects only truly unsupported filters' do
        tool.build_variables

        expect(tool.unsupported_filters).to contain_exactly('someUnknownFilter')
        expect(tool.unsupported_filters).not_to include('healthStatusFilter')
      end
    end
  end
end
