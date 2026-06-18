# frozen_string_literal: true

module SeatAlert
  module Admin
    class ThresholdComponent < BaseComponent
      private

      def title
        _('Your instance is approaching its seat limit')
      end

      def body_text
        if restricted_access?
          safe_format(
            n_(
              'Your instance has used %{used_seats} of %{total_seats} seat. ' \
                'When no seats remain, restricted access will block new users from ' \
                'being added to prevent overages.',
              'Your instance has used %{used_seats} of %{total_seats} seats. ' \
                'When no seats remain, restricted access will block new users from ' \
                'being added to prevent overages.',
              total_user_count
            ),
            used_seats: used_seats,
            total_seats: total_user_count
          )
        else
          safe_format(
            n_(
              'Your instance has used %{used_seats} of %{total_seats} seat. ' \
                'When no seats remain, adding new users will put your instance into ' \
                'overage. Purchase more seats and turn on restricted access to block ' \
                'new users automatically.',
              'Your instance has used %{used_seats} of %{total_seats} seats. ' \
                'When no seats remain, adding new users will put your instance into ' \
                'overage. Purchase more seats and turn on restricted access to block ' \
                'new users automatically.',
              total_user_count
            ),
            used_seats: used_seats,
            total_seats: total_user_count
          )
        end
      end

      def alert_variant
        :info
      end
    end
  end
end
