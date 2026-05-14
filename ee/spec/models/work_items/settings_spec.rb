# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Settings, feature_category: :team_planning do
  subject(:settings) { build(:work_item_settings) }

  describe 'associations' do
    it { is_expected.to belong_to(:organization).class_name('Organizations::Organization').optional }
    it { is_expected.to belong_to(:namespace).optional }
  end

  describe 'validations' do
    it { is_expected.to allow_values(true, false).for(:customizable_type_visibility) }

    describe 'sharding key validation' do
      shared_examples 'an invalid settings record' do
        it 'is invalid with the expected error' do
          expect(settings).to be_invalid
          expect(settings.errors[:base]).to include(
            'Exactly one of namespace_id, organization_id must be present'
          )
        end
      end

      context 'when neither organization nor namespace is set' do
        subject(:settings) { build(:work_item_settings, organization: nil, namespace: nil) }

        it_behaves_like 'an invalid settings record'
      end

      context 'when both organization and namespace are set' do
        subject(:settings) do
          build(:work_item_settings, organization: create(:organization), namespace: create(:group))
        end

        it_behaves_like 'an invalid settings record'
      end

      context 'when only organization is set' do
        subject(:settings) { build(:work_item_settings, organization: create(:organization), namespace: nil) }

        it { is_expected.to be_valid }
      end

      context 'when only namespace is set' do
        subject(:settings) { build(:work_item_settings, namespace: create(:group), organization: nil) }

        it { is_expected.to be_valid }
      end
    end

    describe 'uniqueness validations' do
      shared_examples 'validates uniqueness' do |attribute|
        it { is_expected.to be_invalid }

        it 'adds the correct error' do
          settings.valid?
          expect(settings.errors[attribute]).to include('has already been taken')
        end
      end

      context 'for organization_id' do
        let_it_be(:organization) { create(:organization) }
        let_it_be(:existing_settings) { create(:work_item_settings, organization: organization, namespace: nil) }

        subject(:settings) { build(:work_item_settings, organization: organization, namespace: nil) }

        it_behaves_like 'validates uniqueness', :organization_id
      end

      context 'for namespace_id' do
        let_it_be(:namespace) { create(:group) }
        let_it_be(:existing_settings) { create(:work_item_settings, namespace: namespace) }

        subject(:settings) { build(:work_item_settings, namespace: namespace) }

        it_behaves_like 'validates uniqueness', :namespace_id
      end
    end
  end
end
