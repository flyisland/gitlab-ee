# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::WorkItems::TypeType, feature_category: :team_planning do
  include GraphqlHelpers

  describe '#supported_conversion_types' do
    let_it_be(:root_group) { create(:group) }
    let_it_be(:converted_task) do
      create(:work_item_custom_type, :converted_from_task, namespace: root_group, name: 'Subtask')
    end

    let(:issue_type) { build(:work_item_system_defined_type, :issue) }
    let(:user) { create(:user) }
    let(:context) { { resource_parent: root_group, current_user: user } }

    before do
      stub_licensed_features(configurable_work_item_types: true)
      stub_feature_flags(work_item_configurable_types: root_group)
    end

    subject(:result) do
      resolve_field(:supported_conversion_types, issue_type, ctx: context, current_user: user)
    end

    it 'returns custom type instead of replaced system type' do
      names = result.map(&:name)

      expect(names).to include('Subtask')
      expect(names).not_to include('Task')
    end

    it 'returns system-defined types not replaced by a custom type' do
      expect(result.map(&:name)).to include('Incident')
    end

    context 'when resource_parent is nil' do
      let(:context) { { resource_parent: nil, current_user: user } }

      it 'falls back to system-defined types' do
        names = result.map(&:name)

        expect(names).to include('Task')
        expect(names).not_to include('Subtask')
      end
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(work_item_configurable_types: false)
      end

      it 'returns system-defined types only' do
        names = result.map(&:name)

        expect(names).to include('Task')
        expect(names).not_to include('Subtask')
      end
    end
  end
end
