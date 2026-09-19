# frozen_string_literal: true

namespace :gitlab do
  namespace :geo do
    namespace :logical_replication do
      namespace :publication do
        desc 'GitLab | Geo | Logical Replication | Create the publication on the Geo primary'
        task create: :gitlab_environment do
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort "This is only available on the primary node" unless ::Gitlab::Geo.primary?

          db_connection.execute("CREATE PUBLICATION #{publication_name};")
        rescue ActiveRecord::StatementInvalid => si
          raise unless si.cause.is_a?(PG::DuplicateObject)

          puts "Publication already exists. Not doing anything"
        end

        desc 'GitLab | Geo | Logical Replication | Delete the publication on the Geo primary'
        task delete: :gitlab_environment do
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort "This is only available on the primary node" unless ::Gitlab::Geo.primary?

          db_connection.execute("DROP PUBLICATION #{publication_name};")
        rescue ActiveRecord::StatementInvalid => si
          raise unless si.cause.is_a?(PG::UndefinedObject)

          puts "publication does not exist"
        end

        desc 'GitLab | Geo | Logical Replication | Add and remove tables on the Geo primary publication'
        task set_tables: :create do
          extend Tasks::Gitlab::Geo::LogicalReplication

          current_tables = publication_tables(publication_name)

          db_connection.tables.each do |table|
            if excluded_tables.include?(table)
              next unless current_tables.include?(table)

              puts "Removing #{table}"
              alter_publication("DROP", table)
            else
              next if current_tables.include?(table)

              puts "Adding #{table}"
              alter_publication("ADD", table)
            end
          end
        end
      end

      # These tasks deliberately have no :gitlab_environment dependency: they run against a
      # subscriber that is not a bootable GitLab database yet, so the helper module has to be
      # required rather than autoloaded. See the operational contract in
      # ee/lib/tasks/gitlab/geo/logical_replication.rb.
      namespace :subscription do
        desc 'GitLab | Geo | Logical Replication | Subscription | Refresh the subscription on the Geo secondary'
        task :refresh do
          require_relative './logical_replication'
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort subscriber_connection_string_message if subscriber_connection_string.blank?

          with_subscriber_connection do |connection|
            abort publisher_target_message if local_database_owns_publication?(connection)

            connection.exec("ALTER SUBSCRIPTION #{connection.quote_ident(subscription_name)} REFRESH PUBLICATION")
          end
        rescue PG::UndefinedObject
          abort "Subscription #{subscription_name} does not exist"
        rescue PG::Error => e
          abort "Error refreshing the subscription: #{e.message}"
        end

        desc 'GitLab | Geo | Logical Replication | Subscription | Create the subscription on the Geo secondary'
        task :create do
          require_relative './logical_replication'
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort subscriber_connection_string_message(create: true) if subscriber_connection_string.blank?
          abort publisher_connection_string_message if publisher_connection_string.blank?

          with_subscriber_connection do |connection|
            abort publisher_target_message if local_database_owns_publication?(connection)

            # copy_data = false is the documented way to re-attach to an existing publisher, so the
            # database is expected to already hold data in that case.
            if copy_data?
              begin
                abort seeded_database_message if application_settings_present?(connection)
                abort unseeded_metadata_message unless schema_migrations_present?(connection)
              rescue PG::UndefinedTable
                abort unseeded_database_message
              rescue PG::InsufficientPrivilege => e
                abort unreadable_application_settings_message(connection, e)
              end
            end

            # Scoped tightly to the CREATE so a privilege error raised by a gate query above can
            # never be reported as a missing CREATE SUBSCRIPTION privilege.
            begin
              connection.exec(<<~SQL.squish)
                CREATE SUBSCRIPTION #{connection.quote_ident(subscription_name)}
                CONNECTION #{connection.escape_literal(publisher_connection_string)}
                PUBLICATION #{connection.quote_ident(publication_name)}
                WITH (copy_data = #{copy_data?})
              SQL

              puts copy_data? ? subscription_created_message : "Subscription #{subscription_name} was created."
            rescue PG::DuplicateObject
              puts "Subscription #{subscription_name} already exists. Its connection info was NOT " \
                "verified or updated. If the publisher has changed (for example after a promotion), " \
                "check pg_subscription and recreate it with subscription:drop followed by subscription:create."
            rescue PG::InsufficientPrivilege => e
              abort create_privileges_message(connection, e)
            end
          end
        rescue PG::Error => e
          abort "Error creating the subscription: #{e.message}"
        end

        desc 'GitLab | Geo | Logical Replication | Subscription | Drop the subscription on the Geo secondary'
        task :drop do
          require_relative './logical_replication'
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort subscriber_connection_string_message if subscriber_connection_string.blank?

          with_subscriber_connection do |connection|
            abort publisher_target_message if local_database_owns_publication?(connection)

            subscription = current_database_subscription(connection)

            unless subscription
              puts "Subscription does not exist. Not doing anything"
              next
            end

            # subslotname is nulled out by SET (slot_name = NONE), so a retry after a partial drop
            # would otherwise read nil here; Postgres defaults the slot name to the subscription name
            # and we never override it in subscription:create, so fall back to that.
            slot_name = subscription['subslotname'].presence || subscription_name

            # A drop during initial sync also strands the transient per-table slots
            # (pg_<suboid>_sync_<relid>_<sysid>) on the publisher, so clean those up too.
            sync_slot_pattern = "pg\\_#{Integer(subscription['oid'])}\\_sync\\_%"

            quoted_subscription = connection.quote_ident(subscription_name)

            # Detach the slot before DROP so it never hangs waiting on a publisher connection.
            connection.exec("ALTER SUBSCRIPTION #{quoted_subscription} DISABLE")
            connection.exec("ALTER SUBSCRIPTION #{quoted_subscription} SET (slot_name = NONE)")
            connection.exec("DROP SUBSCRIPTION #{quoted_subscription}")

            if publisher_connection_string.blank?
              puts "Set GEO_PUBLISHER_CONNECTION_STRING to drop the replication slots automatically."
              puts manual_slot_cleanup_message(slot_name, sync_slot_pattern)
            else
              begin
                drop_publisher_replication_slots(slot_name, sync_slot_pattern)
              rescue PG::Error => e
                puts "Warning: could not drop the replication slots on the publisher (#{e.message})"
                puts manual_slot_cleanup_message(slot_name, sync_slot_pattern)
              end
            end
          end
        rescue PG::Error => e
          abort "Error dropping the subscription: #{e.message}"
        end
      end

      # Rails-free for the same reason as the subscription tasks: metadata:seed runs against a
      # subscriber that holds a seeded schema and no subscription yet.
      namespace :metadata do
        desc 'GitLab | Geo | Logical Replication | Metadata | Seed schema_migrations and ' \
          'ar_internal_metadata on the Geo secondary'
        task :seed do
          require_relative './logical_replication'
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort subscriber_connection_string_message if subscriber_connection_string.blank?
          abort publisher_connection_string_message if publisher_connection_string.blank?

          with_subscriber_connection do |connection|
            abort publisher_target_message if local_database_owns_publication?(connection)
            abort metadata_seed_subscription_exists_message if current_database_subscription(connection)

            missing_tables = missing_seeded_metadata_tables(connection)
            abort unseeded_metadata_tables_message(missing_tables) if missing_tables.any?

            # A live GitLab database has no publication and no subscription either, so this is the
            # check that keeps the TRUNCATE below away from one.
            begin
              abort seeded_database_message if application_settings_present?(connection)
            rescue PG::UndefinedTable
              abort unseeded_database_message
            rescue PG::InsufficientPrivilege => e
              abort unreadable_application_settings_message(connection, e)
            end

            publisher_metadata = with_publisher_connection do |publisher|
              read_publisher_metadata(publisher)
            rescue PG::InsufficientPrivilege => e
              abort unreadable_publisher_metadata_message(publisher, e)
            end

            begin
              write_subscriber_metadata(connection, **publisher_metadata)
            rescue PG::InsufficientPrivilege => e
              abort unwritable_metadata_message(connection, e)
            end

            puts metadata_seeded_message(publisher_metadata[:versions], publisher_metadata[:metadata_rows])
          end
        rescue PG::Error => e
          abort "Error seeding the replication metadata: #{e.message}"
        end

        desc 'GitLab | Geo | Logical Replication | Metadata | Verify that the Geo secondary ' \
          'schema_migrations matches the Geo primary'
        task :verify do
          require_relative './logical_replication'
          extend Tasks::Gitlab::Geo::LogicalReplication

          abort subscriber_connection_string_message if subscriber_connection_string.blank?
          abort publisher_connection_string_message if publisher_connection_string.blank?

          publisher_state = with_publisher_connection do |publisher|
            metadata_state(publisher)
          rescue PG::UndefinedTable
            abort missing_metadata_table_message('publisher')
          end

          subscriber_state = with_subscriber_connection do |connection|
            metadata_state(connection)
          rescue PG::UndefinedTable
            abort missing_metadata_table_message('subscriber')
          end

          missing_on_subscriber = publisher_state[:versions] - subscriber_state[:versions]
          extra_on_subscriber = subscriber_state[:versions] - publisher_state[:versions]

          if missing_on_subscriber.any? || extra_on_subscriber.any?
            abort schema_migrations_mismatch_message(missing_on_subscriber, extra_on_subscriber)
          end

          if publisher_state[:environment] != subscriber_state[:environment]
            abort environment_mismatch_message(publisher_state[:environment], subscriber_state[:environment])
          end

          puts schema_migrations_match_message(publisher_state[:versions])
        rescue PG::Error => e
          abort "Error verifying the replication metadata: #{e.message}"
        end
      end

      desc 'GitLab | Geo | Logical Replication | Sync sequences to match table data'
      task sync_sequences: :gitlab_environment do
        only_sequences = ENV['ONLY_SEQUENCES'].presence&.split(',')&.map(&:strip)

        Gitlab::Database::SyncSequencesWithTableData.new(only_sequences: only_sequences).execute
      rescue Gitlab::Database::SyncSequencesWithTableData::Error => e
        abort e.message
      end
    end
  end
end
