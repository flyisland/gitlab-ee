# frozen_string_literal: true

module FreeTrial
  class ScanFreeTrialUserService
    include Gitlab::Utils::StrongMemoize

    PAID_PLANS = ENV.fetch('JH_FREE_TRIAL_PAID_PLANS', 'team,premium,ultimate')
    JH_FREE_TRIAL_BLOCK_DAY = ENV.fetch('JH_FREE_TRIAL_BLOCK_DAY', 90).to_i
    JH_FREE_TRIAL_FIRST_REMINDER = ENV.fetch('JH_FREE_TRIAL_FIRST_REMINDER', 30).to_i
    JH_FREE_TRIAL_LAST_REMINDER = ENV.fetch('JH_FREE_TRIAL_LAST_REMINDER', 7).to_i
    JH_FREE_TRIAL_DATA_KEEP_DURATION = ENV.fetch('JH_FREE_TRIAL_DATA_KEEP_DURATION', 3).to_i
    FREE_TRIAL_WORKER_BATCH = ENV.fetch('FREE_TRIAL_WORKER_BATCH', 7200).to_i
    FREE_TRIAL_WORKER_BATCH_DELAY = ENV.fetch('FREE_TRIAL_WORKER_BATCH_DELAY', 1800).to_i

    def initialize(dry_run: false, batch_size: 1000)
      @dry_run = dry_run
      @batch_size = batch_size
      @today = Date.current
      @first_reminder_date = @today - (JH_FREE_TRIAL_BLOCK_DAY - JH_FREE_TRIAL_FIRST_REMINDER).days
      @last_reminder_date = @today - (JH_FREE_TRIAL_BLOCK_DAY - JH_FREE_TRIAL_LAST_REMINDER).days
      @block_date_since = @today - JH_FREE_TRIAL_BLOCK_DAY.days
      Sidekiq.logger.info(class: self.class.name, today: @today, first_reminder_date: @first_reminder_date,
        last_reminder_date: @last_reminder_date, block_date_since: @block_date_since,
        default_free_trial_start_date: default_free_trial_start_date)
    end

    def execute
      block_user_list, first_reminder_users_list, last_reminder_users_list = find_free_trial_user_list
      block_free_trial_users(block_user_list)
      send_first_reminder_email(first_reminder_users_list)
      send_last_reminder_email(last_reminder_users_list)
    end

    private

    def send_first_reminder_email(user_id_list)
      trial_end_date = (@today + JH_FREE_TRIAL_FIRST_REMINDER.days).to_s
      if @dry_run
        Sidekiq.logger.info(class: self.class.name, method: :first_free_trial_reminder, values: user_id_list,
          trial_end_date: trial_end_date)
      else
        batch_run(RemindFreeTrialUserWorker, user_id_list, :first_free_trial_reminder, trial_end_date)
      end
    end

    def send_last_reminder_email(user_id_list)
      trial_end_date = (@today + JH_FREE_TRIAL_LAST_REMINDER.days).to_s
      if @dry_run
        Sidekiq.logger.info(class: self.class.name, method: :last_free_trial_reminder, values: user_id_list,
          trial_end_date: trial_end_date)
      else
        batch_run(RemindFreeTrialUserWorker, user_id_list, :last_free_trial_reminder, trial_end_date)
      end
    end

    def block_free_trial_users(user_id_list)
      if @dry_run
        Sidekiq.logger.info(class: self.class.name, method: :block_free_trial_users, values: user_id_list)
      else
        batch_run(BlockFreeTrialUserWorker, user_id_list)
      end
    end

    def batch_run(worker_klass, batches, *args)
      batch_count = 0
      batches.each_slice(FREE_TRIAL_WORKER_BATCH) do |batch|
        batch.each do |item|
          worker_klass.perform_in(batch_count * FREE_TRIAL_WORKER_BATCH_DELAY, item, *args)
        end
        batch_count += 1
      end
    end

    def expired_user_hash
      merged_hash = merged_expired_namespace_hash
      merged_hash.each_with_object({}) do |(namespace_id, expired_date), result|
        # expire date before default_free_trial_start_date will be ignore
        next if expired_date.before?(default_free_trial_start_date)

        users_in_namespace(namespace_id).each do |user_id|
          result[user_id] ||= Set.new
          result[user_id] << expired_date
        end
      end
    end

    strong_memoize_attr :expired_user_hash

    def paid_user_hash
      all_namespace_ids = available_storage_namespace_list +
        available_plan_namespace_list + available_credit_namespace_list + ci_purchase_namespaces_list
      users_in_namespace(all_namespace_ids).index_with(true)
    end

    strong_memoize_attr :paid_user_hash

    def users_in_namespace(namespace_list)
      result = []
      Namespace.id_in(namespace_list).each_batch(of: @batch_size) do |namespaces|
        namespaces.each do |namespace|
          if namespace.is_a?(Group)
            # according to ee/app/models/ee/group.rb#billed_user_ids
            # guest user in ultimate plan is not billed, so we treat them as free trial user
            namespace.billed_user_ids[:user_ids].each { |id| result << id }
          else
            result << namespace.owner_id
          end
        end
      end
      result
    end

    def find_free_trial_user_list
      block_user_list = []
      first_reminder_users_list = []
      last_reminder_users_list = []
      User.human.not_admins.without_forbidden_states.each_batch(of: @batch_size) do |users|
        users.each do |user|
          if paid_user_hash.has_key?(user.id)
            user.remove_free_trial_left_days
            next
          end

          free_trial_start_date = if expired_user_hash.has_key?(user.id)
                                    expired_user_hash[user.id].max
                                  elsif user.created_at.before?(default_free_trial_start_date)
                                    default_free_trial_start_date
                                  else
                                    user.created_at.to_date
                                  end

          left_days = JH_FREE_TRIAL_BLOCK_DAY - (@today - free_trial_start_date).to_i
          user.mark_free_trial_left_days(left_days)

          if free_trial_start_date == @first_reminder_date
            first_reminder_users_list << user.id
          elsif free_trial_start_date == @last_reminder_date
            last_reminder_users_list << user.id
          elsif free_trial_start_date == @block_date_since || free_trial_start_date.before?(@block_date_since)
            block_user_list << user.id
          end
        end
      end

      [block_user_list, first_reminder_users_list, last_reminder_users_list]
    end

    def ci_purchase_namespaces_list
      ## ci mins does not have expired date, so skip check ci mins expire date
      res = ::Gitlab::SubscriptionPortal::Client.subscriptions
      if res.is_a?(Hash) && res[:success] == false
        raise ::Gitlab::SubscriptionPortal::Client::SubscriptionPortalRESTException,
          'Cannot fetch subscription purchase list'
      end

      res.dig(:data, 'subscriptions')&.each_with_object([]) do |subscription, result|
        result << subscription['gl_namespace_id'] if !subscription['trial'] && subscription['gl_namespace_id'].present?
      end || []
    end

    def storage_purchase_namespace_limit_list
      # rubocop: disable CodeReuse/ActiveRecord -- query namespace buy storage addon before
      NamespaceLimit.where('additional_purchased_storage_size > 0').to_a
      # rubocop: enable CodeReuse/ActiveRecord
    end

    strong_memoize_attr :storage_purchase_namespace_limit_list

    def available_storage_namespace_list
      storage_purchase_namespace_limit_list.each_with_object([]) do |limit, memo|
        # if no ends date then we think it last forever
        if limit.additional_purchased_storage_ends_on.nil? || limit.additional_purchased_storage_ends_on >= @today
          memo << limit.namespace_id
        end
      end
    end

    def expired_storage_namespace_hash
      storage_purchase_namespace_limit_list.each_with_object({}) do |limit, memo|
        if limit.additional_purchased_storage_ends_on&.before?(@today)
          memo[limit.namespace_id] = limit.additional_purchased_storage_ends_on
        end
      end
    end

    def available_plan_namespace_list
      # rubocop: disable CodeReuse/ActiveRecord -- query available plan namespace
      GitlabSubscription.where(hosted_plan_id: paid_plan_ids)
                        .and(GitlabSubscription.where(trial: nil).or(GitlabSubscription.where(trial: false)))
                        .and(GitlabSubscription.where(end_date: nil).or(GitlabSubscription.where(end_date: @today..)))
                        .pluck(:namespace_id)
      # rubocop: enable CodeReuse/ActiveRecord
    end

    def expired_plan_namespace_hash
      result = {}

      # rubocop: disable CodeReuse/ActiveRecord
      ::GitlabSubscription
        .select('namespace_id, end_date AS expired_date')
        .where(trial: false, hosted_plan_id: paid_plan_ids)
        .where(end_date: ...@today)
        .group(:namespace_id, :end_date)
        .each do |subscription|
          result[subscription.namespace_id] = subscription.expired_date
        end

      ::GitlabSubscriptions::SubscriptionHistory
        .select('namespace_id, MAX(end_date) AS expired_date')
        .where(trial: false, hosted_plan_id: paid_plan_ids)
        .where(end_date: ...@today)
        .where.not(namespace_id: result.keys)
        .group(:namespace_id)
        .each do |history|
          result[history.namespace_id] = history.expired_date
        end
      # rubocop: enable CodeReuse/ActiveRecord

      result
    end

    def merged_expired_namespace_hash
      [
        expired_plan_namespace_hash,
        expired_storage_namespace_hash,
        expired_credit_namespace_hash
      ].reduce({}) do |merged_hash, expired_hash|
        merged_hash.merge(expired_hash) do |_namespace_id, date1, date2|
          date1.before?(date2) ? date2 : date1
        end
      end
    end

    # rubocop: disable CodeReuse/ActiveRecord -- query gitlab credit namespaces
    def available_credit_namespace_list
      ::GitlabSubscriptions::AddOnPurchase.for_gitlab_credits.non_trial.active.pluck(:namespace_id)
    end

    def expired_credit_namespace_hash
      ::GitlabSubscriptions::AddOnPurchase.for_gitlab_credits.non_trial.where(expires_on: ...@today)
        .each_with_object({}) do |purchase, memo|
          memo[purchase.namespace_id] = purchase.expires_on
        end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def paid_plan_ids
      Plan.by_name(PAID_PLANS.split(',')).map(&:id)
    end

    strong_memoize_attr :paid_plan_ids

    def default_free_trial_start_date
      Date.parse(ENV.fetch('JH_FREE_TRIAL_START_DATE', '2024-01-02'))
    end

    strong_memoize_attr :default_free_trial_start_date
  end
end
