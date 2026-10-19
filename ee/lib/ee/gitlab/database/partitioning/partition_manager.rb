# frozen_string_literal: true

module EE
  module Gitlab
    module Database
      module Partitioning
        module PartitionManager
          extend ::Gitlab::Utils::Override
          include ::Gitlab::Utils::StrongMemoize

          private

          # A database fed by logical replication only creates partitions: detaching could remove a range the
          # publisher still writes to, and changing the parent takes an ACCESS EXCLUSIVE lock that stalls the
          # apply worker.
          override :logical_replication_subscriber?
          def logical_replication_subscriber?
            return false unless geo_node_table_exists?

            # Reads GeoNode.current_node rather than the process-memoized Gitlab::Geo.current_node, so a
            # promoted site leaves replica mode without a restart.
            node = ::GeoNode.current_node if ::Gitlab::Geo.enabled?
            # geo_nodes arrives through the subscription, so a subscriber still in its initial copy has no node yet
            replicated = node ? node.secondary? : ::Gitlab::Geo::LogicalReplication.subscription_names(connection).any?

            # Asks the database being synced, not ApplicationRecord.database (always main). A streaming standby
            # is read-only, so it keeps the default behaviour.
            replicated && !::Gitlab::Utils.to_boolean(connection.select_value('SELECT pg_is_in_recovery()'))
          end
          strong_memoize_attr :logical_replication_subscriber?

          # Not Gitlab::Geo.connected?: Rails opens connections lazily, and it reports one that has not
          # run a query yet as inactive, which would turn replica mode off for the first model synced on it.
          def geo_node_table_exists?
            ::GeoNode.table_exists?
          rescue ActiveRecord::ActiveRecordError, PG::Error
            false
          end
        end
      end
    end
  end
end
