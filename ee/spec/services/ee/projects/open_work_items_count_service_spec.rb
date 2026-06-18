# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OpenWorkItemsCountService, :use_clean_rails_memory_store_caching,
  feature_category: :team_planning do
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:user)    { create(:user) }

  subject(:service) { described_class.new(project, user) }

  before_all do
    project.add_planner(user)
  end

  describe '#count' do
    let_it_be(:work_item)   { create(:work_item, :opened, project: project) }
    let_it_be(:test_case)   { create(:work_item, :test_case, :opened, project: project) }
    let_it_be(:requirement) { create(:work_item, :requirement, :opened, project: project) }

    it 'excludes test_case and requirement work items, counting only filterable types' do
      expect(service.count).to eq(1) # only the issue-type work_item
    end
  end

  describe '#relation_for_count' do
    it 'delegates to .query then excludes non-filterable types' do
      allow(described_class).to receive(:query).and_call_original

      expect(described_class).to receive(:query).with(project, public_only: false)

      service.count
    end

    context 'when there are no non-filterable types' do
      before do
        allow(service).to receive(:non_filterable_base_types).and_return([])
      end

      it 'returns the base query without type filtering' do
        expect(service.relation_for_count).to be_a(ActiveRecord::Relation)
      end
    end
  end
end
