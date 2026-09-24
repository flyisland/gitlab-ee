# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gitlab:db namespace rake task', :silence_stdout, feature_category: :database do
  before(:all) do
    Rake.application.rake_require '../jh/lib/tasks/gitlab/db'
    Rake.application.rake_require 'active_record/railties/databases'
    Rake.application.rake_require 'tasks/seed_fu'
    Rake.application.rake_require 'tasks/gitlab/click_house/migration'
    Rake.application.rake_require 'tasks/gitlab/db'
    Rake.application.rake_require 'tasks/gitlab/db/lock_writes'
  end

  before do
    # Stub out db tasks
    allow(Rake::Task['db:migrate']).to receive(:invoke).and_return(true)
    allow(Rake::Task['db:schema:load']).to receive(:invoke).and_return(true)
    allow(Rake::Task['db:seed_fu']).to receive(:invoke).and_return(true)
    allow(Rake::Task['gitlab:db:lock_writes']).to receive(:invoke).and_return(true)
    stub_feature_flags(disallow_database_ddl_feature_flags: false)
  end

  # rubocop:disable RSpec/VerifiedDoubles -- we need to stub the connection
  describe 'mark_migration_complete' do
    context 'with multiple databases' do
      let(:main_model) { double(:model, connection: double(:connection)) }
      let(:jh_model) { double(:model, connection: double(:connection)) }
      let(:base_models) { { 'main' => main_model, 'jh' => jh_model } }

      before do
        skip_if_shared_database(:jh)

        allow(Gitlab::Database).to receive(:database_base_models_with_gitlab_shared).and_return(base_models)
      end

      context 'with jh configured' do
        before do
          skip_unless_jh_configured
        end

        xit 'creates a task for the jh database' do
          expect(jh_model.connection).to receive(:quote).with('123').and_return("'123'")
          expect(jh_model.connection).to receive(:execute)
            .with("INSERT INTO schema_migrations (version) VALUES ('123')")

          run_rake_task('gitlab:db:mark_migration_complete:jh', '[123]')
        end
      end
    end
  end

  describe 'configure' do
    context 'with multiple databases' do
      let(:main_db_config) { double(:db_config, name: 'main') }
      let(:jh_db_config) { double(:db_config, name: 'jh') }
      let(:main_pool) { double(:pool, db_config: main_db_config) }
      let(:jh_pool) { double(:pool, db_config: jh_db_config) }
      let(:main_connection) { double(:connection, pool: main_pool) }
      let(:jh_connection) { double(:connection, pool: jh_pool) }
      let(:main_model) { double(:model, connection: main_connection) }
      let(:jh_model) { double(:model, connection: jh_connection) }
      let(:base_models) { { 'main' => main_model, 'jh' => jh_model }.with_indifferent_access }

      let(:main_config) { double(:config, name: 'main') }
      let(:jh_config) { double(:config, name: 'jh') }

      before do
        skip_if_shared_database(:jh)

        allow(Gitlab::Database).to receive(:database_base_models_with_gitlab_shared).and_return(base_models)
        allow(Gitlab::Database::Partitioning).to receive(:sync_partitions)
      end

      context 'when jh is not configured' do
        before do
          allow(ActiveRecord::Base).to receive_message_chain('configurations.configs_for')
            .and_return([main_config, jh_config])
        end

        context 'when no database has the schema loaded' do
          before do
            allow(main_model.connection).to receive(:tables).and_return(%w[schema_migrations])
            allow(jh_model.connection).to receive(:tables).and_return([])
          end

          it 'loads the schema and seeds all the databases' do
            expect(Rake::Task['db:schema:load:main']).to receive(:invoke)
            expect(Rake::Task['db:schema:load:jh']).to receive(:invoke)

            expect(Rake::Task['db:migrate:main']).not_to receive(:invoke)
            expect(Rake::Task['db:migrate:jh']).not_to receive(:invoke)

            expect(Rake::Task['gitlab:db:lock_writes']).to receive(:invoke)
            expect(Rake::Task['db:seed_fu']).to receive(:invoke)

            run_rake_task('gitlab:db:configure')
          end
        end

        context 'when both databases have the schema loaded' do
          before do
            allow(main_model.connection).to receive(:tables).and_return(%w[table1 table2])
            allow(jh_model.connection).to receive(:tables).and_return(%w[table1 table2])
          end

          it 'migrates the databases without seeding them' do
            expect(Rake::Task['db:migrate:main']).to receive(:invoke)
            expect(Rake::Task['db:migrate:jh']).to receive(:invoke)

            expect(Rake::Task['db:schema:load:main']).not_to receive(:invoke)
            expect(Rake::Task['db:schema:load:jh']).not_to receive(:invoke)

            expect(Rake::Task['db:seed_fu']).not_to receive(:invoke)

            run_rake_task('gitlab:db:configure')
          end
        end

        context 'when only one database has the schema loaded' do
          before do
            allow(main_model.connection).to receive(:tables).and_return(%w[table1 table2])
            allow(jh_model.connection).to receive(:tables).and_return([])
          end

          it 'migrates and loads the schema correctly, without seeding the databases' do
            expect(Rake::Task['db:migrate:main']).to receive(:invoke)
            expect(Rake::Task['db:schema:load:main']).not_to receive(:invoke)

            expect(Rake::Task['db:schema:load:jh']).to receive(:invoke)
            expect(Rake::Task['db:migrate:jh']).not_to receive(:invoke)

            expect(Rake::Task['db:seed_fu']).not_to receive(:invoke)

            run_rake_task('gitlab:db:configure')
          end
        end
      end

      context 'when jh is configured' do
        let(:jh_config) { double(:config, name: 'jh') }

        before do
          skip_unless_jh_configured

          allow(main_model.connection).to receive(:tables).and_return(%w[schema_migrations])
          allow(jh_model.connection).to receive(:tables).and_return(%w[schema_migrations])
        end

        it 'does not run tasks against jh' do
          expect(Rake::Task['db:schema:load:main']).to receive(:invoke)
          expect(Rake::Task['db:schema:load:jh']).to receive(:invoke)
          expect(Rake::Task['db:seed_fu']).to receive(:invoke)

          expect(Rake::Task['db:migrate:jh']).not_to receive(:invoke)
          expect(Rake::Task['db:schema:load:jh']).not_to receive(:invoke)

          run_rake_task('gitlab:db:configure')
        end
      end
    end
  end

  describe 'drop_tables' do
    let(:tables) { %w[one two schema_migrations] }
    let(:views) { %w[three four pg_stat_statements] }
    let(:schemas) { Gitlab::Database::EXTRA_SCHEMAS }
    let(:ignored_views) { double(ActiveRecord::Relation, pluck: ['pg_stat_statements']) }

    before do
      allow(Gitlab::Database::PgDepend).to receive(:using_connection).and_yield
      allow(Gitlab::Database::PgDepend).to receive(:from_pg_extension).with('VIEW').and_return(ignored_views)
    end

    context 'with multiple databases', :aggregate_failures do
      let(:main_model) { double(:model, connection: double(:connection, tables: tables, views: views)) }
      let(:jh_model) { double(:model, connection: double(:connection, tables: tables, views: views)) }
      let(:base_models) { { 'main' => main_model, 'jh' => jh_model } }

      before do
        skip_if_shared_database(:jh)

        allow(Gitlab::Database).to receive(:database_base_models_with_gitlab_shared).and_return(base_models)

        allow(main_model.connection).to receive(:table_exists?).with('schema_migrations').and_return(true)
        allow(jh_model.connection).to receive(:table_exists?).with('schema_migrations').and_return(true)

        (tables + views + schemas).each do |name|
          allow(main_model.connection).to receive(:quote_table_name).with(name).and_return("\"#{name}\"")
          allow(jh_model.connection).to receive(:quote_table_name).with(name).and_return("\"#{name}\"")
        end

        allow(Backup::DatabaseConnection).to receive(:new).with('main')
          .and_return(instance_double(Backup::DatabaseConnection, connection: main_model.connection))
        allow(Backup::DatabaseConnection).to receive(:new).with('jh')
          .and_return(instance_double(Backup::DatabaseConnection, connection: jh_model.connection))
      end

      it 'drops all objects for all databases', :aggregate_failures do
        expect_objects_to_be_dropped(main_model.connection)
        expect_objects_to_be_dropped(jh_model.connection)

        run_rake_task('gitlab:db:drop_tables')
      end

      context 'when the single database task is used' do
        it 'drops all objects for the given database', :aggregate_failures do
          expect_objects_to_be_dropped(main_model.connection)

          expect(jh_model.connection).not_to receive(:execute)

          run_rake_task('gitlab:db:drop_tables:main')
        end
      end
    end

    def expect_objects_to_be_dropped(connection)
      expect(connection).to receive(:execute).with('DROP TABLE IF EXISTS "one" CASCADE')
      expect(connection).to receive(:execute).with('DROP TABLE IF EXISTS "two" CASCADE')

      expect(connection).to receive(:execute).with('DROP VIEW IF EXISTS "three" CASCADE')
      expect(connection).to receive(:execute).with('DROP VIEW IF EXISTS "four" CASCADE')
      expect(Gitlab::Database::PgDepend).to receive(:from_pg_extension).with('VIEW')
      expect(connection).not_to receive(:execute).with('DROP VIEW IF EXISTS "pg_stat_statements" CASCADE')

      expect(connection).to receive(:execute).with('TRUNCATE schema_migrations')

      Gitlab::Database::EXTRA_SCHEMAS.each do |schema|
        expect(connection).to receive(:execute).with("DROP SCHEMA IF EXISTS \"#{schema}\" CASCADE")
      end
    end
  end

  describe 'create_dynamic_partitions' do
    context 'with multiple databases' do
      before do
        skip_if_shared_database(:jh)
      end

      context 'when running the multi-database variant' do
        it 'delegates syncing of partitions without limiting databases' do
          expect(Gitlab::Database::Partitioning).to receive(:sync_partitions)

          run_rake_task('gitlab:db:create_dynamic_partitions')
        end
      end
    end
  end

  describe 'reindex' do
    context 'with multiple databases' do
      let(:base_models) { { 'main' => double(:model), 'jh' => double(:model) } }

      before do
        skip_if_multiple_databases_not_setup(:jh)

        allow(Gitlab::Database).to receive(:database_base_models_with_gitlab_shared).and_return(base_models)
      end

      it 'delegates to Gitlab::Database::Reindexing without a specific database' do
        expect(Gitlab::Database::Reindexing).to receive(:invoke).with(no_args)

        run_rake_task('gitlab:db:reindex')
      end

      context 'when the single database task is used' do
        before do
          skip_if_shared_database(:jh)
        end

        xit 'delegates to Gitlab::Database::Reindexing with a specific database' do
          expect(Gitlab::Database::Reindexing).to receive(:invoke).with('jh')

          run_rake_task('gitlab:db:reindex:jh')
        end

        context 'when reindexing is not enabled' do
          xit 'is a no-op' do
            expect(Gitlab::Database::Reindexing).to receive(:enabled?).and_return(false)
            expect(Gitlab::Database::Reindexing).not_to receive(:invoke)

            expect { run_rake_task('gitlab:db:reindex:jh') }.to raise_error(SystemExit)
          end
        end
      end
    end
  end

  context 'with multiple databases', :reestablished_active_record_base do
    before do
      skip_if_shared_database(:jh)
    end

    describe 'db:migrate against jh single database' do
      xit 'invokes gitlab:db:create_dynamic_partitions for the same database' do
        expect(Rake::Task['gitlab:db:create_dynamic_partitions:jh']).to receive(:invoke).once.and_return(true)

        expect { run_rake_task('db:migrate:jh') }.not_to raise_error
      end
    end
  end

  def run_rake_task(task_name, arguments = '')
    Rake::Task[task_name].reenable
    Rake.application.invoke_task("#{task_name}#{arguments}")
  end

  def skip_unless_jh_configured
    skip 'Skipping because the jh database is not configured' unless jh_configured?
  end

  def jh_configured?
    !!ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'jh')
  end
  # rubocop:enable RSpec/VerifiedDoubles
end
