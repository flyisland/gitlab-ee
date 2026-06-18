# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SecretsManagement::ProjectSecretsManagerMaintenanceTask, feature_category: :secrets_management do
  subject(:task) { build(:project_secrets_manager_maintenance_task) }

  let(:factory_name) { :project_secrets_manager_maintenance_task }

  it_behaves_like 'a secrets manager maintenance task'

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project_id) }

    it 'validates uniqueness of project_id' do
      create(:project_secrets_manager_maintenance_task)

      expect(task).to validate_uniqueness_of(:project_id)
    end

    it 'enforces uniqueness on project_id at the database level' do
      existing = create(:project_secrets_manager_maintenance_task, action: :provision)

      duplicate = build(:project_secrets_manager_maintenance_task,
        user: existing.user,
        project: existing.project,
        action: :deprovision,
        retry_count: 0
      )

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'path helpers' do
    subject(:task) do
      build(:project_secrets_manager_maintenance_task,
        organization_id: 7, root_namespace_id: 42, project_id: 99)
    end

    describe '#org_path' do
      it 'builds the level-1 path from organization_id' do
        expect(task.org_path).to eq('org_7')
      end
    end

    describe '#root_namespace_path' do
      it 'builds the level-2 path from root_namespace_id' do
        expect(task.root_namespace_path).to eq('group_42')
      end
    end

    describe '#project_path' do
      it 'builds the level-3 path from project_id' do
        expect(task.project_path).to eq('project_99')
      end
    end

    describe '#full_project_namespace_path' do
      it 'joins the three levels with /' do
        expect(task.full_project_namespace_path).to eq('org_7/group_42/project_99')
      end
    end
  end
end
