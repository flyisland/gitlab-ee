# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FreeTrial::ScanFreeTrialUserService, :saas, time_travel_to: '2023-06-01' do
  subject(:service) { described_class.new.execute }

  let_it_be(:owner, refind: true) { create(:user, created_at: '2022-01-01') }
  let(:subscriptions_response) { { success: true, data: {} } }
  let_it_be(:developer, refind: true) { create(:user, created_at: '2023-01-02') }
  let_it_be(:admin, refind: true) { create(:user, :admin, created_at: '2022-01-02') }
  let_it_be(:blocked_user) { create(:user, :blocked) }
  let_it_be(:banned_user) { create(:user, :banned) }
  let_it_be(:ldap_blocked_user) { create(:user, :ldap_blocked) }
  let_it_be(:bot) { create(:user, :bot) }
  let_it_be(:owner_namespace) { create(:namespace, owner: owner) }
  let_it_be(:developer_namespace) { create(:namespace, owner: developer) }
  let_it_be(:group) { create(:group) }
  let_it_be(:premium_plan) { create(:premium_plan) }
  let_it_be(:ultimate_plan) { create(:ultimate_plan) }
  let_it_be(:ultimate_trial_plan) { create(:ultimate_trial_plan) }
  let_it_be(:today) { Date.new(2023, 6, 1) }
  let_it_be(:first_reminder_date) do
    today - (ENV.fetch('JH_FREE_TRIAL_BLOCK_DAY', 90) - ENV.fetch('JH_FREE_TRIAL_FIRST_REMINDER', 30)).days
  end

  let_it_be(:last_reminder_date) do
    today - (ENV.fetch('JH_FREE_TRIAL_BLOCK_DAY', 90) - ENV.fetch('JH_FREE_TRIAL_LAST_REMINDER', 7)).days
  end

  let_it_be(:block_date_since) do
    today - ENV.fetch('JH_FREE_TRIAL_BLOCK_DAY', 90).days
  end

  let(:free_trial_start_date) { '2023-01-01' }

  before_all do
    group.add_owner(owner)
    [developer, blocked_user, banned_user, ldap_blocked_user, bot].each { |u| group.add_developer(u) }
  end

  before do
    stub_env('JH_FREE_TRIAL_START_DATE', free_trial_start_date)
    allow(::Gitlab::SubscriptionPortal::Client).to receive(:subscriptions).and_return(subscriptions_response).once
  end

  context 'when user is not free trial' do
    context 'when namespace is premium and ultimate' do
      it 'not block user' do
        developer.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')

        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        create(:gitlab_subscription, namespace: developer_namespace, hosted_plan: ultimate_plan)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to be_nil
      end
    end

    context 'when namespace buy ci addon' do
      let(:subscriptions_response) do
        {
          success: true,
          data: {
            "total" => 2,
            "subscriptions" => [
              { 'gl_namespace_id' => developer_namespace.id, 'trial' => false },
              { 'gl_namespace_id' => owner_namespace.id, 'trial' => false }
            ]
          }
        }
      end

      it 'not block user' do
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace buy storage' do
      it 'not block user for group namespace' do
        create(:namespace_limit, namespace: group, additional_purchased_storage_size: 10)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end

      it 'not block user for user namespace' do
        create(:namespace_limit, namespace: owner_namespace, additional_purchased_storage_size: 10)
        create(:namespace_limit, namespace: developer_namespace, additional_purchased_storage_size: 10,
          additional_purchased_storage_ends_on: 1.day.after)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when user is admin' do
      it 'do not block admin user' do
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in).with(0, admin.id)

        service
      end
    end

    context 'when user is project member only' do
      it 'not block project member' do
        another_group = create(:group)
        another_group.add_owner(owner)

        project = create(:project, group: another_group)
        project.add_developer(developer)

        if another_group.gitlab_subscription.present?
          another_group.gitlab_subscription.update(hosted_plan: ultimate_plan)
        else
          create(:gitlab_subscription, namespace: another_group, hosted_plan: ultimate_plan)
        end

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace is set to premium or ultimate directly' do
      it 'not block no end_date subscription of group' do
        create(:gitlab_subscription, namespace: group, hosted_plan: premium_plan, end_date: nil, trial: false)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end

      it 'not block trial is nil ultimate subscription of group' do
        create(:gitlab_subscription, namespace: group, hosted_plan: premium_plan, end_date: nil, trial: nil)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when free group has active gitlab credits' do
      it 'treats users in the group as paid users' do
        developer.custom_attributes.create(key: ::JH::User::FREE_TRIAL_LEFT_DAYS, value: '1')
        create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: group, expires_on: 1.day.after)

        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to be_nil
      end
    end
  end

  context 'when block free trial user' do
    context 'when user created before default date' do
      it 'block developer' do
        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '0')
      end
    end

    context 'when user created after after date' do
      it 'block owner' do
        create(:gitlab_subscription, namespace: developer_namespace, hosted_plan: premium_plan)
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, owner.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace is premium_trial' do
      it 'block ultimate_trial_plan group' do
        create(:gitlab_subscription, namespace: group, hosted_plan: ultimate_trial_plan)
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, owner.id).once
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace plan expired' do
      it 'block user in expire group' do
        gitlab_subscription = create(:gitlab_subscription, namespace: group, hosted_plan: ultimate_plan)
        gitlab_subscription.update(hosted_plan: ultimate_plan, start_date: 2.years.ago, end_date: 1.year.ago)
        gitlab_subscription.update(hosted_plan: ultimate_plan, start_date: 1.year.ago, end_date: 6.months.ago)
        gitlab_subscription.update(hosted_plan: ultimate_trial_plan, start_date: 6.months.ago, end_date: 1.month.after)

        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, owner.id).once
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace storage addon expired' do
      it 'block developer namespace' do
        create(:namespace_limit, namespace: owner_namespace, additional_purchased_storage_size: 10)
        create(:namespace_limit, namespace: developer_namespace, additional_purchased_storage_size: 10,
          additional_purchased_storage_ends_on: '2023-01-01')

        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace gitlab credit expired' do
      it 'uses credit expire date as free trial start date' do
        create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: group, expires_on: '2023-01-01')

        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, owner.id).once
        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when user role is guest' do
      let(:another_group) { create(:group) }

      before do
        another_group.add_owner(owner)
        another_group.add_guest(developer)
      end

      it 'guest user is free trial in ultimate plan' do
        create(:gitlab_subscription, namespace: another_group, hosted_plan: ultimate_plan)

        expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end

      it 'guest user is NOT free trial in premium plan' do
        create(:gitlab_subscription, namespace: another_group, hosted_plan: premium_plan)

        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)
        expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end
  end

  context 'when send first reminder email' do
    let(:trial_end_date) { (today + ENV.fetch('JH_FREE_TRIAL_FIRST_REMINDER', 30).days).to_s }

    context 'when namespace plan expired' do
      it 'send first email to developer' do
        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        developer_subscription = create(:gitlab_subscription, namespace: developer_namespace, hosted_plan: premium_plan,
          end_date: first_reminder_date)
        developer_subscription.update(hosted_plan: ultimate_trial_plan, end_date: 1.year.after)
        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :first_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '30')
      end
    end

    context 'when namespace storage addon expired' do
      it 'send first email to developer' do
        create(:namespace_limit, namespace: owner_namespace, additional_purchased_storage_size: 10)
        create(:namespace_limit, namespace: developer_namespace, additional_purchased_storage_size: 10,
          additional_purchased_storage_ends_on: first_reminder_date)

        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :first_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace gitlab credit expired' do
      it 'send first email to developer' do
        credit_group = create(:group)
        credit_group.add_owner(developer)
        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: credit_group,
          expires_on: first_reminder_date)

        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :first_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '30')
      end
    end
  end

  context 'when send last reminder email' do
    let(:trial_end_date) { (today + ENV.fetch('JH_FREE_TRIAL_LAST_REMINDER', 7).days).to_s }

    context 'when namespace plan expired' do
      it 'send last email to developer' do
        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        developer_subscription = create(:gitlab_subscription, namespace: developer_namespace, hosted_plan: premium_plan,
          end_date: last_reminder_date)
        developer_subscription.update(hosted_plan: ultimate_trial_plan, end_date: 1.year.after)
        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :last_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '7')
      end
    end

    context 'when namespace storage addon expired' do
      it 'send last email to developer' do
        create(:namespace_limit, namespace: owner_namespace, additional_purchased_storage_size: 10)
        create(:namespace_limit, namespace: developer_namespace, additional_purchased_storage_size: 10,
          additional_purchased_storage_ends_on: last_reminder_date)

        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :last_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service
      end
    end

    context 'when namespace gitlab credit expired' do
      it 'send last email to developer' do
        credit_group = create(:group)
        credit_group.add_owner(developer)
        create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
        create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: credit_group,
          expires_on: last_reminder_date)

        expect(::FreeTrial::RemindFreeTrialUserWorker).to receive(:perform_in)
                                                            .with(0, developer.id, :last_free_trial_reminder,
                                                              trial_end_date)
        expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)

        service

        expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '7')
      end
    end
  end

  context 'when namespace gitlab credit is close to blocking threshold' do
    it 'does not remind or block users when credit expired 89 days ago' do
      create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: group,
        expires_on: 1.day.after(block_date_since))

      expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)
      expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

      service

      expect(owner.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '1')
      expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '1')
    end

    it 'blocks users when credit expired 91 days ago' do
      create(:gitlab_subscription_add_on_purchase, :gitlab_credits, namespace: group,
        expires_on: 1.day.before(block_date_since))

      expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, owner.id).once
      expect(::FreeTrial::BlockFreeTrialUserWorker).to receive(:perform_in).with(0, developer.id).once
      expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

      service

      expect(owner.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '0')
      expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '0')
    end
  end

  context 'when CDot api failed' do
    it 'raise exception' do
      allow(::Gitlab::SubscriptionPortal::Client).to receive(:subscriptions).and_return({ success: false }).once
      expect { service }.to raise_error(::Gitlab::SubscriptionPortal::Client::SubscriptionPortalRESTException)
    end
  end

  context 'when dry run' do
    it 'log block user' do
      create(:gitlab_subscription, namespace: owner_namespace, hosted_plan: premium_plan)
      expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)
      expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)
      expect(Sidekiq.logger).to receive(:info).with(any_args).once
      expect(Sidekiq.logger).to receive(:info).with(class: described_class.name, method: :block_free_trial_users,
        values: [developer.id]).once
      expect(Sidekiq.logger).to receive(:info).with(class: described_class.name, method: :first_free_trial_reminder,
        values: [], trial_end_date: "2023-07-01").once
      expect(Sidekiq.logger).to receive(:info).with(class: described_class.name, method: :last_free_trial_reminder,
        values: [], trial_end_date: "2023-06-08").once

      described_class.new(dry_run: true).execute
    end
  end

  context 'when free trial user is not overdue' do
    it 'not block user when namespace is expired before free trial start date' do
      stub_env('JH_FREE_TRIAL_START_DATE', Time.zone.today.to_s)

      gitlab_subscription = create(:gitlab_subscription, namespace: group, hosted_plan: ultimate_plan)
      gitlab_subscription.update(hosted_plan: ultimate_plan, start_date: 2.years.ago, end_date: 1.year.ago)
      gitlab_subscription.update(hosted_plan: ultimate_plan, start_date: 1.year.ago, end_date: 7.months.ago)
      gitlab_subscription.update(hosted_plan: ultimate_trial_plan, start_date: 7.months.ago, end_date: 1.month.after)

      expect(::FreeTrial::BlockFreeTrialUserWorker).not_to receive(:perform_in)
      expect(::FreeTrial::RemindFreeTrialUserWorker).not_to receive(:perform_in)

      service

      expect(developer.last_custom_attribute).to have_attributes(key: 'free_trial_left_days', value: '90')
    end
  end

  context 'when checking expired plan namespace hash' do
    let(:expired_subscription_date) { 1.month.ago.to_date }
    let(:expired_history_date) { 2.months.ago.to_date }

    context 'when namespace has expired subscription' do
      it 'returns expired date from GitlabSubscription' do
        create(:gitlab_subscription, namespace: group, hosted_plan: premium_plan,
          end_date: expired_subscription_date, trial: false)

        result = described_class.new.send(:expired_plan_namespace_hash)
        expect(result[group.id]).to eq(expired_subscription_date)
      end
    end

    context 'when namespace has expired subscription history' do
      it 'returns expired date from SubscriptionHistory' do
        create(:gitlab_subscription_history, namespace: group, hosted_plan: premium_plan,
          end_date: expired_history_date, trial: false)

        result = described_class.new.send(:expired_plan_namespace_hash)
        expect(result[group.id]).to eq(expired_history_date)
      end
    end

    context 'when namespace has both expired subscription and history' do
      it 'prioritizes GitlabSubscription expired date' do
        create(:gitlab_subscription, namespace: group, hosted_plan: premium_plan,
          end_date: expired_subscription_date, trial: false)
        create(:gitlab_subscription_history, namespace: group, hosted_plan: premium_plan,
          end_date: expired_history_date, trial: false)

        result = described_class.new.send(:expired_plan_namespace_hash)
        expect(result[group.id]).to eq(expired_subscription_date)
      end
    end
  end
end
