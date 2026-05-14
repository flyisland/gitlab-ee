# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectPushRuleFinder, feature_category: :source_code_management do
  let_it_be(:project) { create(:project) }

  subject(:finder) { described_class.new(project) }

  describe '#execute' do
    context 'when read_project_push_rules is enabled' do
      let!(:project_push_rule) { create(:project_push_rule, project: project) }

      it 'returns the project push rule' do
        expect(finder.execute).to eq(project_push_rule)
      end
    end

    context 'when read_project_push_rules is disabled' do
      before do
        stub_feature_flags(read_project_push_rules: false)
      end

      let!(:push_rule) { create(:push_rule, project: project) }

      it 'returns the legacy push rule' do
        expect(finder.execute).to eq(push_rule)
      end
    end
  end
end
