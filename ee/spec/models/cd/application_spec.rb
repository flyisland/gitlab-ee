# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Application, feature_category: :continuous_delivery do
  describe 'associations' do
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to have_many(:services) }
    it { is_expected.to have_many(:version_sets) }
    it { is_expected.to have_many(:application_flow_definitions) }
  end

  describe 'validations' do
    subject { create(:cd_application) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }

    describe 'name format' do
      it { is_expected.to allow_value('my-app').for(:name) }
      it { is_expected.to allow_value('my_app').for(:name) }
      it { is_expected.to allow_value('MyApp').for(:name) }
      it { is_expected.to allow_value('app1').for(:name) }
      it { is_expected.to allow_value('1app').for(:name) }
      it { is_expected.not_to allow_value('-app').for(:name) }
      it { is_expected.not_to allow_value('app-').for(:name) }
      it { is_expected.not_to allow_value('my app').for(:name) }
      it { is_expected.not_to allow_value('app/name').for(:name) }
      it { is_expected.not_to allow_value('app.name').for(:name) }
      it { is_expected.not_to allow_value('app!').for(:name) }
    end

    it { is_expected.to validate_length_of(:description).is_at_most(2000) }

    describe 'sharding key' do
      it 'is valid with an organization and no group' do
        expect(create(:cd_application, :for_organization)).to be_valid
      end

      it 'is valid with both an organization and a group owner' do
        expect(create(:cd_application, :with_group)).to be_valid
      end

      it 'is invalid without an organization' do
        application = build(:cd_application, organization: nil)

        expect(application).not_to be_valid
      end
    end
  end

  describe '.for_groups' do
    let_it_be(:group) { create(:group) }
    let_it_be(:other_group) { create(:group) }
    let_it_be(:application) { create(:cd_application, group: group) }
    let_it_be(:other_application) { create(:cd_application, group: other_group) }

    it 'returns applications belonging to the given groups' do
      expect(described_class.for_groups([group])).to contain_exactly(application)
    end

    it 'accepts a relation of groups' do
      expect(described_class.for_groups(Group.where(id: [group.id, other_group.id])))
        .to contain_exactly(application, other_application)
    end
  end

  describe '.for_organization' do
    it 'returns applications belonging to the given organization' do
      application = create(:cd_application, :for_organization)
      create(:cd_application, :for_organization)

      expect(described_class.for_organization(application.organization_id)).to contain_exactly(application)
    end
  end

  describe '.in_organization' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:other_organization) { create(:organization) }
    let_it_be(:group_in_org) { create(:group, organization: organization) }
    let_it_be(:org_application) { create(:cd_application, :for_organization, organization: organization) }
    let_it_be(:group_application) { create(:cd_application, group: group_in_org) }
    let_it_be(:other_org_application) do
      create(:cd_application, :for_organization, organization: other_organization)
    end

    it 'returns applications belonging to the organization, including those owned by its groups' do
      expect(described_class.in_organization(organization))
        .to contain_exactly(org_application, group_application)
    end
  end
end
