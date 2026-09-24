# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/BeforeAllRoleAssignment
RSpec.describe ::GitlabSubscriptions::PreviewBillableUserChangeService, feature_category: :subscription_management do
  describe '#execute' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:role) { :developer }
    let(:target_namespace) { create(:group_with_plan, plan: :ultimate_plan) }
    let(:existing_user) { create(:user) }
    let(:eligible_for_usage_alerts) { true }
    let(:usage_alert_eligibility_service) do
      instance_double(GitlabSubscriptions::Reconciliations::CheckSeatUsageAlertsEligibilityService,
        execute: eligible_for_usage_alerts)
    end

    before do
      allow(::Gitlab).to receive(:com?).and_return(true)
      stub_saas_features(gitlab_com_subscriptions: true)
      target_namespace.add_developer(existing_user)
      allow(GitlabSubscriptions::Reconciliations::CheckSeatUsageAlertsEligibilityService)
        .to receive(:new).and_return(usage_alert_eligibility_service)
    end

    context 'when adding more users than seats in subscription' do
      let_it_be(:add_user_ids) do
        10.times.map do |i| # rubocop:disable Performance/TimesMap
          non_existing_record_id - i
        end
      end

      subject(:execute) do
        described_class.new(
          current_user: current_user,
          target_namespace: target_namespace,
          role: role,
          add_user_ids: add_user_ids
        ).execute
      end

      context 'when block seat overages' do
        before do
          allow(target_namespace).to receive(:block_seat_overages?).and_return(true)
        end

        it 'returns `will_increase_overage: false`' do
          expect(execute).to include({
            success: true,
            data: {
              will_increase_overage: false,
              new_billable_user_count: 11,
              seats_in_subscription: 10
            }
          })
        end
      end

      context 'when not block seat overages' do
        before do
          allow(target_namespace).to receive(:block_seat_overages?).and_return(false)
        end

        it 'returns `will_increase_overage: true`' do
          expect(execute).to include({
            success: true,
            data: {
              will_increase_overage: true,
              new_billable_user_count: 11,
              seats_in_subscription: 10
            }
          })
        end
      end
    end
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/BeforeAllRoleAssignment
