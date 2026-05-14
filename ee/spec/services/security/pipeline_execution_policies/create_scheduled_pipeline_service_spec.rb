# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::PipelineExecutionPolicies::CreateScheduledPipelineService,
  feature_category: :security_policy_management do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  let(:ci_content) do
    {
      "test_job" => {
        "stage" => "test",
        "script" => "exit 0"
      }
    }
  end

  let(:branch) { project.default_branch_or_main }
  let(:policy_id) { 123 }
  let(:schedule_id) { 456 }

  let(:service) do
    described_class.new(
      project: project,
      ci_content: ci_content,
      branch: branch,
      policy_id: policy_id,
      schedule_id: schedule_id
    )
  end

  let(:pipeline_service) { instance_double(Ci::CreatePipelineService) }
  let(:pipeline_response) { ServiceResponse.success(payload: pipeline) }

  describe '#execute' do
    subject(:execute) { service.execute }

    before do
      allow(Ci::CreatePipelineService).to receive(:new).and_return(pipeline_service)
      allow(pipeline_service).to receive(:execute).and_return(pipeline_response)
    end

    context 'when project has a security policy bot' do
      let_it_be(:security_bot) { create(:user, :security_policy_bot) }

      before_all do
        project.add_guest(security_bot)
      end

      context 'when pipeline creation succeeds' do
        it 'creates a pipeline using CreatePipelineService' do
          expect(Ci::CreatePipelineService).to receive(:new)
            .with(project, security_bot, ref: branch)
            .and_return(pipeline_service)

          expect(pipeline_service).to receive(:execute)
            .with(described_class::PIPELINE_SOURCE,
              content: ci_content.deep_stringify_keys.to_yaml,
              ignore_skip_ci: true)
            .and_return(pipeline_response)

          execute
        end

        it 'returns a success response' do
          expect(execute).to be_success
          expect(execute.payload).to eq(pipeline)
        end

        it 'does not log an error' do
          expect(Gitlab::AppJsonLogger).not_to receive(:error)
          execute
        end
      end

      context 'when pipeline creation fails' do
        let(:pipeline_response) { ServiceResponse.error(message: "Reference not found") }

        let(:expected_log) do
          {
            event: described_class::EVENT_KEY,
            message: "Reference not found",
            reason: nil,
            project_id: project.id,
            schedule_id: schedule_id,
            policy_id: policy_id,
            branch: branch
          }
        end

        it 'returns an error response' do
          expect(execute).to be_error
          expect(execute.message).to eq("Reference not found")
        end

        it 'logs the error' do
          expect(Gitlab::AppJsonLogger).to receive(:error).with(expected_log)
          execute
        end
      end

      context 'when using default branch' do
        let(:service) do
          described_class.new(
            project: project,
            ci_content: ci_content,
            policy_id: policy_id,
            schedule_id: schedule_id
          )
        end

        it 'uses the project default branch' do
          expect(Ci::CreatePipelineService).to receive(:new)
            .with(project, security_bot, ref: project.default_branch_or_main)
            .and_return(pipeline_service)

          execute
        end
      end

      context 'when ci_content contains symbol keys' do
        let(:ci_content) do
          {
            test_job: {
              stage: "test",
              script: "exit 0"
            }
          }
        end

        it 'stringifies the content before converting to YAML' do
          expect(pipeline_service).to receive(:execute)
            .with(described_class::PIPELINE_SOURCE,
              content: ci_content.deep_stringify_keys.to_yaml,
              ignore_skip_ci: true)
            .and_return(pipeline_response)

          execute
        end
      end
    end

    context 'when project has no security policy bot' do
      let_it_be(:project) { create(:project, :repository) }

      it 'creates a new bot user' do
        expect { execute }.to change { project.security_policy_bot }.from(nil).to(User)
      end
    end
  end
end
