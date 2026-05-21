# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::DeprovisionProjectSecretsManagerWorker, :gitlab_secrets_manager, feature_category: :secrets_management do
  let(:worker) { described_class.new }

  describe '#perform' do
    let_it_be(:group) { create(:group) }
    let_it_be_with_reload(:project) { create(:project, group: group) }
    let_it_be(:user) { create(:user, owner_of: project) }

    let(:secrets_manager) { create(:project_secrets_manager, project: project) }
    let(:maintenance_task) do
      create(:project_secrets_manager_maintenance_task, :deprovision,
        project_secrets_manager: secrets_manager,
        user: user,
        project_id: project.id
      )
    end

    let(:maintenance_task_class) { SecretsManagement::ProjectSecretsManagerMaintenanceTask }
    let(:deprovision_service_class) { SecretsManagement::ProjectSecretsManagers::DeprovisionService }

    before do
      provision_project_secrets_manager(secrets_manager, user)
    end

    it_behaves_like 'a secrets manager deprovision worker'

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [maintenance_task.id] }

      it 'completely deprovisions the project secrets manager' do
        expect { perform_idempotent_work }.not_to raise_error

        expect_kv_secret_engine_not_to_be_mounted(secrets_manager.full_namespace_path,
          secrets_manager.ci_secrets_mount_path)
        expect_project_to_have_no_policies(secrets_manager.full_namespace_path)
        expect(SecretsManagement::ProjectSecretsManager.find_by(id: secrets_manager.id)).to be_nil
        expect(SecretsManagement::ProjectSecretsManagerMaintenanceTask.find_by(id: maintenance_task.id)).to be_nil
      end
    end
  end
end
