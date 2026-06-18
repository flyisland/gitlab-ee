# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::GroupSecretsManagers::InitializeService, :gitlab_secrets_manager, feature_category: :secrets_management do
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let(:resource) { group }
  let(:service) { described_class.new(group, user) }

  let(:secrets_manager_class) { SecretsManagement::GroupSecretsManager }
  let(:maintenance_task_class) { SecretsManagement::GroupSecretsManagerMaintenanceTask }
  let(:provision_worker_class) { SecretsManagement::ProvisionGroupSecretsManagerTaskWorker }
  let(:payload_key) { :group_secrets_manager }
  let(:resource_type) { 'group' }
  let(:create_existing_secrets_manager) do
    -> { create(:group_secrets_manager, group: group) }
  end

  describe '#execute' do
    it_behaves_like 'a secrets manager initialize service'

    context 'when the resource has no secrets manager' do
      subject(:result) { service.execute }

      it 'persists scope-specific snapshot ids on the maintenance task', :aggregate_failures do
        result

        task = maintenance_task_class.last
        expect(task.group_id).to eq(group.id)
        expect(task.organization_id).to eq(group.organization_id)
        expect(task.root_namespace_id).to eq(group.root_ancestor.id)
      end
    end
  end
end
