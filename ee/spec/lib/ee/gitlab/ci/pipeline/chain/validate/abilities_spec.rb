# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Chain::Validate::Abilities, feature_category: :continuous_integration do
  let_it_be(:project, freeze: false) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  let(:pipeline) do
    build_stubbed(:ci_pipeline, project: project)
  end

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command
      .new(project: project, current_user: user, origin_ref: ref)
  end

  let(:step) { described_class.new(pipeline, command) }
  let(:ref) { 'master' }

  describe '#perform!' do
    before_all do
      project.add_developer(user)
    end

    context 'when triggering builds for project mirrors is disabled' do
      before do
        allow(project).to receive(:mirror_trigger_builds?).and_return(false)
      end

      context 'when the gitaly_context includes "pull-mirror-update" => true' do
        let(:command) do
          Gitlab::Ci::Pipeline::Chain::Command
            .new(
              project: project,
              current_user: user,
              origin_ref: ref,
              gitaly_context: { 'pull-mirror-update' => true }
            )
        end

        it 'returns an error' do
          step.perform!

          expect(pipeline.errors.to_a)
            .to include('Pipeline is disabled for mirror updates')
        end
      end

      context 'when mirror_update is true' do
        let(:command) do
          Gitlab::Ci::Pipeline::Chain::Command
            .new(project: project, current_user: user, origin_ref: ref, mirror_update: true)
        end

        it 'returns an error' do
          step.perform!

          expect(pipeline.errors.to_a)
            .to include('Pipeline is disabled for mirror updates')
        end
      end
    end

    context 'when the maintainer is blocked by IP restriction' do
      # Project must belong to a group to use IP restriction
      let_it_be(:project, freeze: false) { create(:project, :in_group) }

      before do
        allow_next_instance_of(Gitlab::IpRestriction::Enforcer) do |enforcer|
          allow(enforcer).to receive(:allows_current_ip?).and_return(false)
        end

        step.perform!
      end

      it 'adds an error about insufficient permissions' do
        expect(pipeline.errors.to_a)
          .to include(/Insufficient permissions/)
      end

      it 'breaks the pipeline builder chain' do
        expect(step.break?).to be true
      end
    end

    context 'when user is security policy bot' do
      let_it_be(:bot_user) { create(:user, :security_policy_bot) }
      let(:command) do
        Gitlab::Ci::Pipeline::Chain::Command
          .new(project: project, current_user: bot_user, origin_ref: ref)
      end

      before do
        create(:protected_branch, project: project, name: ref)
      end

      it 'adds an error about insufficient permissions' do
        step.perform!

        expect(pipeline.errors.to_a)
          .to include(/Insufficient permissions/)
      end

      context 'when user is a guest in the project' do
        before_all do
          project.add_guest(bot_user)
        end

        before do
          step.perform!
        end

        it 'does not produce errors' do
          expect(pipeline.errors).to be_empty
        end
      end
    end

    context 'when pushing to a protected branch via an approval policy bypass' do
      let_it_be(:bot_user) { create(:user, :project_bot) }
      let_it_be(:personal_access_token) { create(:personal_access_token, user: bot_user) }

      let(:command) do
        Gitlab::Ci::Pipeline::Chain::Command
          .new(project: project, current_user: bot_user, origin_ref: ref, source: :push)
      end

      before_all do
        project.add_developer(bot_user)
      end

      before do
        create(:protected_branch, project: project, name: ref)
        stub_licensed_features(security_orchestration_policies: true)
        allow(::Gitlab::Audit::Auditor).to receive(:audit)
      end

      context 'when the security policy grants the actor a protected branch bypass' do
        before do
          create(:security_policy, :approval_policy, linked_projects: [project],
            bypass_access_token_ids: [personal_access_token.id])
        end

        it 'does not add a permission error so the push pipeline can be created' do
          step.perform!

          expect(pipeline.errors).to be_empty
        end

        it 'does not re-audit the bypass already logged by the push' do
          expect(::Gitlab::Audit::Auditor).not_to receive(:audit)
            .with(hash_including(name: 'security_policy_protected_branch_bypass'))

          step.perform!
        end

        context 'when the pipeline is not created from a push' do
          %i[web schedule api].each do |non_push_source|
            context "with a #{non_push_source} pipeline" do
              let(:command) do
                Gitlab::Ci::Pipeline::Chain::Command
                  .new(project: project, current_user: bot_user, origin_ref: ref, source: non_push_source)
              end

              it 'does not apply the push-path bypass and adds a permission error' do
                step.perform!

                expect(pipeline.errors.to_a)
                  .to include(/You do not have sufficient permission to run a pipeline/)
              end

              it 'does not audit a bypass that no push path evaluated' do
                expect(::Gitlab::Audit::Auditor).not_to receive(:audit)
                  .with(hash_including(name: 'security_policy_protected_branch_bypass'))

                step.perform!
              end
            end
          end
        end
      end

      context 'when the security policy does not grant the actor a bypass' do
        before do
          create(:security_policy, :approval_policy, linked_projects: [project])
        end

        it 'adds an error about insufficient permissions' do
          step.perform!

          expect(pipeline.errors.to_a)
            .to include(/You do not have sufficient permission to run a pipeline/)
        end
      end
    end

    context 'when user is a security manager' do
      let_it_be(:current_user) { create(:user, security_manager_of: project) }

      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'and pipeline is for a DAST on-demand scan' do
        let(:command) do
          Gitlab::Ci::Pipeline::Chain::Command
            .new(project: project, current_user: current_user, origin_ref: ref, source: :ondemand_dast_scan)
        end

        it 'does not add errors to the pipeline' do
          step.perform!

          expect(pipeline.errors).to be_empty
        end
      end

      context 'and pipeline is not for a DAST on-demand scan' do
        let(:command) do
          Gitlab::Ci::Pipeline::Chain::Command
            .new(project: project, current_user: current_user, origin_ref: ref)
        end

        it 'adds an error about insufficient permissions' do
          step.perform!

          expect(pipeline.errors.to_a).to include(/Insufficient permissions to create a new pipeline/)
        end
      end
    end
  end
end
