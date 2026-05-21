# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::GroupSecretsManagers::InitiateDeprovisionService, :gitlab_secrets_manager, feature_category: :secrets_management do
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let(:snapshot_group_id) { group.id }
  let(:snapshot_organization_id) { group.organization_id }
  let(:snapshot_root_namespace_id) { group.root_ancestor.id }

  let(:service) do
    described_class.new(
      group.secrets_manager,
      user,
      group_id: snapshot_group_id,
      organization_id: snapshot_organization_id,
      root_namespace_id: snapshot_root_namespace_id
    )
  end

  subject(:result) { service.execute }

  describe '#execute' do
    let(:deprovision_worker_spy) { class_spy(SecretsManagement::DeprovisionGroupSecretsManagerWorker) }

    before do
      stub_const('SecretsManagement::DeprovisionGroupSecretsManagerWorker', deprovision_worker_spy)
    end

    context 'when secrets manager exists and is active' do
      let!(:secrets_manager) { create(:group_secrets_manager, :active, group: group) }

      it 'initiates the deprovision process', :aggregate_failures do
        expect(result).to be_success

        returned_secrets_manager = result.payload[:group_secrets_manager]
        expect(returned_secrets_manager).to be_present
        expect(returned_secrets_manager).to be_deprovisioning

        task = SecretsManagement::GroupSecretsManagerMaintenanceTask.last
        expect(deprovision_worker_spy).to have_received(:perform_async).with(task.id)
      end

      it 'creates a maintenance task', :aggregate_failures do
        expect { result }.to change {
          SecretsManagement::GroupSecretsManagerMaintenanceTask.count
        }.by(1)

        task = SecretsManagement::GroupSecretsManagerMaintenanceTask.last
        expect(task.group_id).to eq(group.id)
        expect(task.root_namespace_id).to eq(group.root_ancestor.id)
        expect(task.organization_id).to eq(group.organization_id)
        expect(task.user).to eq(user)
        expect(task.action).to eq('deprovision')
        expect(task.retry_count).to eq(0)
        expect(task.last_processed_at).to be_present
        expect(task.last_processed_at).to be_within(1.second).of(Time.current)
      end

      context 'when explicit snapshot ids are provided' do
        let(:snapshot_organization_id) { group.organization_id + 100 }
        let(:snapshot_root_namespace_id) { group.root_ancestor.id + 100 }

        it 'uses the explicit snapshot ids when persisting the maintenance task' do
          fake_task = instance_double(SecretsManagement::GroupSecretsManagerMaintenanceTask, id: 12_345)
          expect(SecretsManagement::GroupSecretsManagerMaintenanceTask).to receive(:create!).with(
            hash_including(
              organization_id: snapshot_organization_id,
              root_namespace_id: snapshot_root_namespace_id
            )
          ).and_return(fake_task)

          expect(result).to be_success
          expect(deprovision_worker_spy).to have_received(:perform_async).with(12_345)
        end
      end
    end

    context 'when secrets manager does not exist' do
      let(:service) do
        described_class.new(
          nil,
          user,
          group_id: snapshot_group_id,
          organization_id: snapshot_organization_id,
          root_namespace_id: snapshot_root_namespace_id
        )
      end

      it 'fails' do
        expect(result).to be_error
        expect(result.message).to eq('Secrets manager not found for the group.')
        expect(deprovision_worker_spy).not_to have_received(:perform_async)
        expect(SecretsManagement::GroupSecretsManagerMaintenanceTask.count).to be_zero
      end
    end

    context 'when secrets manager is not active' do
      let!(:secrets_manager) { create(:group_secrets_manager, :deprovisioning, group: group) }

      it 'fails' do
        expect(result).to be_error
        expect(result.message).to eq('Secrets manager is not active')
        expect(deprovision_worker_spy).not_to have_received(:perform_async)
        expect(SecretsManagement::GroupSecretsManagerMaintenanceTask.count).to be_zero
      end
    end
  end

  describe '.bulk_initiate_for_groups' do
    let_it_be(:groups) { create_list(:group, 3) }
    let_it_be(:user) { create(:user) }
    # Use a real org and namespace that are different from each group's
    # live values, to prove the bulk method uses the passed-in OLD ids
    # rather than reading from the live records.
    let_it_be(:old_org) { create(:organization) }
    let_it_be(:old_root_namespace) { create(:group) }

    let(:old_root_namespace_id) { old_root_namespace.id }
    let(:old_organization_id) { old_org.id }
    let(:deprovision_worker_spy) { class_spy(SecretsManagement::DeprovisionGroupSecretsManagerWorker) }

    before do
      stub_const('SecretsManagement::DeprovisionGroupSecretsManagerWorker', deprovision_worker_spy)
    end

    subject(:bulk_call) do
      described_class.bulk_initiate_for_groups(
        SecretsManagement::GroupSecretsManager.unscoped.where(group_id: groups).select(:group_id),
        user,
        old_root_namespace_id: old_root_namespace_id,
        old_organization_id: old_organization_id
      )
    end

    context 'when no active SMs match' do
      it 'returns without touching the DB or enqueuing workers' do
        expect { bulk_call }
          .to not_change { SecretsManagement::GroupSecretsManagerMaintenanceTask.count }
        expect(deprovision_worker_spy).not_to have_received(:bulk_perform_async)
      end
    end

    context 'when active SMs exist' do
      let_it_be_with_reload(:sm1) { create(:group_secrets_manager, :active, group: groups[0]) }
      let_it_be_with_reload(:sm2) { create(:group_secrets_manager, :active, group: groups[1]) }
      # Inactive SM in the batch must be ignored
      let_it_be_with_reload(:sm_provisioning) do
        create(:group_secrets_manager, group: groups[2])
      end

      it 'transitions only active SMs to deprovisioning' do
        bulk_call

        expect(sm1.reload).to be_deprovisioning
        expect(sm2.reload).to be_deprovisioning
        expect(sm_provisioning.reload).to be_provisioning
      end

      it 'creates one task per active SM with OLD ids' do
        expect { bulk_call }
          .to change { SecretsManagement::GroupSecretsManagerMaintenanceTask.count }.by(2)

        SecretsManagement::GroupSecretsManagerMaintenanceTask.find_each do |task|
          expect(task.root_namespace_id).to eq(old_root_namespace_id)
          expect(task.organization_id).to eq(old_organization_id)
          expect(task.user_id).to eq(user.id)
          expect(task.action).to eq('deprovision')
          expect(task.retry_count).to eq(0)
          expect(task.last_processed_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'bulk-enqueues one worker job per inserted task' do
        bulk_call

        task_ids = SecretsManagement::GroupSecretsManagerMaintenanceTask.pluck(:id)
        expect(deprovision_worker_spy)
          .to have_received(:bulk_perform_async).with(task_ids.map { |id| [id] })
      end

      it 'rolls back the SM transition when task insert fails' do
        allow(SecretsManagement::GroupSecretsManagerMaintenanceTask)
          .to receive(:insert_all).and_raise(ActiveRecord::StatementInvalid, 'boom')

        expect { bulk_call }.to raise_error(ActiveRecord::StatementInvalid)
        expect(sm1.reload).to be_active
        expect(sm2.reload).to be_active
        expect(deprovision_worker_spy).not_to have_received(:bulk_perform_async)
      end
    end

    context 'when user is nil' do
      let_it_be(:user) { nil }

      it 'returns without doing any work' do
        create(:group_secrets_manager, :active, group: groups[0])

        expect { bulk_call }
          .to not_change { SecretsManagement::GroupSecretsManagerMaintenanceTask.count }
        expect(deprovision_worker_spy).not_to have_received(:bulk_perform_async)
      end
    end
  end
end
