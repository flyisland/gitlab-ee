# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PipelineExecutionPolicies::TestRunService, '#execute', feature_category: :security_policy_management do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { project.first_owner }
  let_it_be(:policy) { create(:security_policy, :pipeline_execution_schedule_policy) }
  let_it_be(:policy_configuration) do
    create(:security_orchestration_policy_configuration,
      project: project,
      security_policy_management_project: policy.security_policy_management_project)
  end

  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  let(:service) { described_class.new(policy: policy, project: project, user: user) }
  let(:create_pipeline_service_response) { ServiceResponse.success(payload: pipeline) }
  let(:create_scheduled_pipeline_service) do
    instance_double(Security::PipelineExecutionPolicies::CreateScheduledPipelineService)
  end

  subject(:execute) { service.execute }

  before do
    stub_licensed_features(security_orchestration_policies: true)
    allow(policy).to receive(:scope_applicable?).with(project).and_return(true)
    allow(Security::PipelineExecutionPolicies::CreateScheduledPipelineService)
      .to receive(:new).and_return(create_scheduled_pipeline_service)
    allow(create_scheduled_pipeline_service).to receive(:execute).and_return(create_pipeline_service_response)
  end

  context 'when user can commit to security policy project' do
    before do
      policy.security_policy_management_project.add_developer(user)
    end

    it 'creates a test run and executes a pipeline', :aggregate_failures do
      expect(Security::PipelineExecutionPolicies::CreateScheduledPipelineService).to receive(:new)
        .with(
          project: project,
          ci_content: policy.content['content'],
          policy: policy
        )
        .and_return(create_scheduled_pipeline_service)
      expect(create_scheduled_pipeline_service).to receive(:execute)
        .and_return(create_pipeline_service_response)

      expect { execute }
        .to change { Security::ScheduledPipelineExecutionPolicyTestRun.count }.by(1)
      expect(execute).to be_success
      expect(execute.payload[:test_run]).to be_running
      expect(execute.payload[:test_run].pipeline).to eq(pipeline)
    end

    context 'when policy is not a pipeline execution schedule policy' do
      let_it_be(:policy) { create(:security_policy, :pipeline_execution_policy) }

      it 'returns an error', :aggregate_failures do
        expect(execute).to be_error
        expect(execute.message).to eq('Policy must be a pipeline_execution_schedule_policy')
      end
    end

    context 'when project is not in policy scope' do
      before do
        allow(policy).to receive(:scope_applicable?).with(project).and_return(false)
      end

      it 'returns an error', :aggregate_failures do
        expect(execute).to be_error
        expect(execute.message).to eq('Project is not in policy scope')
      end
    end

    context 'when test run creation fails' do
      let(:errors) { instance_double(ActiveModel::Errors, full_messages: ['Validation error']) }

      before do
        allow(Security::ScheduledPipelineExecutionPolicyTestRun).to receive(:create).and_return(
          instance_double(Security::ScheduledPipelineExecutionPolicyTestRun, persisted?: false, errors: errors)
        )
      end

      it 'returns an error', :aggregate_failures do
        expect(execute).to be_error
        expect(execute.message).to eq('Validation error')
      end
    end

    context 'when pipeline creation fails' do
      let(:create_pipeline_service_response) { ServiceResponse.error(message: 'Pipeline error') }

      it 'marks the test run failed', :aggregate_failures do
        test_run = execute.payload[:test_run]

        expect(execute).to be_error
        expect(test_run).to be_failed
        expect(test_run.error_message).to eq('Pipeline error')
      end
    end
  end

  context 'when user cannot commit to security policy project' do
    before do
      policy.security_policy_management_project.add_guest(user)
    end

    it 'returns an error', :aggregate_failures do
      expect(execute).to be_error
      expect(execute.message).to eq('User is not allowed to trigger test runs for this policy')
    end
  end

  context 'when user can commit to a different policy project but not to the tested policy project' do
    let_it_be(:group) { create(:group) }
    let_it_be(:group_project) { create(:project, :repository, group: group) }
    let_it_be(:group_policy_management_project) { create(:project) }
    let_it_be(:group_policy_configuration) do
      create(:security_orchestration_policy_configuration, :namespace,
        namespace: group,
        security_policy_management_project: group_policy_management_project)
    end

    let_it_be(:other_policy_management_project) { create(:project) }
    let_it_be(:other_policy) do
      create(:security_policy, :pipeline_execution_schedule_policy,
        security_policy_management_project: other_policy_management_project)
    end

    let(:service) { described_class.new(policy: other_policy, project: group_project, user: user) }

    before_all do
      # User has access to group policy but NOT to other_policy
      group_policy_management_project.add_developer(user)
    end

    before do
      allow(other_policy).to receive(:scope_applicable?).with(group_project).and_return(true)
    end

    it 'returns an authorization error', :aggregate_failures do
      expect(execute).to be_error
      expect(execute.message).to eq('User is not allowed to trigger test runs for this policy')
    end
  end

  context 'when project has no security policy configuration' do
    before do
      allow(project).to receive(:security_orchestration_policy_configuration).and_return(nil)
    end

    it 'returns an error', :aggregate_failures do
      expect(execute).to be_error
      expect(execute.message).to eq('User is not allowed to trigger test runs for this policy')
    end
  end
end
