# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sbom::Ingestion::Tasks::IngestOccurrenceRefs, feature_category: :dependency_management do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project, ref: 'main') }
  let_it_be(:occurrence) { create(:sbom_occurrence, project: project, pipeline: pipeline) }

  let(:occurrence_map) do
    build(:sbom_occurrence_map).tap do |map|
      map.occurrence_id = occurrence.id
      map.occurrence_changed = true
    end
  end

  let(:occurrence_maps) { [occurrence_map] }

  before do
    allow(project).to receive(:default_branch).and_return('main')
    allow(project.repository).to receive(:branch_exists?).with(pipeline.ref).and_return(true)
  end

  subject(:task) { described_class.new(pipeline, occurrence_maps) }

  describe '#execute' do
    context 'when tracked context exists for branch' do
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      it 'creates occurrence refs' do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(1)

        ref = Sbom::OccurrenceRef.last
        expect(ref.sbom_occurrence_id).to eq(occurrence.id)
        expect(ref.security_project_tracked_context_id).to eq(tracked_context.id)
        expect(ref.pipeline).to eq(pipeline)
        expect(ref.project).to eq(project)
        expect(ref.commit_sha).to eq(pipeline.sha)
      end

      it 'is idempotent across repeated executions' do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(1)
        expect { described_class.new(pipeline, occurrence_maps).execute }
          .not_to change { Sbom::OccurrenceRef.count }
      end
    end

    context 'when tracked context exists for tag' do
      let_it_be(:pipeline) { create(:ci_pipeline, project: project, ref: 'v1.0', tag: true) }

      let_it_be(:tag_context) do
        create(:security_project_tracked_context, :tracked, project: project, context_name: pipeline.ref,
          context_type: :tag)
      end

      it 'finds tag context for tag pipeline' do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(1)

        ref = Sbom::OccurrenceRef.last
        expect(ref.tracked_context).to eq(tag_context)
      end
    end

    context 'when tracked context does not exist and is default branch' do
      it 'creates tracked context and occurrence ref' do
        expect { task.execute }
          .to change { Security::ProjectTrackedContext.count }.by(1)
          .and change { Sbom::OccurrenceRef.count }.by(1)

        created_context = Security::ProjectTrackedContext.last
        expect(created_context.context_name).to eq('main')
        expect(created_context.context_type).to eq('branch')
        expect(created_context.is_default).to be(true)
        expect(created_context.project).to eq(project)
      end
    end

    context 'when multiple occurrence maps exist' do
      let(:occurrence2) { create(:sbom_occurrence, project: project, pipeline: pipeline) }
      let(:occurrence_map2) do
        map = build(:sbom_occurrence_map)
        map.occurrence_id = occurrence2.id
        map.occurrence_changed = true
        map
      end

      let(:occurrence_maps) { [occurrence_map, occurrence_map2] }
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context, :tracked, project: project, context_name: pipeline.ref,
          context_type: :branch)
      end

      it 'creates occurrence refs for all valid maps' do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(2)

        refs = Sbom::OccurrenceRef.last(2)
        expect(refs.map(&:sbom_occurrence_id)).to match_array([occurrence.id, occurrence2.id])
        expect(refs.map(&:tracked_context)).to all(eq(tracked_context))
      end
    end

    context 'when an occurrence ref already exists for the (occurrence, tracked_context) pair' do
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      let_it_be(:older_pipeline) { create(:ci_pipeline, project: project, ref: 'main') }

      let_it_be(:existing_ref) do
        create(:sbom_occurrence_ref,
          occurrence: occurrence,
          tracked_context: tracked_context,
          pipeline: older_pipeline,
          project: project,
          commit_sha: 'oldsha0000000000000000000000000000000000')
      end

      context 'and the occurrence changed in this run' do
        before do
          occurrence_map.occurrence_changed = true
        end

        it 'updates the existing ref instead of creating a new one', :aggregate_failures do
          expect { task.execute }.not_to change { Sbom::OccurrenceRef.count }

          existing_ref.reload
          expect(existing_ref.sbom_occurrence_id).to eq(occurrence.id)
          expect(existing_ref.security_project_tracked_context_id).to eq(tracked_context.id)
          expect(existing_ref.pipeline_id).to eq(pipeline.id)
          expect(existing_ref.project_id).to eq(project.id)
          expect(existing_ref.commit_sha).to eq(pipeline.sha)
        end
      end

      context 'and the occurrence did not change in this run' do
        before do
          occurrence_map.occurrence_changed = false
        end

        it 'does not modify the existing ref', :aggregate_failures do
          expect { task.execute }.not_to change { Sbom::OccurrenceRef.count }

          existing_ref.reload
          expect(existing_ref.pipeline_id).to eq(older_pipeline.id)
          expect(existing_ref.commit_sha).to eq('oldsha0000000000000000000000000000000000')
        end
      end
    end

    context 'when the occurrence did not change and no ref exists' do
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      before do
        occurrence_map.occurrence_changed = false
      end

      it 'creates an occurrence ref for the new (occurrence, tracked_context) pair', :aggregate_failures do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(1)

        ref = Sbom::OccurrenceRef.last
        expect(ref.sbom_occurrence_id).to eq(occurrence.id)
        expect(ref.security_project_tracked_context_id).to eq(tracked_context.id)
        expect(ref.pipeline_id).to eq(pipeline.id)
        expect(ref.project_id).to eq(project.id)
        expect(ref.commit_sha).to eq(pipeline.sha)
      end
    end

    context 'when some occurrence maps changed and others did not but have no existing ref' do
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      let(:occurrence2) { create(:sbom_occurrence, project: project, pipeline: pipeline) }
      let(:occurrence_map2) do
        map = build(:sbom_occurrence_map)
        map.occurrence_id = occurrence2.id
        map.occurrence_changed = false
        map
      end

      let(:occurrence_maps) { [occurrence_map, occurrence_map2] }

      before do
        occurrence_map.occurrence_changed = true
      end

      it 'creates refs for both the changed map and the unchanged map without an existing ref' do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(2)

        expect(Sbom::OccurrenceRef.pluck(:sbom_occurrence_id))
          .to match_array([occurrence.id, occurrence2.id])
      end
    end

    context 'when occurrence did not change and a ref exists for a different tracked_context' do
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      let_it_be(:other_tracked_context) do
        create(:security_project_tracked_context,
          :tracked,
          project: project,
          context_name: 'other-branch',
          context_type: :branch)
      end

      let_it_be(:unrelated_ref) do
        create(:sbom_occurrence_ref,
          occurrence: occurrence,
          tracked_context: other_tracked_context,
          pipeline: pipeline,
          project: project,
          commit_sha: 'unrelated00000000000000000000000000000000')
      end

      before do
        occurrence_map.occurrence_changed = false
      end

      it 'creates a ref for the current tracked_context and leaves the unrelated ref untouched', :aggregate_failures do
        expect { task.execute }.to change { Sbom::OccurrenceRef.count }.by(1)

        new_ref = Sbom::OccurrenceRef.find_by(
          sbom_occurrence_id: occurrence.id,
          security_project_tracked_context_id: tracked_context.id
        )
        expect(new_ref).to be_present
        expect(new_ref.commit_sha).to eq(pipeline.sha)

        unrelated_ref.reload
        expect(unrelated_ref.commit_sha).to eq('unrelated00000000000000000000000000000000')
        expect(unrelated_ref.security_project_tracked_context_id).to eq(other_tracked_context.id)
      end
    end

    context 'when finding/creating tracked context fails' do
      let(:error_response) do
        ServiceResponse.error(message: ['Some error'], payload: { tracked_context: nil })
      end

      before do
        allow_next_instance_of(Security::ProjectTrackedContexts::FindOrCreateService) do |service|
          allow(service).to receive(:execute).and_return(error_response)
        end
      end

      it 'raises an error' do
        expect do
          task.execute
        end.to raise_error(RuntimeError,
          /Failed to find or create tracked context for project #{project.id}: Some error/)
      end

      it 'does not create occurrence ref' do
        expect do
          task.execute
        rescue StandardError
          nil
        end.not_to change { Sbom::OccurrenceRef.count }
      end
    end

    context 'when pipeline is not on default branch' do
      let_it_be(:pipeline) { create(:ci_pipeline, project: project, ref: 'feature-branch') }

      it 'raises an error' do
        expect do
          task.execute
        end.to raise_error(RuntimeError)
      end

      it 'does not create tracked context or occurrence ref' do
        expect do
          task.execute
        rescue StandardError
          nil
        end
          .to not_change { Security::ProjectTrackedContext.count }
          .and not_change { Sbom::OccurrenceRef.count }
      end
    end

    context 'when no occurrence maps exist' do
      let(:occurrence_maps) { [] }

      it 'does not create any occurrence refs' do
        expect { task.execute }.not_to change { Sbom::OccurrenceRef.count }
      end
    end
  end

  describe 'edge cases' do
    context 'when tracked context creation fails for default branch' do
      before do
        stub_feature_flags(vac_increased_limit: false)

        Security::ProjectTrackedContext::MAX_TRACKED_REFS_PER_PROJECT.times do |i|
          create(:security_project_tracked_context, :tracked, project: project, context_name: "branch-#{i}")
        end
      end

      it 'raises an error' do
        expect do
          task.execute
        end.to raise_error(RuntimeError, /Failed to find or create tracked context for project #{project.id}/)
      end

      it 'does not create occurrence ref' do
        expect do
          task.execute
        rescue StandardError
          nil
        end.to not_change { Sbom::OccurrenceRef.count }
      end
    end

    context 'when untracked context exists for branch' do
      let_it_be(:untracked_context) do
        create(:security_project_tracked_context, :untracked,
          project: project,
          context_name: pipeline.ref,
          context_type: :branch)
      end

      it 'raises an error' do
        expect do
          task.execute
        end.to raise_error(RuntimeError,
          /Failed to find or create tracked context for project #{project.id}: Context is not tracked/)
      end

      it 'does not create occurrence ref' do
        expect do
          task.execute
        rescue StandardError
          nil
        end.to not_change { Sbom::OccurrenceRef.count }
          .and not_change { Security::ProjectTrackedContext.count }
      end
    end

    context 'when tracked context exists for non-default branch' do
      let_it_be(:pipeline) { create(:ci_pipeline, project: project, ref: 'feature-branch') }
      let_it_be(:tracked_context) do
        create(:security_project_tracked_context, :tracked,
          project: project,
          context_name: 'feature-branch',
          context_type: :branch)
      end

      it 'creates occurrence refs using existing context' do
        expect { task.execute }
          .to change { Sbom::OccurrenceRef.count }.by(1)
          .and not_change { Security::ProjectTrackedContext.count }

        occurrence_ref = Sbom::OccurrenceRef.last
        expect(occurrence_ref.tracked_context).to eq(tracked_context)
      end
    end
  end
end
