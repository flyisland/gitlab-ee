# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectPushRuleFinder, feature_category: :source_code_management do
  let_it_be(:project) { create(:project) }

  subject(:finder) { described_class.new(project) }

  describe '#execute' do
    context 'when project has a push rule' do
      let_it_be(:push_rule) { create(:push_rule, project: project) }

      it 'returns the push rule' do
        expect(finder.execute).to eq(push_rule)
      end
    end
  end
end
