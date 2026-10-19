# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::Governance::Session, feature_category: :compliance_management do
  describe 'associations' do
    it { is_expected.to belong_to(:namespace).optional }
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:workflow).class_name('::Ai::DuoWorkflows::Workflow').optional }
    it { is_expected.to belong_to(:agent_identity).class_name('::Ai::ExternalAgents::AgentIdentity').optional }
  end

  describe 'validations' do
    subject { build(:ai_governance_session) }

    it { is_expected.to validate_presence_of(:namespace_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:session_started_at) }
    it { is_expected.to validate_length_of(:external_xid).is_at_most(255) }
    it { is_expected.to validate_length_of(:agent_type).is_at_most(50) }
    it { is_expected.to validate_length_of(:flow_type).is_at_most(255) }

    it 'requires exactly one of workflow_id or external_xid' do
      session = build(:ai_governance_session, workflow_id: nil)

      expect(session).not_to be_valid
      expect(session.errors[:base]).to include('Exactly one of workflow_id, external_xid must be present')
    end

    it 'rejects a session with both workflow_id and external_xid set' do
      session = build(:ai_governance_session, :external, workflow_id: 5)

      expect(session).not_to be_valid
      expect(session.errors[:base]).to include('Exactly one of workflow_id, external_xid must be present')
    end

    it 'allows many rows without an external xid in the same namespace' do
      namespace = create(:namespace)
      create(:ai_governance_session, namespace: namespace)

      expect(build(:ai_governance_session, namespace: namespace)).to be_valid
    end

    it 'rejects a duplicate external xid for the same namespace and source' do
      existing = create(:ai_governance_session, :external, external_xid: 'clls_abc',
        source: :claude_code_compliance_api)
      duplicate = build(:ai_governance_session, :external,
        namespace: existing.namespace, external_xid: 'clls_abc', source: :claude_code_compliance_api)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:external_xid]).to include('has already been taken')
    end

    it 'allows the same external xid under a different source' do
      existing = create(:ai_governance_session, :external, external_xid: 'clls_abc',
        source: :claude_code_compliance_api)
      other_source = build(:ai_governance_session, :external,
        namespace: existing.namespace, external_xid: 'clls_abc', source: :claude_code_glab)

      expect(other_source).to be_valid
    end

    it 'rejects a duplicate workflow_id in the same namespace' do
      existing = create(:ai_governance_session, workflow_id: 42)
      duplicate = build(:ai_governance_session, namespace: existing.namespace, workflow_id: 42)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:workflow_id]).to include('has already been taken')
    end

    it 'allows the same workflow_id in a different namespace' do
      create(:ai_governance_session, workflow_id: 42)

      expect(build(:ai_governance_session, workflow_id: 42)).to be_valid
    end
  end

  describe 'source enum' do
    it 'defines the known session sources' do
      expect(described_class.sources).to eq(
        'gitlab_duo' => 0, 'claude_code_compliance_api' => 1, 'claude_code_glab' => 2, 'mcp' => 3
      )
    end

    it 'defaults to gitlab_duo' do
      expect(build(:ai_governance_session).source).to eq('gitlab_duo')
    end
  end

  describe 'status enum' do
    it 'mirrors Ai::DuoWorkflows::Workflow state_machine :status exactly' do
      workflow_statuses = Ai::DuoWorkflows::Workflow.state_machines[:status].states.to_h do |state|
        [state.name.to_s, state.value]
      end

      expect(described_class.statuses).to eq(workflow_statuses)
    end

    it 'defaults to created' do
      expect(build(:ai_governance_session).status).to eq('created')
    end
  end

  describe 'database constraint' do
    it 'rejects a row with neither workflow_id nor external_xid when validations are bypassed' do
      session = build(:ai_governance_session, workflow_id: nil)

      expect { session.save!(validate: false) }.to raise_error(
        ActiveRecord::StatementInvalid, /check_ai_session_is_duo_or_external/
      )
    end

    it 'rejects a row with both workflow_id and external_xid when validations are bypassed' do
      session = build(:ai_governance_session, :external, workflow_id: 5)

      expect { session.save!(validate: false) }.to raise_error(
        ActiveRecord::StatementInvalid, /check_ai_session_is_duo_or_external/
      )
    end

    it 'rejects a duplicate workflow_id in the same namespace when validations are bypassed' do
      existing = create(:ai_governance_session, workflow_id: 42)
      duplicate = build(:ai_governance_session, namespace: existing.namespace, workflow_id: 42)

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'deletion behaviour' do
    it 'keeps the session when the referenced user is deleted' do
      user = create(:user)
      session = create(:ai_governance_session, user: user)

      user.delete

      expect(session.reload.user_id).to eq(user.id)
      expect(session.user).to be_nil
    end

    it 'keeps the session in the window before the namespace loose FK cleanup runs' do
      namespace = create(:namespace)
      session = create(:ai_governance_session, namespace: namespace)

      namespace.delete

      expect(session.reload.namespace_id).to eq(namespace.id)
      expect(session.namespace).to be_nil
    end

    it 'keeps the session when the referenced project is deleted' do
      project = create(:project)
      session = create(:ai_governance_session, project: project)

      project.delete

      expect(session.reload.project_id).to eq(project.id)
      expect(session.project).to be_nil
    end

    # 'it has loose foreign keys' does not apply: that shared example checks the deletion
    # trigger on a table that is itself an LFK *parent* (something else cleans up when this
    # row is deleted). ai_governance_sessions is the child side here, pointing at namespaces.
    it_behaves_like 'cleanup by a loose foreign key', on_delete: :async_delete do
      let!(:parent) { create(:namespace) }
      let!(:model) { create(:ai_governance_session, namespace: parent) }
    end

    it 'nullifies agent_identity_id when the agent identity is deleted' do
      agent_identity = create(:ai_agent_identity)
      session = create(:ai_governance_session, agent_identity: agent_identity)

      agent_identity.delete

      expect(session.reload.agent_identity_id).to be_nil
    end
  end

  describe '.sync_from_workflow!' do
    let_it_be_with_reload(:workflow) { create(:duo_workflows_workflow) }

    def session_for(workflow)
      described_class.find_by(workflow_id: workflow.id)
    end

    it 'creates a session from a workflow', :aggregate_failures do
      expect { described_class.sync_from_workflow!(workflow) }
        .to change { described_class.count }.by(1)

      session = session_for(workflow)
      expect(session).to have_attributes(
        user_id: workflow.user_id,
        project_id: workflow.project_id,
        flow_type: workflow.workflow_definition,
        agent_type: workflow.agent_type,
        source: 'gitlab_duo',
        external_xid: nil
      )
      expect(session.status).to eq(workflow.status_name.to_s)
      expect(session.session_started_at).to be_within(1.second).of(workflow.created_at)
    end

    it 'populates namespace_id with the project namespace for a project workflow' do
      described_class.sync_from_workflow!(workflow)

      expect(session_for(workflow).namespace_id).to eq(workflow.project.project_namespace_id)
    end

    it 'leaves the columns it does not own at their defaults' do
      described_class.sync_from_workflow!(workflow)

      expect(session_for(workflow).session_finished_at).to be_nil
    end

    it 'writes a row that satisfies the model validations' do
      described_class.sync_from_workflow!(workflow)

      expect(session_for(workflow)).to be_valid
    end

    context 'with a namespace-scoped workflow' do
      let_it_be(:group) { create(:group) }
      let_it_be(:namespace_workflow, freeze: false) do
        create(:duo_workflows_workflow, project: nil, namespace: group)
      end

      it 'populates namespace_id with the workflow namespace', :aggregate_failures do
        described_class.sync_from_workflow!(namespace_workflow)

        session = session_for(namespace_workflow)
        expect(session.namespace_id).to eq(group.id)
        expect(session.project_id).to be_nil
      end
    end

    it 'upserts on subsequent calls' do
      described_class.sync_from_workflow!(workflow)

      expect { described_class.sync_from_workflow!(workflow) }.not_to change { described_class.count }
    end

    it 'updates the existing row when the workflow status changes', :aggregate_failures do
      described_class.sync_from_workflow!(workflow)
      workflow.start!

      expect { described_class.sync_from_workflow!(workflow) }.not_to change { described_class.count }
      expect(session_for(workflow).status).to eq('running')
    end

    it 'copies agent_type from an external agent workflow' do
      workflow.update!(agent_type: 'claude-code')

      described_class.sync_from_workflow!(workflow)

      expect(session_for(workflow).agent_type).to eq('claude-code')
    end
  end

  it 'defaults source and status' do
    session = create(:ai_governance_session)

    expect(session).to have_attributes(source: 'gitlab_duo', status: 'created')
  end

  describe '.for_agent_class' do
    let_it_be(:duo_session) { create(:ai_governance_session) }
    let_it_be(:api_session) { create(:ai_governance_session, :external) }
    let_it_be(:glab_session) { create(:ai_governance_session, :external, source: :claude_code_glab) }

    using RSpec::Parameterized::TableSyntax

    where(:agent_class, :expected) do
      :internal_dap | %i[duo_session]
      :external     | %i[api_session glab_session]
      :all          | %i[duo_session api_session glab_session]
    end

    with_them do
      it 'matches on source' do
        expect(described_class.for_agent_class(agent_class)).to match_array(expected.map { |name| public_send(name) })
      end
    end
  end

  describe 'scopes' do
    describe '.excluding_flow_type' do
      let_it_be(:chat) { create(:ai_governance_session, flow_type: 'chat') }
      let_it_be(:dev) { create(:ai_governance_session, flow_type: 'software_development') }
      let_it_be(:no_flow_type) { create(:ai_governance_session, flow_type: nil) }

      it 'keeps sessions without a flow type' do
        expect(described_class.excluding_flow_type('chat')).to contain_exactly(dev, no_flow_type)
      end
    end

    describe '.excluding_project' do
      let_it_be(:project) { create(:project) }
      let_it_be(:in_project) { create(:ai_governance_session, project: project) }
      let_it_be(:no_project) { create(:ai_governance_session, project: nil) }

      it 'keeps sessions without a project' do
        expect(described_class.excluding_project(project.id)).to contain_exactly(no_project)
      end
    end

    describe '.without_private_messaging_sessions' do
      let_it_be(:private_workflow) do
        create(:duo_workflows_workflow, messaging_callback_context: { 'adapter' => 'slack' })
      end

      let_it_be(:private_session) { create(:ai_governance_session, workflow_id: private_workflow.id) }
      let_it_be(:plain_session) { create(:ai_governance_session, workflow_id: create(:duo_workflows_workflow).id) }
      let_it_be(:external_session) { create(:ai_governance_session, :external) }

      it 'excludes sessions whose workflow is private to its invoker' do
        expect(described_class.without_private_messaging_sessions).to contain_exactly(plain_session, external_session)
      end

      context 'when no adapter is private to its invoker' do
        before do
          allow(::Ai::Messaging::AdapterRegistry).to receive(:private_to_invoker_keys).and_return([])
        end

        it 'does not filter' do
          expect(described_class.without_private_messaging_sessions)
            .to contain_exactly(private_session, plain_session, external_session)
        end
      end
    end
  end
end
