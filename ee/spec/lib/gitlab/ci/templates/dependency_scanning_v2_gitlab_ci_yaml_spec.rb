# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dependency-Scanning.v2.gitlab-ci.yml', feature_category: :software_composition_analysis do
  include Ci::PipelineMessageHelpers

  subject(:template) { Gitlab::Template::GitlabCiYmlTemplate.find('Jobs/Dependency-Scanning.v2') }

  describe 'the created pipeline' do
    let_it_be(:default_branch) { 'master' }
    let_it_be(:feature_branch) { 'patch-1' }
    let_it_be(:inputs) { {} }

    let(:pipeline) { service.execute(:push, inputs: inputs).payload }

    before do
      stub_ci_pipeline_yaml_file(template.content)
    end

    context "with project type" do
      # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
      include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }

      using RSpec::Parameterized::TableSyntax
      where(:case_name, :files, :variables, :jobs) do
        # rubocop:disable Layout/LineLength -- TableSyntax
        'Any'                           | ['any.txt']                      | {} | %w[dependency-scanning]
        'Java Maven'                    | ['pom.xml']                      | {} | %w[dependency-scanning dependency-scanning:maven-resolution]
        'Python requirements.txt'       | ['requirements.txt']             | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python requirements.in'        | ['requirements.in']              | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python requirements.pip'       | ['requirements.pip']             | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python custom requirements'    | ['custom-requirements.txt']      | { 'PIP_REQUIREMENTS_FILE' => 'custom-requirements.txt' } | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python requires.txt'           | ['requires.txt']                 | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python with setup.py'          | ['setup.py']                     | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python with setup.cfg'         | ['setup.cfg']                    | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Python with pyproject.toml'    | ['pyproject.toml']               | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        # Not supported yet
        # 'Python Pipfile'                | ['Pipfile']                      | {} | %w[dependency-scanning dependency-scanning:python-resolution]
        'Multiple languages'            | ['pom.xml', 'requirements.txt'] | {} | %w[dependency-scanning dependency-scanning:maven-resolution dependency-scanning:python-resolution]
        # rubocop:enable Layout/LineLength
      end

      with_them do
        include_context 'when project has files', params[:files]
        include_context 'with CI variables', params[:variables], if: params[:variables].any?

        context 'as a branch pipeline on the default branch' do
          include_context 'with default branch pipeline setup'

          include_examples 'has expected jobs', params[:jobs]
        end

        context 'as a branch pipeline on a feature branch' do
          include_context 'with feature branch pipeline setup'

          include_examples 'has expected jobs', params[:jobs]
        end

        context 'as an MR pipeline' do
          include_context 'with MR pipeline setup'

          include_examples 'has expected jobs', params[:jobs]

          context 'when AST_ENABLE_MR_PIPELINES=false' do
            include_context 'with CI variables', { 'AST_ENABLE_MR_PIPELINES' => 'false' }

            include_examples 'has expected jobs', []
          end
        end

        context 'when files exists in a subdirectory' do
          include_context 'when project has files', params[:files].map { |f| "submodule/#{f}" }

          context 'as a branch pipeline on the default branch' do
            include_context 'with default branch pipeline setup'

            include_examples 'has expected jobs', params[:jobs]
          end
        end
      end
    end

    describe 'Maven resolution job' do
      include_context 'when project has files', ["pom.xml"]
      # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
      include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }

      context 'as a branch pipeline on the default branch' do
        include_context 'with default branch pipeline setup'

        let(:maven_job) { pipeline.builds.find_by(name: 'dependency-scanning:maven-resolution') }

        include_examples 'has expected jobs', %w[dependency-scanning dependency-scanning:maven-resolution]

        it 'configures the DS analyzer service', :aggregate_failures do
          service = maven_job.options[:services].first

          expect(service[:name]).to eq('$DS_ANALYZER_IMAGE')
          expect(service[:alias]).to eq('ds-analyzer')
          expect(service[:command]).to eq(['/analyzer', 'dependency-resolution-service', '--project-types', 'maven'])
        end

        it 'always uploads maven graph artifacts', :aggregate_failures do
          expect(maven_job.options[:artifacts][:paths]).to include('**/maven.graph.json')
          expect(maven_job.options[:artifacts][:when]).to eq('always')
        end
      end
    end

    describe 'python resolution job' do
      include_context 'when project has files', ["requirements.txt"]
      # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
      include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }

      context 'as a branch pipeline on the default branch' do
        include_context 'with default branch pipeline setup'

        let(:python_job) { pipeline.builds.find_by(name: 'dependency-scanning:python-resolution') }

        include_examples 'has expected jobs', %w[dependency-scanning dependency-scanning:python-resolution]

        it 'configures the DS analyzer service', :aggregate_failures do
          service = python_job.options[:services].first

          expect(service[:name]).to eq('$DS_ANALYZER_IMAGE')
          expect(service[:alias]).to eq('ds-analyzer')
          expect(service[:command]).to eq(['/analyzer', 'dependency-resolution-service', '--project-types', 'python'])
        end

        it 'always uploads python lockfile artifacts', :aggregate_failures do
          expect(python_job.options[:artifacts][:paths]).to include('**/pipcompile.lock.txt')
          expect(python_job.options[:artifacts][:when]).to eq('always')
        end
      end
    end

    context 'when options for DS job are set' do
      include_context 'when project has files', ["any.file"]
      include_context 'with default branch pipeline setup'

      let(:ds_job) { pipeline.builds.find_by(name: 'dependency-scanning') }

      context 'when job stage is specified' do
        let(:inputs) { { stage: 'build' } }

        it 'matches' do
          expect(ds_job.stage).to eq('build')
        end
      end

      context 'when failure mode is specified' do
        let(:inputs) { { allow_failure: false } }

        it 'matches' do
          expect(ds_job.allow_failure).to be(false)
        end
      end

      context 'when job name is specified' do
        let(:inputs) { { job_name: 'dependency-scanning-1a' } }

        include_examples 'has expected jobs', %w[dependency-scanning-1a]
      end

      context 'when analyzer image is specified' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            'default' => {
              variables: {},
              inputs: {},
              expected_analyzer_image: 'registry.gitlab.com/security-products/dependency-scanning:1'
            },
            'set prefix input' => {
              variables: {},
              inputs: {
                analyzer_image_prefix: 'registry.example.com'
              },
              expected_analyzer_image: 'registry.example.com/dependency-scanning:1'
            },
            'set name input' => {
              variables: {},
              inputs: {
                analyzer_image_name: 'foo'
              },
              expected_analyzer_image: 'registry.gitlab.com/security-products/foo:1'
            },
            'set version input' => {
              variables: {},
              inputs: {
                analyzer_image_version: '0'
              },
              expected_analyzer_image: 'registry.gitlab.com/security-products/dependency-scanning:0'
            },
            'set all inputs' => {
              variables: {},
              inputs: {
                analyzer_image_prefix: 'registry.example.com/security',
                analyzer_image_name: 'bar',
                analyzer_image_version: 'v9.8.7'
              },
              expected_analyzer_image: 'registry.example.com/security/bar:v9.8.7'
            },
            'SECURE_ANALYZERS_PREFIX is set' => {
              variables: {
                SECURE_ANALYZERS_PREFIX: "registry.other.com/appsec-team"
              },
              inputs: {
                analyzer_image_name: 'bar',
                analyzer_image_version: 'v9.8.7'
              },
              expected_analyzer_image: 'registry.other.com/appsec-team/bar:v9.8.7'
            },
            'DS_ANALYZER_IMAGE is set' => {
              variables: {
                DS_ANALYZER_IMAGE: "my-analyzer-image"
              },
              inputs: {},
              expected_analyzer_image: 'my-analyzer-image'
            }
          }
        end

        with_them do
          include_context 'with CI variables', params[:variables]

          include_examples 'has expected image', 'dependency-scanning', params[:expected_analyzer_image]
        end
      end

      context "when options for DS analyzer are set" do
        using RSpec::Parameterized::TableSyntax

        let(:ds_job) { pipeline.builds.find_by(name: 'dependency-scanning') }

        where(:variable_name, :input_name, :input_value) do
          'ADDITIONAL_CA_CERT_BUNDLE' | :additional_ca_cert_bundle | 'ANOTHER PEM CERTIFICATE'
          'DS_PIPCOMPILE_REQUIREMENTS_FILE_NAME_PATTERN' | :pipcompile_requirements_file_name_pattern | '**/*.txt'
          'DS_MAX_DEPTH' | :max_scan_depth | 5
          'DS_EXCLUDED_PATHS' | :excluded_paths | '**/custom'
          'DS_INCLUDE_DEV_DEPENDENCIES' | :include_dev_dependencies | false
          'DS_STATIC_REACHABILITY_ENABLED' | :enable_static_reachability | true
          'SECURE_LOG_LEVEL' | :analyzer_log_level | 'debug'
          'DS_ENABLE_VULNERABILITY_SCAN' | :enable_vulnerability_scan | false
          'DS_API_TIMEOUT' | :vulnerability_scan_api_timeout | 20
          'DS_API_SCAN_DOWNLOAD_DELAY' | :vulnerability_scan_api_download_delay | 5
        end

        with_them do
          let(:inputs) { { input_name => input_value } }

          it 'sets the variable in the script with the input value if not already set' do
            script = ds_job.options[:script].join("\n")
            expect(script).to include("export #{variable_name}=\"${#{variable_name}:-#{input_value}}\"")
          end
        end
      end
    end

    context 'when options for maven resolution job are specified' do
      include_context 'when project has files', ["pom.xml"]
      # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
      include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }
      include_context 'with default branch pipeline setup'

      let(:maven_job) { pipeline.builds.find_by(name: 'dependency-scanning:maven-resolution') }

      context 'when resolution job stage is specified' do
        let(:inputs) { { resolution_jobs_stage: 'build' } }

        it 'matches' do
          expect(maven_job.stage).to eq('build')
        end
      end

      context 'when resolution job failure mode is specified' do
        let(:inputs) { { resolution_jobs_allow_failure: false } }

        it 'matches' do
          expect(maven_job.allow_failure).to be(false)
        end
      end

      context 'when maven resolution job name is specified' do
        let(:inputs) { { maven_resolution_job_name: 'custom-maven-resolution' } }

        include_examples 'has expected jobs', %w[dependency-scanning custom-maven-resolution]
      end

      context 'when maven resolution image is specified' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            'default' => {
              variables: {},
              inputs: {},
              expected_image: 'registry.gitlab.com/security-products/dependency-resolution/ubi9/openjdk-21:1'
            },
            'image input is set' => {
              variables: {},
              inputs: {
                maven_resolution_image: 'registry.example.com/maven:latest'
              },
              expected_image: 'registry.example.com/maven:latest'
            },
            'DS_MAVEN_RESOLUTION_IMAGE is set' => {
              variables: {
                DS_MAVEN_RESOLUTION_IMAGE: "my-custom-maven-image"
              },
              inputs: {},
              expected_image: 'my-custom-maven-image'
            }
          }
        end

        with_them do
          include_context 'with CI variables', params[:variables]

          include_examples 'has expected image', 'dependency-scanning:maven-resolution', params[:expected_image]
        end
      end

      context "when options for DS analyzer service are set" do
        using RSpec::Parameterized::TableSyntax

        where(:variable_name, :input_name, :input_value) do
          'ADDITIONAL_CA_CERT_BUNDLE' | :additional_ca_cert_bundle | 'ANOTHER PEM CERTIFICATE'
          'DS_MAX_DEPTH' | :max_scan_depth | 5
          'DS_EXCLUDED_PATHS' | :excluded_paths | '**/custom'
          'DS_INCLUDE_DEV_DEPENDENCIES' | :include_dev_dependencies | false
          'SECURE_LOG_LEVEL' | :analyzer_log_level | 'debug'
        end

        with_them do
          let(:inputs) { { input_name => input_value } }

          it 'sets the variable with the input value if not already set, and export it for the service container' do
            script = maven_job.options[:script].join("\n")
            expect(script).to include("export #{variable_name}=\"${#{variable_name}:-#{input_value}}\"")
            expect(String(maven_job.variables.to_hash['DS_MAVEN_RESOLUTION_EXPORTED_VARS']))
              .to match(/\b#{variable_name}\b/)
          end
        end
      end
    end

    context 'when options for python resolution job are specified' do
      include_context 'when project has files', ["requirements.txt"]
      # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
      include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }
      include_context 'with default branch pipeline setup'

      let(:python_job) { pipeline.builds.find_by(name: 'dependency-scanning:python-resolution') }

      context 'when resolution job stage is specified' do
        let(:inputs) { { resolution_jobs_stage: 'build' } }

        it 'matches' do
          expect(python_job.stage).to eq('build')
        end
      end

      context 'when resolution job failure mode is specified' do
        let(:inputs) { { resolution_jobs_allow_failure: false } }

        it 'matches' do
          expect(python_job.allow_failure).to be(false)
        end
      end

      context 'when python resolution job name is specified' do
        let(:inputs) { { python_resolution_job_name: 'custom-python-resolution' } }

        include_examples 'has expected jobs', %w[dependency-scanning custom-python-resolution]
      end

      context 'when python resolution image is specified' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            'default' => {
              variables: {},
              inputs: {},
              expected_image:
                'registry.gitlab.com/security-products/dependency-resolution/ubi9/python-312-minimal-with-piptools-7:9'
            },
            'image input is set' => {
              variables: {},
              inputs: {
                python_resolution_image: 'registry.example.com/python:latest'
              },
              expected_image: 'registry.example.com/python:latest'
            },
            'DS_PYTHON_RESOLUTION_IMAGE is set' => {
              variables: {
                DS_PYTHON_RESOLUTION_IMAGE: "my-custom-python-image"
              },
              inputs: {},
              expected_image: 'my-custom-python-image'
            }
          }
        end

        with_them do
          include_context 'with CI variables', params[:variables]

          include_examples 'has expected image', 'dependency-scanning:python-resolution', params[:expected_image]
        end
      end

      context "when options for DS analyzer service are set" do
        using RSpec::Parameterized::TableSyntax

        where(:variable_name, :input_name, :input_value) do
          # rubocop:disable Layout/LineLength -- TableSyntax
          'ADDITIONAL_CA_CERT_BUNDLE' | :additional_ca_cert_bundle | 'ANOTHER PEM CERTIFICATE'
          'DS_PIPCOMPILE_REQUIREMENTS_FILE_NAME_PATTERN' | :pipcompile_requirements_file_name_pattern | 'some-*-requirement.txt'
          'DS_PIP_DEPENDENCY_PATH' | nil | nil
          'PIP_REQUIREMENTS_FILE' | nil | nil
          'DS_MAX_DEPTH' | :max_scan_depth | 5
          'DS_EXCLUDED_PATHS' | :excluded_paths | '**/custom'
          'DS_INCLUDE_DEV_DEPENDENCIES' | :include_dev_dependencies | false
          'SECURE_LOG_LEVEL' | :analyzer_log_level | 'debug'
          # rubocop:enable Layout/LineLength -- TableSyntax
        end

        with_them do
          let(:inputs) { input_name.present? ? { input_name => input_value } : {} }

          it 'sets the variable with the input value if not already set, and export it for the service container' do
            script = python_job.options[:script].join("\n")
            expect(script).to include("export #{variable_name}=\"${#{variable_name}:-#{input_value}}\"") if input_name
            expect(String(python_job.variables.to_hash['DS_PYTHON_RESOLUTION_EXPORTED_VARS']))
              .to match(/\b#{variable_name}\b/)
          end
        end
      end
    end

    context "when resolution jobs are disabled" do
      using RSpec::Parameterized::TableSyntax
      include_context 'when project has files', ["pom.xml", "requirements.txt"]
      include_context 'with default branch pipeline setup'

      where(:case_name, :disabled_resolution_jobs, :jobs) do
        # rubocop:disable Layout/LineLength -- TableSyntax
        'default'       | ''              | %w[dependency-scanning dependency-scanning:maven-resolution dependency-scanning:python-resolution]
        'maven'         | 'maven'         | %w[dependency-scanning dependency-scanning:python-resolution]
        'python'        | 'python'        | %w[dependency-scanning dependency-scanning:maven-resolution]
        'multiple jobs' | 'maven, python' | %w[dependency-scanning]
        # rubocop:enable Layout/LineLength -- TableSyntax
      end

      with_them do
        context 'and input is specified' do
          let(:inputs) { { disabled_resolution_jobs: disabled_resolution_jobs } }

          # Temporary override DS_DISABLED_RESOLUTION_JOBS during rollout of the feature
          include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => '' }

          include_examples 'has expected jobs', params[:jobs]
        end

        context 'and CI/CD variable is specified' do
          include_context 'with CI variables', { 'DS_DISABLED_RESOLUTION_JOBS' => params[:disabled_resolution_jobs] }

          include_examples 'has expected jobs', params[:jobs]
        end
      end
    end
  end
end
