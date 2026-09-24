# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Patch::AdditionalDatabaseTasks, feature_category: :database do
  describe Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordDatabaseTasksDumpFilename do
    subject(:tasks) do
      Class.new do
        prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordDatabaseTasksDumpFilename

        def schema_dump_path(*)
          Rails.root.join('foo.sql').to_s
        end
      end.new
    end

    describe '#schema_dump_path' do
      using RSpec::Parameterized::TableSyntax

      where(:db_config_name, :structure_path) do
        :main | 'foo.sql'
        :jh | 'jh/db/structure.sql'
      end

      with_them do
        let(:db_config) { ActiveRecord::DatabaseConfigurations::HashConfig.new('test', db_config_name, {}) }

        it 'returns the correct path for the structure.sql file' do
          expect(tasks.schema_dump_path(db_config)).to eq Rails.root.join(structure_path).to_s
        end
      end
    end
  end

  describe Gitlab::Patch::AdditionalDatabaseTasks::SchemaCacheDumpPath do
    describe '#default_schema_cache_path' do
      using RSpec::Parameterized::TableSyntax

      let(:db_config) { ActiveRecord::DatabaseConfigurations::HashConfig.new('test', db_config_name, {}) }

      before do
        allow(db_config).to receive(:primary?).and_return(primary)
      end

      where(:db_config_name, :primary, :schema_cache_path) do
        :main | true  | 'db/schema_cache.yml'
        :jh   | false | Rails.root.join('jh/db/schema_cache.yml').to_s
      end

      with_them do
        it 'returns the correct path for the schema_cache file' do
          expect(db_config.default_schema_cache_path).to eq schema_cache_path
        end
      end
    end
  end

  describe Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath do
    describe '#configured_migrate_path' do
      context 'when super returns nil' do
        subject(:tasks) do
          Class.new do
            prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath

            def configured_migrate_path
              nil
            end
          end.new
        end

        it 'returns nil' do
          expect(tasks.configured_migrate_path).to be_nil
        end
      end

      context 'when super returns only one regular migration path' do
        subject(:tasks) do
          Class.new do
            prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath

            def configured_migrate_path
              'jh/db/migrate'
            end
          end.new
        end

        it 'returns the configured migrate path' do
          expect(tasks.configured_migrate_path).to eq('jh/db/migrate')
        end
      end

      context 'when super returns only one post migrations path' do
        subject(:tasks) do
          Class.new do
            prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath

            def configured_migrate_path
              'jh/db/post_migrate'
            end
          end.new
        end

        it 'returns nil' do
          expect(tasks.configured_migrate_path).to be_nil
        end
      end

      context 'when super does not include a post migrations path' do
        subject(:tasks) do
          Class.new do
            prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath

            def configured_migrate_path
              'jh/db/migrate'
            end
          end.new
        end

        it 'returns the configured migrations path' do
          expect(tasks.configured_migrate_path).to eq('jh/db/migrate')
        end
      end

      context 'when super includes a post migrations path' do
        subject(:tasks) do
          Class.new do
            prepend Gitlab::Patch::AdditionalDatabaseTasks::ActiveRecordMigrationConfiguredMigratePath

            def configured_migrate_path
              ['jh/db/migrate', 'jh/db/post_migrate']
            end
          end.new
        end

        it 'returns the regular migration path' do
          expect(tasks.configured_migrate_path).to eq('jh/db/migrate')
        end
      end
    end
  end
end
