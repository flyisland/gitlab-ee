# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::TypesFramework::Visibility, feature_category: :team_planning do
  subject(:visibility) { build(:work_item_type_visibility) }

  describe 'associations' do
    it { is_expected.to belong_to(:namespace) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:namespace) }
    it { is_expected.to validate_presence_of(:work_item_type_id) }
    it { is_expected.to validate_uniqueness_of(:work_item_type_id).scoped_to(:namespace_id) }
    it { is_expected.to allow_values(true, false).for(:enabled) }
    it { is_expected.to allow_values(true, false).for(:propagate) }

    it_behaves_like 'validates work item type ID'
  end
end
