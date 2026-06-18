# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Environment, feature_category: :continuous_delivery do
  describe 'associations' do
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:organization).required }
    it { is_expected.to belong_to(:cluster_agent).required }
    it { is_expected.to have_many(:rollouts) }
    it { is_expected.to have_many(:deployments).through(:rollouts) }
  end

  describe 'validations' do
    subject { create(:cd_environment) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id) }

    describe 'name format' do
      it { is_expected.to allow_value('my-env').for(:name) }
      it { is_expected.to allow_value('my_env').for(:name) }
      it { is_expected.to allow_value('MyEnv').for(:name) }
      it { is_expected.to allow_value('env1').for(:name) }
      it { is_expected.to allow_value('1env').for(:name) }
      it { is_expected.not_to allow_value('-env').for(:name) }
      it { is_expected.not_to allow_value('env-').for(:name) }
      it { is_expected.not_to allow_value('my env').for(:name) }
      it { is_expected.not_to allow_value('env/name').for(:name) }
      it { is_expected.not_to allow_value('env.name').for(:name) }
      it { is_expected.not_to allow_value('env!').for(:name) }
    end

    it { is_expected.to validate_length_of(:description).is_at_most(1024) }
    it { is_expected.to validate_length_of(:region).is_at_most(255) }

    describe 'sharding key' do
      it 'is valid with an organization and no group' do
        expect(create(:cd_environment, :for_organization)).to be_valid
      end

      it 'is valid with both an organization and a group owner' do
        expect(create(:cd_environment)).to be_valid
      end

      it 'is invalid without an organization' do
        env = build(:cd_environment, organization: nil)

        expect(env).not_to be_valid
      end
    end

    describe 'cluster agent organization' do
      let_it_be(:organization) { create(:organization) }
      let_it_be(:same_org_agent) do
        create(:cluster_agent, project: create(:project, group: create(:group, organization: organization)))
      end

      let_it_be(:other_org_agent) { create(:cluster_agent) }

      shared_examples 'enforces same organization' do
        it 'is valid when the agent project shares the parent organization' do
          expect(build_env(same_org_agent)).to be_valid
        end

        it 'is invalid when the agent project is in a different organization' do
          env = build_env(other_org_agent)

          expect(env).not_to be_valid
          expect(env.errors[:cluster_agent]).to include('must belong to the same organization')
        end
      end

      context 'for a group-scoped environment' do
        def build_env(agent)
          build(:cd_environment, group: create(:group, organization: organization), cluster_agent: agent)
        end

        it_behaves_like 'enforces same organization'
      end

      context 'for an organization-scoped environment' do
        def build_env(agent)
          build(:cd_environment, :for_organization, organization: organization, cluster_agent: agent)
        end

        it_behaves_like 'enforces same organization'
      end
    end
  end

  describe 'enums' do
    it 'defines platform_type enum with expected values' do
      is_expected.to define_enum_for(:platform_type)
        .with_values(kubernetes: 0)
    end
  end

  describe 'scopes' do
    describe '.for_namespace' do
      it 'returns environments belonging to the given group' do
        env = create(:cd_environment)
        create(:cd_environment)

        expect(described_class.for_namespace(env.group_id)).to contain_exactly(env)
      end
    end

    describe '.for_organization' do
      it 'returns environments belonging to the given organization' do
        env = create(:cd_environment, :for_organization)
        create(:cd_environment, :for_organization)

        expect(described_class.for_organization(env.organization_id)).to contain_exactly(env)
      end
    end

    describe '.for_groups' do
      let_it_be(:group) { create(:group) }
      let_it_be(:other_group) { create(:group) }
      let_it_be(:environment) { create(:cd_environment, group: group) }
      let_it_be(:other_environment) { create(:cd_environment, group: other_group) }

      it 'returns environments belonging to the given groups' do
        expect(described_class.for_groups([group])).to contain_exactly(environment)
      end

      it 'accepts a relation of groups' do
        expect(described_class.for_groups(Group.where(id: [group.id, other_group.id])))
          .to contain_exactly(environment, other_environment)
      end
    end

    describe '.in_organization' do
      let_it_be(:organization) { create(:organization) }
      let_it_be(:other_organization) { create(:organization) }
      let_it_be(:group_in_org) { create(:group, organization: organization) }
      let_it_be(:group_in_other_org) { create(:group, organization: other_organization) }
      let_it_be(:org_environment) { create(:cd_environment, :for_organization, organization: organization) }
      let_it_be(:group_environment) { create(:cd_environment, group: group_in_org) }
      let_it_be(:other_org_environment) do
        create(:cd_environment, :for_organization, organization: other_organization)
      end

      let_it_be(:other_group_environment) { create(:cd_environment, group: group_in_other_org) }

      it 'returns environments attached directly to the organization and via its groups' do
        expect(described_class.in_organization(organization))
          .to contain_exactly(org_environment, group_environment)
      end
    end

    describe '.order_by_name_asc' do
      it 'returns environments ordered by name ascending' do
        env_b = create(:cd_environment, name: 'beta')
        env_a = create(:cd_environment, name: 'alpha')

        expect(described_class.order_by_name_asc).to eq([env_a, env_b])
      end
    end
  end
end
