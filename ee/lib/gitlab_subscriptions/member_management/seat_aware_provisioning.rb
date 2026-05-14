# frozen_string_literal: true

module GitlabSubscriptions
  module MemberManagement
    module SeatAwareProvisioning
      SEAT_AWARE_PROVISIONING_CACHE_PERIOD = 48.hours

      SEAT_AWARE_PROVISIONING_ROOT_GROUPS_CACHE_KEY = 'seat_aware_provisioning:group:{%{date}}'
      SEAT_AWARE_PROVISIONING_USERS_CACHE_KEY = 'seat_aware_provisioning:group:%{root_namespace_id}:{%{date}}'
      SEAT_AWARE_PROVISIONING_INSTANCE_CACHE_KEY = 'seat_aware_provisioning:instance:{%{date}}'

      def calculate_adjusted_access_level(source, invitee, requested_access_level, extra = {})
        adjusted_access_level = adjust_access_level_for_seat_availability(source, invitee, requested_access_level)

        if adjusted_access_level != requested_access_level
          log_bso_access_level_adjustment(source, invitee, requested_access_level, adjusted_access_level, extra)
        end

        adjusted_access_level
      end

      def track_ma_provisioning_event(root_namespace, user_identifier)
        return unless feature_flag_enabled?(root_namespace)
        return unless user_identifier

        if ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
          track_namespace_provisioning_event(root_namespace, user_identifier)
        else
          track_instance_provisioning_event(user_identifier)
        end
      end

      private

      def adjust_access_level_for_seat_availability(source, invitee, desired_access_level)
        return desired_access_level unless feature_flag_enabled?(source)
        return desired_access_level unless apply_bso_adjustment?(source)
        return desired_access_level if seats_available_for_desired_access?(source, invitee, desired_access_level)

        ::Gitlab::Access::MINIMAL_ACCESS
      end

      def feature_flag_enabled?(source)
        if ::Gitlab::Saas.feature_available?(:gitlab_com_subscriptions)
          ::Feature.enabled?(:bso_minimal_access_fallback, source.root_ancestor)
        else
          ::Feature.enabled?(:bso_minimal_access_fallback, :instance)
        end
      end

      def apply_bso_adjustment?(source)
        ::GitlabSubscriptions::MemberManagement::BlockSeatOverages.block_seat_overages?(source)
      end

      def seats_available_for_desired_access?(source, invitee, access_level)
        user_identifier = invitee.is_a?(User) ? invitee.id : invitee

        ::GitlabSubscriptions::MemberManagement::BlockSeatOverages.seats_available_for?(
          source, [user_identifier], access_level, nil
        )
      end

      def log_bso_access_level_adjustment(source, invitee, requested_access_level, adjusted_access_level, extra = {})
        user = invitee.is_a?(User) ? invitee : nil

        log_data = {
          message: 'Group membership access level adjusted due to BSO seat limits',
          group_id: source.id,
          group_path: source.full_path,
          user_id: user&.id,
          requested_access_level: requested_access_level,
          adjusted_access_level: adjusted_access_level,
          feature_flag: 'bso_minimal_access_fallback'
        }.merge(extra)

        ::Gitlab::AppLogger.info(log_data)
      end

      def track_namespace_provisioning_event(root_namespace, user_identifier)
        ::Gitlab::Redis::SharedState.with do |redis|
          redis.pipelined do |p|
            p.sadd(format_root_groups_cache_key, root_namespace.id.to_s)
            p.expire(format_root_groups_cache_key, SEAT_AWARE_PROVISIONING_CACHE_PERIOD)

            p.sadd(format_users_cache_key(root_namespace.id), user_identifier.to_s)
            p.expire(format_users_cache_key(root_namespace.id), SEAT_AWARE_PROVISIONING_CACHE_PERIOD)
          end
        end
      end

      def track_instance_provisioning_event(user_identifier)
        ::Gitlab::Redis::SharedState.with do |redis|
          redis.pipelined do |p|
            p.sadd(format_instance_cache_key, user_identifier.to_s)
            p.expire(format_instance_cache_key, SEAT_AWARE_PROVISIONING_CACHE_PERIOD)
          end
        end
      end

      def current_date
        @current_date ||= Date.current.iso8601
      end

      def format_users_cache_key(root_namespace_id)
        format(
          SEAT_AWARE_PROVISIONING_USERS_CACHE_KEY,
          root_namespace_id: root_namespace_id,
          date: current_date
        )
      end

      def format_instance_cache_key
        format(
          SEAT_AWARE_PROVISIONING_INSTANCE_CACHE_KEY,
          date: current_date
        )
      end

      def format_root_groups_cache_key
        format(
          SEAT_AWARE_PROVISIONING_ROOT_GROUPS_CACHE_KEY,
          date: current_date
        )
      end
    end
  end
end
