# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../elastic/migrate/20260420120000_migrate_migrations_index_to_alias'

RSpec.describe MigrateMigrationsIndexToAlias, :elastic, feature_category: :global_search do
  let(:version) { 20260420120000 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.default }
  let(:client) { Gitlab::Search::Client.new }
  let(:old_index_name) { helper.legacy_migrations_index_name }
  let(:new_alias_name) { helper.migrations_alias_name }
  let(:settings) { { number_of_shards: 1 } }
  let(:mappings) do
    {
      properties: {
        completed: { type: 'boolean' },
        state: { type: 'object' },
        started_at: { type: 'date' },
        completed_at: { type: 'date' },
        name: { type: 'keyword' }
      }
    }
  end

  before do
    cleanup_all_migration_indexes
  end

  after do
    cleanup_all_migration_indexes
  end

  def cleanup_all_migration_indexes
    helper.delete_migrations_index if helper.migrations_index_exists?
    helper.delete_index(index_name: old_index_name) if helper.index_exists?(index_name: old_index_name)

    begin
      all_indexes = client.cat.indices(index: "#{new_alias_name}-*", format: 'json')
      all_indexes.each do |index_info|
        index_name = index_info['index']
        helper.delete_index(index_name: index_name) if helper.index_exists?(index_name: index_name)
      end
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      # No timestamped indexes found, which is fine
    end
  end

  describe '#migrate' do
    context 'when migration is already completed' do
      before do
        timestamped_index = helper.index_name_with_timestamp(new_alias_name)
        helper.create_index(
          index_name: timestamped_index,
          alias_name: new_alias_name,
          with_alias: true,
          settings: settings,
          mappings: mappings
        )
      end

      it 'returns early without migrating' do
        expect(migration).not_to receive(:log)
        migration.migrate
      end
    end

    context 'when new alias already exists (legacy test)' do
      before do
        client.indices.create( # rubocop:disable Rails/SaveBang -- Elasticsearch client does not use ActiveRecord bang methods
          index: old_index_name,
          body: {
            settings: settings,
            mappings: mappings
          }
        )

        timestamped_index = helper.index_name_with_timestamp(new_alias_name)
        helper.create_index(
          index_name: timestamped_index,
          alias_name: new_alias_name,
          with_alias: true,
          settings: settings,
          mappings: mappings
        )
      end

      it 'returns early without migrating' do
        expect(migration).not_to receive(:log)
        migration.migrate
      end
    end

    context 'when old direct index exists with data' do
      let(:test_migrations) do
        [
          { id: '1', name: 'migration_one', completed: true },
          { id: '2', name: 'migration_two', completed: false },
          { id: '3', name: 'migration_three', completed: true }
        ]
      end

      before do
        client.indices.create( # rubocop:disable Rails/SaveBang -- Elasticsearch client does not use ActiveRecord bang methods
          index: old_index_name,
          body: {
            settings: settings,
            mappings: mappings
          }
        )

        test_migrations.each do |migration_data|
          client.index(
            index: old_index_name,
            id: migration_data[:id],
            body: { name: migration_data[:name], completed: migration_data[:completed] },
            refresh: true
          )
        end
      end

      it 'migrates the index to alias pattern' do
        expect(helper.index_exists?(index_name: old_index_name)).to be true
        expect(helper.alias_exists?(name: old_index_name)).to be false
        expect(helper.alias_exists?(name: new_alias_name)).to be false

        migration.migrate

        expect(helper.alias_exists?(name: new_alias_name)).to be true

        alias_info = helper.get_alias_info(new_alias_name)
        physical_index = alias_info.each_key.first
        expect(physical_index).to match(/#{new_alias_name}-\d{8}-\d{4}/)

        test_migrations.each do |migration_data|
          result = client.get(index: new_alias_name, id: migration_data[:id])
          expect(result['_source']['name']).to eq(migration_data[:name])
          expect(result['_source']['completed']).to eq(migration_data[:completed])
        end

        old_count = client.count(index: old_index_name)['count']
        new_count = client.count(index: new_alias_name)['count']
        expect(new_count).to eq(old_count)
        expect(new_count).to eq(test_migrations.size)

        expect(helper.index_exists?(index_name: old_index_name)).to be true
      end

      it 'handles reindex failures gracefully' do
        allow(migration).to receive(:client).and_return(client)
        allow(client).to receive(:reindex).and_raise(StandardError.new('Reindex failed'))

        expect(migration).to receive(:fail_migration_halt_error!).with(error: /Reindex failed/)
        expect { migration.migrate }.to raise_error(StandardError, 'Reindex failed')
      end

      it 'fails if document counts do not match' do
        allow(migration).to receive(:client).and_return(client)
        allow(client).to receive(:reindex).and_call_original
        # Mock count to return mismatched values: old index has 3, new index has 2
        allow(client).to receive(:count) do |args|
          if args[:index] == old_index_name
            { 'count' => 3 }
          else
            { 'count' => 2 }
          end
        end

        expect(migration).to receive(:fail_migration_halt_error!).with(
          error: "Document count mismatch",
          old_count: 3,
          new_count: 2
        )
        migration.migrate
      end
    end
  end

  describe '#completed?' do
    context 'when old index does not exist and new alias exists' do
      before do
        helper.delete_migrations_index
        helper.create_migrations_index
      end

      it 'returns true' do
        expect(migration.completed?).to be true
      end
    end

    context 'when old direct index exists and new alias does not exist' do
      before do
        client.indices.create( # rubocop:disable Rails/SaveBang -- Elasticsearch client does not use ActiveRecord bang methods
          index: old_index_name,
          body: {
            settings: settings,
            mappings: mappings
          }
        )
      end

      it 'returns false' do
        expect(migration.completed?).to be false
      end
    end

    context 'when both old and new exist (migration complete but old index not cleaned up)' do
      before do
        client.indices.create( # rubocop:disable Rails/SaveBang -- Elasticsearch client does not use ActiveRecord bang methods
          index: old_index_name,
          body: {
            settings: settings,
            mappings: mappings
          }
        )

        timestamped_index = helper.index_name_with_timestamp(new_alias_name)
        helper.create_index(
          index_name: timestamped_index,
          alias_name: new_alias_name,
          with_alias: true,
          settings: settings,
          mappings: mappings
        )
      end

      it 'returns true (migration complete even if old index not cleaned up)' do
        expect(migration.completed?).to be true
      end
    end
  end
end
