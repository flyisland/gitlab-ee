# frozen_string_literal: true

module GitlabSubscriptions
  module AddOnMetrics
    extend ActiveSupport::Concern

    private

    def generate_add_on_metrics
      active_add_on_purchases_with_seat_counts.map do |purchase|
        {
          add_on_type: purchase.add_on.name,
          purchased_seats: purchased_seats_for(purchase),
          assigned_seats: purchase.assigned_users_count
        }
      end
    end

    def purchased_seats_for(purchase)
      # GitLab Credits is not a seat-based add-on, so we report 0 purchased seats
      # to avoid confusion with seat-based metrics
      purchase.add_on.gitlab_credits? ? 0 : purchase.quantity
    end

    def active_add_on_purchases_with_seat_counts
      GitlabSubscriptions::AddOnPurchase
        .active
        .by_namespace(nil)
        .eager_load(:add_on)
        .left_joins(:assigned_users)
        .select(
          :quantity,
          :subscription_add_on_id,
          'COUNT(subscription_user_add_on_assignments.id) AS assigned_users_count'
        )
        .group(:id, 'subscription_add_ons.id')
    end
  end
end
