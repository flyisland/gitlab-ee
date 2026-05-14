# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::TypesFramework::HasType, feature_category: :team_planning do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:custom_type) { create(:work_item_custom_type, namespace: group) }
  let_it_be(:converted_type) { create(:work_item_custom_type, :converted_from_incident, namespace: group) }

  let(:provider) { WorkItems::TypesFramework::Provider.new(project) }

  describe '#work_item_type=' do
    let(:work_item) { create(:work_item, project: project) }

    context 'with a converted custom type' do
      it 'stores the system-defined type ID instead of the custom type AR ID' do
        resolved = provider.find_by_id(converted_type.converted_from_system_defined_type_identifier)

        work_item.clear_memoization(:work_items_types_provider) # Use fresh provider instance
        work_item.work_item_type = resolved

        expect(work_item.work_item_type_id).to eq(converted_type.converted_from_system_defined_type_identifier)
      end
    end

    context 'with a non-converted custom type' do
      it 'stores the custom type AR ID' do
        resolved = provider.find_by_id(custom_type.id)

        work_item.clear_memoization(:work_items_types_provider) # Use fresh provider instance
        work_item.work_item_type = resolved

        expect(work_item.work_item_type_id).to eq(custom_type.id)
      end
    end

    context 'with a system-defined type' do
      it 'stores the system-defined type ID' do
        issue_type = provider.find_by_id(::WorkItems::TypesFramework::Provider.new.default_issue_type.id)

        work_item.work_item_type = issue_type

        expect(work_item.work_item_type_id).to eq(::WorkItems::TypesFramework::Provider.new.default_issue_type.id)
      end
    end
  end
end
