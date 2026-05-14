# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::TypesFramework::SystemDefined::Definitions::Objective, feature_category: :team_planning do
  describe '.filterable_list_view?' do
    let(:resource_parent) { build(:group) }

    it 'returns true when okrs_mvc_feature_flag_enabled? is true' do
      expect(described_class.filterable_list_view?(resource_parent)).to be true
    end

    context "when the okrs_mvc feature_flag is disabled" do
      before do
        stub_feature_flags(okrs_mvc: false)
      end

      it 'returns false when okrs_mvc_feature_flag_enabled? is false' do
        expect(described_class.filterable_list_view?(resource_parent)).to be false
      end
    end

    context 'when resource_parent is nil' do
      let(:resource_parent) { nil }

      it 'returns false' do
        expect(described_class.filterable_list_view?(resource_parent)).to be false
      end
    end
  end
end
