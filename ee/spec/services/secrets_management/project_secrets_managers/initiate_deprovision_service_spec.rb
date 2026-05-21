# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::ProjectSecretsManagers::InitiateDeprovisionService, feature_category: :secrets_management do
  let_it_be_with_reload(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let(:snapshot_project_id) { project.id }
  let(:snapshot_organization_id) { project.organization_id }
  let(:snapshot_root_namespace_id) { project.root_ancestor.id }
  let(:snapshot_parent_group_id) { project.namespace_id }

  let(:service) do
    described_class.new(
      project&.secrets_manager,
      user,
      project_id: snapshot_project_id,
      organization_id: snapshot_organization_id,
      root_namespace_id: snapshot_root_namespace_id,
      parent_group_id: snapshot_parent_group_id
    )
  end

  subject(:result) { service.execute }

  describe '#execute' do
    let(:deprovision_worker_spy) { class_spy(SecretsManagement::DeprovisionProjectSecretsManagerWorker) }

    before do
      stub_const('SecretsManagement::DeprovisionProjectSecretsManagerWorker', deprovision_worker_spy)
    end

    context 'when secrets manager exists and is active' do
      let!(:secrets_manager) { create(:project_secrets_manager, :active, project: project) }

      it 'initiates the deprovision process', :aggregate_failures do
        expect(result).to be_success

        returned_secrets_manager = result.payload[:project_secrets_manager]
        expect(returned_secrets_manager).to be_present
        expect(returned_secrets_manager).to be_deprovisioning

        task = SecretsManagement::ProjectSecretsManagerMaintenanceTask.last
        expect(deprovision_worker_spy).to have_received(:perform_async).with(task.id)
      end

      it 'creates a maintenance task', :aggregate_failures do
        expect { result }.to change {
          SecretsManagement::ProjectSecretsManagerMaintenanceTask.count
        }.by(1)

        task = SecretsManagement::ProjectSecretsManagerMaintenanceTask.last
        expect(task.project_secrets_manager).to eq(secrets_manager)
        expect(task.user).to eq(user)
        expect(task.action).to eq('deprovision')
        expect(task.retry_count).to eq(0)
        expect(task.last_processed_at).to be_present
        expect(task.last_processed_at).to be_within(1.second).of(Time.current)
        expect(task.project_id).to eq(project.id)
        expect(task.organization_id).to eq(project.organization_id)
        expect(task.root_namespace_id).to eq(project.root_ancestor.id)
        expect(task.parent_group_id).to eq(project.namespace_id)
      end

      context 'when explicit snapshot ids are provided' do
        let(:snapshot_organization_id) { project.organization_id + 100 }
        let(:snapshot_root_namespace_id) { project.root_ancestor.id + 100 }
        let(:snapshot_parent_group_id) { project.namespace_id + 100 }

        # Maintenance task FK validations require real records; exercise
        # the snapshot path without persisting, to keep the test focused
        # on the kwargs being threaded into the create! call.
        it 'uses the explicit snapshot ids when persisting the maintenance task' do
          fake_task = instance_double(SecretsManagement::ProjectSecretsManagerMaintenanceTask, id: 12_345)
          expect(SecretsManagement::ProjectSecretsManagerMaintenanceTask).to receive(:create!).with(
            hash_including(
              organization_id: snapshot_organization_id,
              root_namespace_id: snapshot_root_namespace_id,
              parent_group_id: snapshot_parent_group_id
            )
          ).and_return(fake_task)

          expect(result).to be_success
          expect(deprovision_worker_spy).to have_received(:perform_async).with(12_345)
        end
      end

      context 'when the maintenance task insert fails' do
        # Atomicity guarantee: if task creation raises, the secrets
        # manager state must roll back so we never end up with an SM
        # stuck in `deprovisioning` with no task to drive recovery.
        before do
          allow(SecretsManagement::ProjectSecretsManagerMaintenanceTask)
            .to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'rolls back the state transition and does not enqueue the worker' do
          expect { result }.to raise_error(ActiveRecord::RecordInvalid)
          expect(secrets_manager.reload).to be_active
          expect(deprovision_worker_spy).not_to have_received(:perform_async)
        end
      end
    end

    context 'when secrets manager does not exist' do
      it 'fails' do
        expect(result).to be_error
        expect(result.message).to eq('Secrets manager not found for the project.')
        expect(deprovision_worker_spy).not_to have_received(:perform_async)
        expect(SecretsManagement::ProjectSecretsManagerMaintenanceTask.count).to be_zero
      end
    end

    context 'when secrets manager is not active' do
      let!(:secrets_manager) { create(:project_secrets_manager, :deprovisioning, project: project) }

      it 'fails' do
        expect(result).to be_error
        expect(result.message).to eq('Secrets manager is not active')
        expect(deprovision_worker_spy).not_to have_received(:perform_async)
        expect(SecretsManagement::ProjectSecretsManagerMaintenanceTask.count).to be_zero
      end
    end
  end

  describe '.bulk_initiate_for_projects' do
    let_it_be(:projects) { create_list(:project, 3) }
    let_it_be(:user) { create(:user) }
    # Use a real org and namespace that are different from each project's
    # live values, to prove the bulk method uses the passed-in OLD ids
    # rather than reading from the live records.
    let_it_be(:old_org) { create(:organization) }
    let_it_be(:old_root_namespace) { create(:group) }

    let(:old_root_namespace_id) { old_root_namespace.id }
    let(:old_organization_id) { old_org.id }
    let(:deprovision_worker_spy) { class_spy(SecretsManagement::DeprovisionProjectSecretsManagerWorker) }

    before do
      stub_const('SecretsManagement::DeprovisionProjectSecretsManagerWorker', deprovision_worker_spy)
    end

    subject(:bulk_call) do
      described_class.bulk_initiate_for_projects(
        SecretsManagement::ProjectSecretsManager.unscoped.where(project_id: projects).select(:project_id),
        user,
        old_root_namespace_id: old_root_namespace_id,
        old_organization_id: old_organization_id
      )
    end

    context 'when no active SMs match' do
      it 'returns without touching the DB or enqueuing workers' do
        expect { bulk_call }
          .to not_change { SecretsManagement::ProjectSecretsManagerMaintenanceTask.count }
        expect(deprovision_worker_spy).not_to have_received(:bulk_perform_async)
      end
    end

    context 'when active SMs exist' do
      let_it_be_with_reload(:sm1) { create(:project_secrets_manager, :active, project: projects[0]) }
      let_it_be_with_reload(:sm2) { create(:project_secrets_manager, :active, project: projects[1]) }
      # Inactive SM in the batch must be ignored
      let_it_be_with_reload(:sm_provisioning) do
        create(:project_secrets_manager, project: projects[2])
      end

      it 'transitions only active SMs to deprovisioning' do
        bulk_call

        expect(sm1.reload).to be_deprovisioning
        expect(sm2.reload).to be_deprovisioning
        expect(sm_provisioning.reload).to be_provisioning
      end

      it 'creates one task per active SM with OLD ids' do
        expect { bulk_call }
          .to change { SecretsManagement::ProjectSecretsManagerMaintenanceTask.count }.by(2)

        SecretsManagement::ProjectSecretsManagerMaintenanceTask.find_each do |task|
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

        task_ids = SecretsManagement::ProjectSecretsManagerMaintenanceTask.pluck(:id)
        expect(deprovision_worker_spy)
          .to have_received(:bulk_perform_async).with(task_ids.map { |id| [id] })
      end

      it 'rolls back the SM transition when task insert fails' do
        allow(SecretsManagement::ProjectSecretsManagerMaintenanceTask)
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
        create(:project_secrets_manager, :active, project: projects[0])

        expect { bulk_call }
          .to not_change { SecretsManagement::ProjectSecretsManagerMaintenanceTask.count }
        expect(deprovision_worker_spy).not_to have_received(:bulk_perform_async)
      end
    end
  end
end
