# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('ee/elastic/migrate/20260216153009_backfill_traversal_ids_on_commits.rb')

RSpec.describe BackfillTraversalIdsOnCommits, :elastic, :sidekiq_inline, feature_category: :global_search do
  let_it_be(:version) { 20260216153009 }
  let_it_be(:version_mapping_migration) { 20260216152309 }
  let_it_be(:expected_batch_size) { 10_000 }
  let_it_be(:expected_throttle_delay) { 5.seconds }

  let_it_be_with_reload(:projects) { create_list(:project, 3, :repository) }

  it_behaves_like 'migration backfills a field using project-scoped update_by_query' do
    def index_documents_for_projects(projects)
      projects.each { |p| p.repository.index_commits_and_blobs }
    end

    def remove_field_from_indexed_documents(project_ids)
      client = Gitlab::Search::Client.new

      client.update_by_query({
        index: index_name,
        wait_for_completion: true,
        refresh: true,
        body: {
          script: {
            source: "ctx._source.remove('traversal_ids');",
            lang: "painless"
          },
          query: {
            bool: {
              must: [
                { exists: { field: 'traversal_ids' } }
              ],
              filter: [
                { terms: { rid: project_ids } }
              ]
            }
          }
        }
      })
    end
  end

  describe '#batch_update_script' do
    let(:migration) { described_class.new(version) }

    it 'builds script with project data lookup' do
      project1 = create(:project)
      project2 = create(:project)
      projects = [project1, project2]

      script = migration.send(:batch_update_script, projects)

      expect(script[:source]).to eq("ctx._source.traversal_ids = params.project_values[ctx._source.rid.toString()]")
      expect(script[:params][:project_values]).to eq({
        project1.id.to_s => project1.namespace_ancestry,
        project2.id.to_s => project2.namespace_ancestry
      })
    end

    it 'handles empty projects array' do
      script = migration.send(:batch_update_script, [])

      expect(script[:source]).to eq("ctx._source.traversal_ids = params.project_values[ctx._source.rid.toString()]")
      expect(script[:params][:project_values]).to eq({})
    end
  end

  describe 'integration tests with different project sizes', :elastic, :clean_gitlab_redis_shared_state do
    let(:migration) { described_class.new(version) }
    let(:client) { Gitlab::Search::Client.new }

    before do
      stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
      set_elasticsearch_migration_to(version, including: false)

      # Clear any indexed documents from let_it_be projects to prevent test pollution
      client.delete_by_query(
        index: migration.index_name,
        body: { query: { match_all: {} } },
        wait_for_completion: true,
        refresh: true
      )

      # Clear migration state to prevent test pollution from async tasks and phase caching
      migration.set_migration_state(
        projects_in_progress: [],
        current_phase: nil,
        phase_cache_expires_at: nil
      )
    end

    describe 'safe mode processes large projects individually' do
      it 'uses per-project update_by_query for large projects' do
        large_project = create(:project, :repository)

        # Index commits
        large_project.repository.index_commits_and_blobs
        ensure_elasticsearch_index!

        # Remove traversal_ids to simulate unmigrated data
        remove_field_from_indexed_documents([large_project.id])

        # Configure to treat this as a large project
        migration.set_migration_state(
          large_project_threshold: 5, # Low threshold so project is considered "large"
          max_concurrent_tasks: 2
        )

        # Spy on the methods to verify behavior
        allow(migration).to receive(:execute_update_by_query).and_call_original
        allow(migration).to receive(:execute_multi_project_update).and_call_original

        # Run migration
        migration.migrate

        # Verify it used safe mode (per-project updates)
        expect(migration).to have_received(:execute_update_by_query)
        expect(migration).not_to have_received(:execute_multi_project_update)
      end
    end

    describe 'speed mode batches small projects together' do
      it 'uses batched update_by_query for small projects' do
        small_projects = create_list(:project, 3, :repository)

        # Index commits for all projects
        small_projects.each { |p| p.repository.index_commits_and_blobs }
        ensure_elasticsearch_index!

        # Remove traversal_ids to simulate unmigrated data
        remove_field_from_indexed_documents(small_projects.map(&:id))

        # Configure to treat these as small projects
        migration.set_migration_state(
          large_project_threshold: 10_000, # High threshold so projects are "small"
          speed_mode_batch_size: 1000,
          max_concurrent_tasks: 2
        )

        # Spy on the methods to verify behavior
        allow(migration).to receive(:execute_update_by_query).and_call_original
        allow(migration).to receive(:execute_multi_project_update).and_call_original

        # Run migration
        migration.migrate

        # Verify it used speed mode (batched updates)
        expect(migration).to have_received(:execute_multi_project_update)
      end
    end

    describe 'complete migration with mixed project sizes' do
      it 'switches between safe and speed modes and completes migration' do
        # Create mix of projects
        large_project = create(:project, :repository)
        small_projects = create_list(:project, 2, :repository)
        all_projects = [large_project] + small_projects

        # Index commits for all projects
        all_projects.each { |p| p.repository.index_commits_and_blobs }
        ensure_elasticsearch_index!

        # Remove traversal_ids to simulate unmigrated data
        remove_field_from_indexed_documents(all_projects.map(&:id))

        # Configure thresholds to distinguish large vs small
        migration.set_migration_state(
          large_project_threshold: 5, # Large project has more than 5 commits
          speed_mode_batch_size: 100,
          max_concurrent_tasks: 3
        )

        # Run migration until complete
        # Increased iterations to account for phase caching delays
        20.times do
          break if migration.completed?

          migration.migrate
          sleep 0.1 # Give async tasks time to complete
        end

        # Verify migration completed
        expect(migration.completed?).to be(true)
      end
    end

    describe 'orphaned commit cleanup' do
      it 'removes orphaned commits before backfilling' do
        # Create a valid project
        valid_project = create(:project, :repository)
        valid_project.repository.index_commits_and_blobs
        ensure_elasticsearch_index!

        # Remove traversal_ids from valid project's commits
        remove_field_from_indexed_documents([valid_project.id])

        # Insert orphaned commits (project doesn't exist in DB)
        orphaned_project_id = valid_project.id + 999
        insert_orphaned_commit(orphaned_project_id, 'orphan1')
        insert_orphaned_commit(orphaned_project_id, 'orphan2')

        initial_valid_count = count_commits_for_project(valid_project.id)
        expect(count_commits_for_project(orphaned_project_id)).to eq(2)

        # Run migration
        migration.set_migration_state(
          large_project_threshold: 10_000,
          max_concurrent_tasks: 2
        )

        20.times do
          break if migration.completed?

          migration.migrate
          sleep 0.1
        end

        # Orphaned commits should be deleted
        expect(count_commits_for_project(orphaned_project_id)).to eq(0)

        # Valid commits should be preserved and backfilled
        expect(count_commits_for_project(valid_project.id)).to eq(initial_valid_count)

        # Verify valid commits have traversal_ids
        valid_commits = get_commits_for_project(valid_project.id)
        valid_commits.each do |commit|
          expect(commit['_source']['traversal_ids']).to eq(valid_project.namespace_ancestry)
        end
      end

      it 'handles batches with mixed valid and orphaned projects' do
        # Create valid projects
        valid_projects = create_list(:project, 2, :repository)
        valid_projects.each do |p|
          p.repository.index_commits_and_blobs
        end
        ensure_elasticsearch_index!

        # Remove traversal_ids to simulate unmigrated data
        remove_field_from_indexed_documents(valid_projects.map(&:id))

        # Add orphaned commits from multiple non-existent projects
        orphaned_id_1 = valid_projects.last.id + 1000
        orphaned_id_2 = valid_projects.last.id + 2000

        insert_orphaned_commit(orphaned_id_1, 'orphan1')
        insert_orphaned_commit(orphaned_id_2, 'orphan2')

        expect(count_commits_for_project(orphaned_id_1)).to eq(1)
        expect(count_commits_for_project(orphaned_id_2)).to eq(1)

        # Run migration
        migration.set_migration_state(
          large_project_threshold: 10_000,
          max_concurrent_tasks: 3
        )

        20.times do
          break if migration.completed?

          migration.migrate
          sleep 0.1
        end

        # All orphaned commits should be deleted
        expect(count_commits_for_project(orphaned_id_1)).to eq(0)
        expect(count_commits_for_project(orphaned_id_2)).to eq(0)

        # Valid projects should have their commits preserved and backfilled
        valid_projects.each do |project|
          commits = get_commits_for_project(project.id)
          expect(commits).not_to be_empty
          commits.each do |commit|
            expect(commit['_source']['traversal_ids']).to eq(project.namespace_ancestry)
          end
        end
      end
    end

    def remove_field_from_indexed_documents(project_ids)
      client.update_by_query({
        index: migration.index_name,
        wait_for_completion: true,
        refresh: true,
        body: {
          script: {
            source: "ctx._source.remove('traversal_ids');",
            lang: "painless"
          },
          query: {
            bool: {
              must: [
                { exists: { field: 'traversal_ids' } }
              ],
              filter: [
                { terms: { rid: project_ids.map(&:to_s) } }
              ]
            }
          }
        }
      })
    end

    def insert_orphaned_commit(project_id, sha)
      client.index(
        index: migration.index_name,
        id: "#{project_id}_#{sha}",
        body: {
          type: 'commit',
          rid: project_id,
          sha: sha,
          id: sha,
          message: "Commit #{sha}"
        },
        refresh: true
      )
    end

    def count_commits_for_project(project_id)
      client.count(
        index: migration.index_name,
        body: {
          query: {
            bool: {
              filter: [
                { term: { type: 'commit' } },
                { term: { rid: project_id } }
              ]
            }
          }
        }
      )['count']
    end

    def get_commits_for_project(project_id)
      client.search(
        index: migration.index_name,
        body: {
          query: {
            bool: {
              filter: [
                { term: { type: 'commit' } },
                { term: { rid: project_id } }
              ]
            }
          }
        }
      )['hits']['hits']
    end
  end
end
