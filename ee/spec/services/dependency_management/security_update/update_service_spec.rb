# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DependencyManagement::SecurityUpdate::UpdateService, feature_category: :dependency_management do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:project) { create(:project, :repository, organization: organization) }

  let(:vulnerability) do
    create(:vulnerability, :with_finding, :detected, project: project, report_type: :dependency_scanning)
  end

  let(:sbom_occurrence) do
    create(:sbom_occurrence,
      project: project,
      package_manager: 'bundler',
      input_file_path: 'Gemfile',
      component_name: 'rails'
    ).tap do |occurrence|
      occurrence.component_version.update!(version: '6.0.0')
    end
  end

  let(:security_update) do
    DependencyManagement::SecurityUpdate::Request.new(
      sbom_occurrence: sbom_occurrence,
      vulnerability: vulnerability,
      source_ref: project.default_branch
    )
  end

  let(:service) { described_class.new(project: project) }

  # Convenience helpers to avoid repeating the same pipeline/build/vars chain
  def pipeline_from(response)
    response.payload[:pipeline]
  end

  def build_from(response)
    pipeline_from(response).builds.first
  end

  def variables_from(response)
    build_from(response).variables
  end

  def variable_value(response, key)
    variables_from(response).find { |v| v.key == key }&.value
  end

  describe '#execute' do
    subject(:execute) { service.execute(security_update) }

    context 'when project cannot store security reports' do
      before do
        allow(project).to receive(:can_store_security_reports?).and_return(false)
      end

      it 'returns an error response' do
        expect(execute).to be_error
        expect(execute.message).to eq('Automated dependency security updates not enabled')
      end
    end

    context 'when security_update is nil' do
      let(:security_update) { nil }

      before do
        allow(project).to receive(:can_store_security_reports?).and_return(true)
      end

      it 'returns an error response' do
        expect(execute).to be_error
        expect(execute.message).to eq('Security Update Request not found')
      end
    end

    context 'when project can store security reports' do
      before do
        allow(project).to receive(:can_store_security_reports?).and_return(true)
      end

      it 'creates a pipeline using the security bot' do
        response = execute

        expect(response).to be_success
        expect(pipeline_from(response)).to be_a(Ci::Pipeline)
        expect(pipeline_from(response).user).to be_bot
      end

      it 'sets the correct pipeline attributes' do
        pipeline = pipeline_from(execute)

        expect(pipeline.project).to eq(project)
        expect(pipeline.source).to eq('dependency_management_security_update')
        expect(pipeline.ref).to eq(project.default_branch)
      end

      it 'creates a build with the orchestrator image' do
        expect(build_from(execute).image.name).to eq(
          'registry.gitlab.com/security-products/dependency-management/orchestrator:0'
        )
      end

      it 'sets commands to write job file and invoke the orchestrator' do
        script = build_from(execute).options[:script]

        expect(script).to include(a_string_matching(%r{echo .* > /tmp/dependency-update-job\.json}))
        expect(script).to include(
          'dependency-management-orchestrator update --job-file /tmp/dependency-update-job.json'
        )
      end

      it 'exposes output.json as an artifact' do
        artifacts = build_from(execute).options[:artifacts]

        expect(artifacts).to eq({ paths: ['output.json'] })
      end

      it 'sets the expected environment variables' do
        vars = variables_from(execute)
        key_value_pairs = vars.pluck(:key, :value).to_h

        expect(key_value_pairs).to include(
          'DEPENDENCY_MANAGEMENT_PROJECT_PATH' => project.full_path,
          'DEPENDENCY_MANAGEMENT_SOURCE_REF' => project.default_branch,
          'DEPENDENCY_MANAGEMENT_TARGET_BRANCH' => 'dependency-management/rails-6.x',
          'DEPENDENCY_MANAGEMENT_VULNERABILITY_ID' => vulnerability.id.to_s
        )
      end

      it 'uses JobBuilder to generate the job configuration' do
        job_builder = instance_double(DependencyManagement::SecurityUpdate::JobBuilder, to_json: '{}')

        expect(DependencyManagement::SecurityUpdate::JobBuilder)
          .to receive(:new)
          .with(request: security_update, project: project)
          .and_return(job_builder)

        execute
      end

      context 'when workload service fails' do
        before do
          allow_next_instance_of(Ci::Workloads::RunWorkloadService) do |workload_service|
            allow(workload_service).to receive(:execute)
              .and_return(ServiceResponse.error(message: 'Workload creation failed'))
          end
        end

        it 'returns an error response' do
          expect(execute).to be_error
          expect(execute.message).to eq('Workload creation failed')
        end
      end

      context 'when security policy bot already exists' do
        let!(:security_policy_bot) { create(:user, :security_policy_bot) }
        let(:pipeline) { create(:ci_pipeline, project: project, user: security_policy_bot) }

        before do
          allow(project).to receive(:security_policy_bot).and_return(security_policy_bot)
          allow_next_instance_of(Ci::Workloads::RunWorkloadService) do |workload_service|
            allow(workload_service).to receive(:execute)
              .and_return(ServiceResponse.success(payload: Struct.new(:pipeline).new(pipeline)))
          end
        end

        it 'uses the existing security policy bot without creating a new one' do
          expect(Security::Orchestration::CreateBotService).not_to receive(:new)

          response = execute

          expect(response).to be_success
          expect(pipeline_from(response)).to eq(pipeline)
        end
      end

      context 'when bot user creation fails' do
        let(:failed_response) { Struct.new(:user).new(nil) }

        before do
          allow(project).to receive(:security_policy_bot).and_return(nil)
          allow_next_instance_of(Security::Orchestration::CreateBotService) do |bot_service|
            allow(bot_service).to receive(:execute).and_return(failed_response)
          end
        end

        it 'logs the error and returns an error response' do
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(
            an_instance_of(StandardError),
            hash_including(class: described_class.name, project_id: project.id)
          )

          expect(execute).to be_error
          expect(execute.message).to eq('Failed to retrieve or create bot user')
        end

        it 'does not call RunWorkloadService' do
          expect(Ci::Workloads::RunWorkloadService).not_to receive(:new)
          execute
        end
      end
    end
  end

  describe 'target branch name generation' do
    using RSpec::Parameterized::TableSyntax

    before do
      allow(project).to receive(:can_store_security_reports?).and_return(true)
    end

    where(:dep_name, :version, :expected_branch) do
      'rails'           | '6.0.0'      | 'dependency-management/rails-6.x'
      '@scope/my-pkg'   | '1.2.3'      | 'dependency-management/scope-my-pkg-1.x'
      'rails'           | 'abc123'     | 'dependency-management/rails-0.x'
      'rails'           | '7.0.0-beta.1' | 'dependency-management/rails-7.x'
    end

    with_them do
      let(:sbom_occurrence) do
        create(:sbom_occurrence,
          project: project,
          package_manager: 'bundler',
          input_file_path: 'Gemfile',
          component_name: dep_name
        ).tap { |o| o.component_version.update!(version: version) }
      end

      it 'generates the correct target branch name' do
        expect(variable_value(service.execute(security_update), 'DEPENDENCY_MANAGEMENT_TARGET_BRANCH'))
          .to eq(expected_branch)
      end
    end
  end
end
