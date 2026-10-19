# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BuildDetailsEntity, feature_category: :continuous_integration do
  describe '#as_json' do
    let(:project) { create(:project, :repository) }
    let(:user) { project.first_owner }
    let(:pipeline) { create(:ci_pipeline, project: project) }
    let(:build) { create(:ci_build, :failed, pipeline: pipeline) }
    let(:request) { EntityRequest.new(project: project, current_user: user) }

    let(:entity) do
      described_class.new(build, request: request, current_user: user, project: project)
    end

    subject(:serialized_entity) { entity.as_json }

    context 'when the job is pending' do
      let(:build) { create(:ci_build, :pending, pipeline: pipeline) }

      it 'exposes the tags update path for the project owner' do
        expect(serialized_entity[:update_tags_path]).to eq(
          Gitlab::Routing.url_helpers.update_tags_project_job_path(project, build)
        )
      end

      context 'with different project roles' do
        using RSpec::Parameterized::TableSyntax

        let(:user) { create(:user) }

        where(:role, :allowed) do
          :guest      | false
          :planner    | false
          :reporter   | false
          :developer  | false
          :maintainer | true
          :owner      | true
        end

        with_them do
          before do
            project.add_role(user, role)
          end

          it 'exposes the tags update path only to maintainers and owners' do
            expect(serialized_entity.key?(:update_tags_path)).to eq(allowed)
          end
        end
      end

      context 'when the user cannot retry the job' do
        let(:user) { create(:user) }

        it 'does not expose the tags update path' do
          expect(serialized_entity).not_to have_key(:update_tags_path)
        end
      end

      context 'when a runner is assigned' do
        before do
          build.update!(runner: create(:ci_runner))
        end

        it 'does not expose the tags update path' do
          expect(serialized_entity).not_to have_key(:update_tags_path)
        end
      end
    end
  end
end
