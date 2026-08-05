# frozen_string_literal: true

module Cd
  class ServiceEnvironmentHealth < ApplicationRecord
    self.table_name = 'cd_service_environment_healths'

    belongs_to :service, class_name: 'Cd::Service', inverse_of: :service_environment_healths, optional: false
    belongs_to :environment, class_name: 'Cd::Environment', inverse_of: :service_environment_healths, optional: false
    belongs_to :organization, class_name: '::Organizations::Organization', optional: false

    populate_sharding_key :organization_id, source: :service

    validates :environment_id, uniqueness: { scope: :service_id }
    validates :observed_at, presence: true

    enum :health, {
      unknown: 0,
      healthy: 1,
      degraded: 2,
      failed: 3
    }

    # Worst-to-best severity order. Any degraded/failed signal takes
    # precedence over a healthy one, so problems are never hidden behind a
    # healthy result elsewhere.
    HEALTH_SEVERITY_ORDER = %w[failed degraded healthy unknown].freeze

    # Orders records from worst to best health, per HEALTH_SEVERITY_ORDER. A
    # health value not present in HEALTH_SEVERITY_ORDER (for example, if this
    # enum gains a new value in the future) sorts after all known values,
    # since array_position returns NULL for it and we order nulls last below.
    #
    # Uses a Gitlab::Pagination::Keyset::Order (rather than a plain `order`)
    # because this scope backs the serviceEnvironmentHealths GraphQL
    # connection, which uses keyset pagination; a raw computed expression
    # like array_position can't be paginated without describing it this way.
    # `id` is included as a tiebreaker so the order is fully deterministic.
    scope :ordered_by_severity, -> {
      severity_values = healths.values_at(*HEALTH_SEVERITY_ORDER)
      severity_rank = Arel::Nodes::NamedFunction.new(
        'array_position', [Arel.sql("ARRAY[#{severity_values.join(',')}]"), arel_table[:health]]
      )

      keyset_order = Gitlab::Pagination::Keyset::Order.build([
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'severity_rank',
          order_expression: severity_rank.asc,
          nullable: :nulls_last,
          add_to_projections: true
        ),
        Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
          attribute_name: 'id',
          order_expression: arel_table[:id].asc,
          nullable: :not_nullable
        )
      ])

      reorder(keyset_order)
    }

    # Worst (most severe) health reported for each of the given applications,
    # rolled up across all of that application's services and keyed by
    # application id. Applications with no reported health are omitted, so the
    # caller can distinguish "no signal yet" (absent) from an observed
    # `unknown` signal (present, mapped to :unknown).
    #
    # `unknown` is ranked least severe (see HEALTH_SEVERITY_ORDER), so it never
    # overrides a real signal: an application rolls up to `unknown` only when
    # every one of its services is `unknown`, while any degraded/failed service
    # still wins over a healthy or unknown one.
    def self.worst_health_by_application(application_ids)
      severity_array = "ARRAY[#{healths.values_at(*HEALTH_SEVERITY_ORDER).join(',')}]"
      worst_health = "(#{severity_array})[MIN(array_position(#{severity_array}, " \
        "cd_service_environment_healths.health))]"

      # rubocop:disable Database/AvoidUsingPluckWithoutLimit -- bounded by caller's connection page size
      joins(:service)
        .where(cd_services: { application_id: application_ids })
        .group('cd_services.application_id')
        .pluck('cd_services.application_id', Arel.sql(worst_health))
        .to_h
        .transform_values { |value| healths.key(value) }
      # rubocop:enable Database/AvoidUsingPluckWithoutLimit
    end
  end
end
