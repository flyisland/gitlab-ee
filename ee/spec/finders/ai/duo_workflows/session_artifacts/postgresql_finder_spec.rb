# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::SessionArtifacts::PostgresqlFinder, feature_category: :duo_agent_platform do
  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:subgroup_project) { create(:project, group: subgroup) }
  let_it_be(:other_group) { create(:group) }
  let_it_be(:other_project) { create(:project, group: other_group) }
  let_it_be(:workflow1) { create(:duo_workflows_workflow, project: project) }
  let_it_be(:workflow2) { create(:duo_workflows_workflow, project: subgroup_project) }
  let_it_be(:workflow_outside) { create(:duo_workflows_workflow, project: other_project) }

  let_it_be(:artifact1) do
    create(:duo_workflow_session_artifact,
      workflow: workflow1,
      workflow_updated_at: 2.hours.ago)
  end

  let_it_be(:artifact2) do
    create(:duo_workflow_session_artifact,
      workflow: workflow2,
      workflow_updated_at: 1.hour.ago)
  end

  let_it_be(:artifact_outside) do
    create(:duo_workflow_session_artifact, workflow: workflow_outside)
  end

  subject(:results) { described_class.new(namespace: group, params: {}).execute }

  describe '#execute' do
    it 'returns all artifacts scoped to the namespace and its subgroups' do
      expect(results).to contain_exactly(artifact1, artifact2)
    end

    it 'excludes artifacts from outside the namespace' do
      expect(results).not_to include(artifact_outside)
    end

    it 'orders by workflow_updated_at DESC, workflow_id DESC' do
      expect(results.to_a).to eq([artifact2, artifact1])
    end

    it 'eager loads the project association' do
      expect(results.first.association(:project)).to be_loaded
    end
  end
end
