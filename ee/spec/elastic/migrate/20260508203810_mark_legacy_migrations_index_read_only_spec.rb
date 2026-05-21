# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../elastic/migrate/20260508203810_mark_legacy_migrations_index_read_only'

RSpec.describe MarkLegacyMigrationsIndexReadOnly, :elastic, feature_category: :global_search do
  let(:version) { 20260508203810 }
  let(:migration) { described_class.new(version) }
  let(:helper) { Gitlab::Elastic::Helper.default }
  let(:client) { Gitlab::Search::Client.new }
  let(:old_index_name) { helper.legacy_migrations_index_name }
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
    cleanup_index
  end

  after do
    cleanup_index
  end

  def cleanup_index
    helper.delete_index(index_name: old_index_name) if helper.index_exists?(index_name: old_index_name)
  end

  def create_index(index_settings: settings, index_mappings: mappings)
    client.indices.create( # rubocop:disable Rails/SaveBang -- Elasticsearch client does not use ActiveRecord bang methods
      index: old_index_name,
      body: {
        settings: index_settings,
        mappings: index_mappings
      }
    )
  end

  describe '#migrate' do
    context 'when old index does not exist' do
      it 'logs and returns early' do
        allow(migration).to receive(:completed?).and_return(false)
        allow(migration).to receive(:log)

        migration.migrate

        expect(migration).to have_received(:log).with(/does not exist/)
      end
    end

    context 'when old index exists and is not read-only' do
      before do
        create_index
      end

      it 'marks the index as read-only' do
        expect(helper.index_exists?(index_name: old_index_name)).to be true
        expect(migration.completed?).to be false

        migration.migrate

        expect(migration.completed?).to be true

        # Verify the write block is set
        index_settings = client.indices.get_settings(index: old_index_name)
        write_block = index_settings.dig(old_index_name, 'settings', 'index', 'blocks', 'write')
        expect(write_block.to_s).to eq('true')
      end

      it 'prevents write operations after migration' do
        migration.migrate

        # Attempt to index a document should fail
        expect do
          client.index(
            index: old_index_name,
            id: 'test',
            body: { name: 'test' },
            refresh: true
          )
        end.to raise_error(Gitlab::Search::Client::AuthorizationError)
      end
    end

    context 'when migration is already completed' do
      before do
        create_index(
          index_settings: settings.merge(
            index: {
              blocks: {
                write: true
              }
            }
          )
        )
      end

      it 'returns early without re-applying settings' do
        expect(migration.completed?).to be true
        expect(helper).not_to receive(:update_settings)
        migration.migrate
      end
    end

    context 'when an error occurs' do
      before do
        create_index
      end

      it 'raises the error and allows retry_on_failure to handle it' do
        allow_next_instance_of(Gitlab::Elastic::Helper) do |helper|
          allow(helper).to receive(:update_settings).and_raise(StandardError.new('Connection failed'))
        end

        expect { migration.migrate }.to raise_error(StandardError, 'Connection failed')
      end
    end
  end

  describe '#completed?' do
    context 'when old index does not exist' do
      it 'returns true' do
        expect(migration.completed?).to be true
      end
    end

    context 'when old index exists but is not read-only' do
      before do
        create_index
      end

      it 'returns false' do
        expect(migration.completed?).to be false
      end
    end

    context 'when old index exists and is read-only' do
      before do
        create_index(
          index_settings: settings.merge(
            index: {
              blocks: {
                write: true
              }
            }
          )
        )
      end

      it 'returns true' do
        expect(migration.completed?).to be true
      end
    end
  end
end
