# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Cd::Environments::CreateService, feature_category: :continuous_delivery do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:group) { create(:group, organization: organization) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:cluster_agent) { create(:cluster_agent, project: project) }
  let_it_be(:current_user) { create(:user) }

  let(:params) do
    {
      name: 'staging',
      description: 'Staging environment',
      cluster_agent: cluster_agent
    }
  end

  subject(:result) do
    described_class.new(parent: parent, current_user: current_user, params: params).execute
  end

  describe '#execute' do
    shared_examples 'creates the environment' do |parent_attribute|
      it 'returns a success response with the persisted environment' do
        expect { result }.to change { ::Cd::Environment.count }.by(1)

        environment = result.payload[:environment]
        expect(result).to be_success
        expect(environment).to be_persisted
        expect(environment).to have_attributes(
          parent_attribute => parent,
          name: 'staging',
          description: 'Staging environment',
          cluster_agent: cluster_agent
        )
      end
    end

    shared_examples 'returns an error' do |message|
      it 'does not create an environment and returns the error' do
        expect { result }.not_to change { ::Cd::Environment.count }
        expect(result).to be_error
        expect(result.message).to include(message)
      end
    end

    context 'when parent is a group' do
      let(:parent) { group }

      it_behaves_like 'creates the environment', :group

      context 'when name is blank' do
        let(:params) { super().merge(name: '') }

        it_behaves_like 'returns an error', "Name can't be blank"
      end

      context 'when name is already taken in the group' do
        before do
          create(:cd_environment, group: group, name: 'staging')
        end

        it_behaves_like 'returns an error', 'Name has already been taken'
      end

      context 'when cluster agent is in a project of another organization' do
        let(:params) { super().merge(cluster_agent: create(:cluster_agent)) }

        it_behaves_like 'returns an error', 'Cluster agent must belong to the same organization'
      end
    end

    context 'when parent is an organization' do
      let(:parent) { organization }

      it_behaves_like 'creates the environment', :organization

      context 'when cluster agent is in a project of another organization' do
        let(:params) { super().merge(cluster_agent: create(:cluster_agent)) }

        it_behaves_like 'returns an error', 'Cluster agent must belong to the same organization'
      end
    end
  end
end
