# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::SessionArtifact, feature_category: :compliance_management do
  describe 'associations' do
    it { is_expected.to belong_to(:workflow).class_name('Ai::DuoWorkflows::Workflow') }
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:namespace).optional }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:duo_workflow_session_artifact) }

    it { is_expected.to validate_presence_of(:workflow_id) }
    it { is_expected.to validate_uniqueness_of(:workflow_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:workflow_definition) }
    it { is_expected.to validate_length_of(:workflow_definition).is_at_most(255) }
    it { is_expected.to validate_length_of(:model_used).is_at_most(255) }

    context 'when project_id is present' do
      it 'is valid without namespace_id' do
        workflow = create(:duo_workflows_workflow)
        artifact = build(:duo_workflow_session_artifact, workflow: workflow, user: workflow.user,
          project: workflow.project, namespace: nil)

        expect(artifact.project_id).to be_present
        expect(artifact.namespace_id).to be_nil
        expect(artifact).to be_valid
      end
    end

    context 'when namespace_id is present' do
      it 'is valid without project_id' do
        namespace = create(:group)
        workflow = create(:duo_workflows_workflow, project: nil, namespace: namespace)
        artifact = build(:duo_workflow_session_artifact, workflow: workflow, user: workflow.user,
          project: nil, namespace: namespace)

        expect(artifact.namespace_id).to be_present
        expect(artifact.project_id).to be_nil
        expect(artifact).to be_valid
      end
    end

    context 'when both project_id and namespace_id are nil' do
      it 'is invalid' do
        artifact = build(:duo_workflow_session_artifact, project: nil, namespace: nil)

        expect(artifact).not_to be_valid
        expect(artifact.errors[:base]).to include('one of project_id or namespace_id must be present')
      end
    end
  end

  describe '.sync_from_workflow!' do
    let_it_be(:workflow) { create(:duo_workflows_workflow) }

    it 'creates a session artifact from a workflow' do
      expect { described_class.sync_from_workflow!(workflow) }
        .to change { described_class.count }.by(1)

      artifact = described_class.find_by(workflow_id: workflow.id)
      expect(artifact.user_id).to eq(workflow.user_id)
      expect(artifact.project_id).to eq(workflow.project_id)
      expect(artifact.status).to eq(workflow.status_before_type_cast)
      expect(artifact.workflow_definition).to eq(workflow.workflow_definition)
      expect(artifact.workflow_created_at).to be_within(1.second).of(workflow.created_at)
      expect(artifact.workflow_updated_at).to be_within(1.second).of(workflow.updated_at)
    end

    it 'upserts on subsequent calls' do
      described_class.sync_from_workflow!(workflow)

      expect { described_class.sync_from_workflow!(workflow) }
        .not_to change { described_class.count }
    end

    it 'updates the artifact when workflow changes' do
      described_class.sync_from_workflow!(workflow)
      workflow.update!(workflow_definition: 'chat')

      described_class.sync_from_workflow!(workflow)

      artifact = described_class.find_by(workflow_id: workflow.id)
      expect(artifact.workflow_definition).to eq('chat')
    end
  end
end
