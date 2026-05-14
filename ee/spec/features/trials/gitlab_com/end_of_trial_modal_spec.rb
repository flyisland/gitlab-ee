# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'End of trial modal', :saas_gitlab_com_subscriptions, :js, feature_category: :acquisition do
  include SubscriptionPortalHelpers

  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'when duo enterprise is available' do
    context 'when widget is expired' do
      let_it_be(:group_with_expired_trial) do
        create(
          :group_with_plan,
          plan: :free_plan,
          trial: true,
          trial_starts_on: Date.current,
          trial_ends_on: 30.days.from_now,
          owners: user
        )
      end

      before do
        stub_billing_plans(group_with_expired_trial.id)
        stub_subscription_monthly_commitment_request
      end

      it 'shows modal with purchase credits CTA and allows dismissal' do
        visit group_path(group_with_expired_trial)

        expect(page).not_to have_testid('end-of-trial-modal')

        travel_to(31.days.from_now) do
          page.refresh

          within_testid('end-of-trial-modal') do
            expect(page).to have_content('Your trial has ended')
            expect(page).to have_link('Purchase GitLab Credits')
            expect(page).to have_link('Upgrade to Premium')

            click_link 'Purchase GitLab Credits'
          end

          wait_for_all_requests

          visit group_path(group_with_expired_trial)

          expect(page).not_to have_testid('end-of-trial-modal')
        end
      end
    end
  end
end
