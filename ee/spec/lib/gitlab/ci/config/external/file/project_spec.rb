# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::External::File::Project, feature_category: :pipeline_composition do
  include RepoHelpers

  let_it_be(:context_project) { create(:project) }
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user, developer_of: project) }

  let(:context_user) { user }
  let(:context) { Gitlab::Ci::Config::External::Context.new(**context_params) }
  let(:project_file) { described_class.new(params, context) }
  let(:pipeline_policy_context) { nil }
  let(:context_params) do
    {
      project: context_project,
      sha: project.commit.sha,
      user: context_user,
      pipeline_policy_context: pipeline_policy_context
    }
  end

  before do
    allow_next_instance_of(Gitlab::Ci::Config::External::Context) do |instance|
      allow(instance).to receive(:check_execution_time!)
    end
  end

  describe '#valid?' do
    subject(:valid?) do
      Gitlab::Ci::Config::External::Mapper::Verifier.new(context).process([project_file])
      project_file.valid?
    end

    describe 'security_policy_management_project_access_allowed?' do
      include_context 'with pipeline policy context'

      let(:params) { { file: 'pipeline-execution-policy.yml', project: project.full_path } }
      let(:creating_policy_pipeline) { true }

      around do |example|
        create_and_delete_files(project,
          { '/pipeline-execution-policy.yml' => { compliance_job: { script: 'test' } }.to_yaml }) do
          example.run
        end
      end

      shared_examples_for 'user has no access to the project' do
        it 'returns false' do
          expect(valid?).to be(false)
          expect(project_file.error_message).to include("Project `#{project.full_path}` not found or access denied!")
        end
      end

      shared_examples_for 'user has access to the project' do
        it 'returns true' do
          expect(valid?).to be(true)
        end
      end

      context 'when user does not have permission to access file' do
        let(:context_user) { create(:user) }

        it_behaves_like 'user has no access to the project'

        context 'and project is a security policy project' do
          let_it_be(:security_orchestration_policy_configuration, reload: true) do
            create(:security_orchestration_policy_configuration, security_policy_management_project: project,
              project: context_project)
          end

          it_behaves_like 'user has access to the project'

          context 'and project is linked to the context project as a security policy project' do
            before_all do
              security_orchestration_policy_configuration.update!(project: context_project)
            end

            it_behaves_like 'user has access to the project'

            context 'when user is authenticated via CI_JOB_TOKEN', :request_store do
              let(:parent_project) { build_stubbed(:project) }
              let(:job) { build_stubbed(:ci_build, project: parent_project, user: context_user) }

              before do
                context_user.set_ci_job_token_scope!(job)
              end

              it_behaves_like 'user has access to the project'
            end

            context 'when creating_policy_pipeline? is false' do
              let(:creating_policy_pipeline) { false }

              it_behaves_like 'user has no access to the project'
            end

            context 'when project forbids SPP repository access via project settings' do
              before do
                project.project_setting.update!(spp_repository_pipeline_access: false)
              end

              it_behaves_like 'user has no access to the project'
            end
          end
        end
      end
    end

    describe 'pipeline_execution_policy_bot_file_access_allowed?' do
      include_context 'with pipeline policy context'

      let_it_be(:root_group, freeze: true) { create(:group) }
      let_it_be(:target_project, freeze: true) { create(:project, :repository, group: root_group) }
      let_it_be(:bot_project, freeze: true) { create(:project, group: root_group) }
      let_it_be(:bot_user, freeze: true) { create(:user, :security_policy_bot, maintainer_of: bot_project) }

      let(:params) { { file: 'ci/policy.yml', project: target_project.full_path } }
      let(:creating_policy_pipeline) { true }
      let(:context_user) { bot_user }

      around do |example|
        create_and_delete_files(target_project,
          { '/ci/policy.yml' => { compliance_job: { script: 'test' } }.to_yaml }) do
          example.run
        end
      end

      shared_examples_for 'bot has no access to the project' do
        it 'is invalid and includes an access denied error', :aggregate_failures do
          expect(valid?).to be(false)
          expect(project_file.error_message).to include(
            "Project `#{target_project.full_path}` not found or access denied!"
          )
        end
      end

      shared_examples_for 'bot has access to the project' do
        specify { expect(valid?).to be(true) }
      end

      context 'when bot access is not enabled' do
        it_behaves_like 'bot has no access to the project'
      end

      context 'when bot access is enabled' do
        before do
          target_project.project_setting.update!(
            pipeline_execution_policy_bot_access_enabled: true,
            pipeline_execution_policy_bot_access_file_patterns: ['ci/**/*.yml']
          )

          allow_next_found_instance_of(ProjectSetting) do |setting|
            allow(setting).to receive(:pipeline_execution_policy_bot_access_experiment_enabled?).and_return(true)
          end
        end

        it_behaves_like 'bot has access to the project'

        context 'when validating multiple includes in the same request', :request_store do
          let(:additional_project_file) { described_class.new(params, context) }

          before do
            allow_next_instance_of(ProjectSetting) do |instance|
              allow(instance).to receive(:allows_pipeline_execution_policy_bot_access?)
                          .and_return(true)
            end

            allow(bot_user).to receive(:security_policy_bot_project).and_call_original
          end

          it 'caches access checks in SafeRequestStore' do
            Gitlab::Ci::Config::External::Mapper::Verifier.new(context).process([
              project_file,
              additional_project_file
            ])

            expect(project_file).to be_valid
            expect(additional_project_file).to be_valid
            expect(bot_user).to have_received(:security_policy_bot_project).once
          end
        end

        context 'when context user is nil' do
          let(:context_user) { nil }

          it_behaves_like 'bot has no access to the project'
        end

        context 'when bot user has no bot project' do
          before do
            allow(bot_user).to receive(:security_policy_bot_project).and_return(nil)
          end

          it_behaves_like 'bot has no access to the project'
        end

        context 'when file does not match pattern' do
          let(:params) { { file: 'other/policy.yml', project: target_project.full_path } }

          around do |example|
            create_and_delete_files(target_project,
              { '/other/policy.yml' => { compliance_job: { script: 'test' } }.to_yaml }) do
              example.run
            end
          end

          it_behaves_like 'bot has no access to the project'
        end

        context 'when bot project is outside allowed group hierarchy' do
          let_it_be(:other_group) { create(:group) }
          let_it_be(:bot_project, freeze: true) { create(:project, group: other_group) }
          let_it_be(:bot_user, freeze: true) do
            create(:user, :security_policy_bot, maintainer_of: bot_project)
          end

          it_behaves_like 'bot has no access to the project'
        end

        context 'when user is not a security policy bot' do
          let_it_be(:regular_user, freeze: true) { create(:user, maintainer_of: bot_project) }

          let(:context_user) { regular_user }

          it_behaves_like 'bot has no access to the project'
        end

        context 'when creating_policy_pipeline? is false' do
          let(:creating_policy_pipeline) { false }

          it_behaves_like 'bot has no access to the project'
        end
      end
    end
  end
end
