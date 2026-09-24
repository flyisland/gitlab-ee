# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscription, :saas, feature_category: :subscription_management do
  ['free', *Plan::PAID_HOSTED_PLANS].map { |name| "#{name}_plan" }.each do |plan| # rubocop:disable RSpec/UselessDynamicDefinition -- `plan` used in `let_it_be`
    let_it_be(plan) { create(plan) } # rubocop:disable Rails/SaveBang
  end

  describe 'callbacks' do
    context 'with before_update', :freeze_time do
      let(:gitlab_subscription) do
        create(
          :gitlab_subscription,
          seats_in_use: 20,
          max_seats_used: 42,
          max_seats_used_changed_at: 1.month.ago,
          seats: 13,
          seats_owed: 29,
          start_date: Time.zone.today - 1.year
        )
      end

      context 'when switches back to team plan from ultimate_trial_paid_customer plan' do
        before do
          gitlab_subscription.update!(hosted_plan: team_plan)
          gitlab_subscription.update!(hosted_plan: ultimate_trial_paid_customer_plan)
        end

        it 'does not reset seat statistics' do
          expect do
            gitlab_subscription.update!(hosted_plan: team_plan)
          end.to not_change(gitlab_subscription, :max_seats_used)
            .and not_change(gitlab_subscription, :max_seats_used_changed_at)
            .and not_change(gitlab_subscription, :seats_owed)
        end

        context 'when the team_plan was renewed during the ultimate_trial_paid_customer trial' do
          before do
            gitlab_subscription.update!(start_date: Time.zone.today + 2.years, end_date: Time.zone.today + 3.years)
          end

          it 'resets seat statistics' do
            expect do
              gitlab_subscription.update!(hosted_plan: team_plan)
            end.to change { gitlab_subscription.max_seats_used }.from(42).to(1)
              .and change { gitlab_subscription.seats_owed }.from(29).to(0)
              .and change { gitlab_subscription.seats_in_use }.from(20).to(1)
          end
        end
      end
    end
  end
end
