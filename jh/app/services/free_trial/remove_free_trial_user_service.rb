# frozen_string_literal: true

module FreeTrial
  class RemoveFreeTrialUserService
    include Gitlab::Utils::StrongMemoize

    JH_FREE_TRIAL_DATA_KEEP_DURATION = ENV.fetch('JH_FREE_TRIAL_DATA_KEEP_DURATION', 3).to_i
    DELETE_OPTIONS = { hard_delete: true }.freeze

    def initialize(dry_run: false, batch_size: 1000)
      @dry_run = dry_run
      @batch_size = batch_size
      @current = Time.current
      @remove_user_since = (@current - JH_FREE_TRIAL_DATA_KEEP_DURATION.years).to_s
      Sidekiq.logger.info(class: self.class.name, current: @current, remove_user_since: @remove_user_since,
        dry_run: @dry_run)
    end

    def execute
      admin_id = User.admins.first&.id
      # rubocop: disable CodeReuse/ActiveRecord -- need join user customer attributes
      User.human.not_admins.blocked
          .joins(:custom_attributes)
          .where('user_custom_attributes.key': BlockFreeTrialUserService::FREE_TRIAL_ENDS)
          .where('user_custom_attributes.value::timestamp < ?', @remove_user_since)
          .each_batch(of: @batch_size) do |users|
        user_ids = users.pluck(:id)
        Sidekiq.logger.info(class: self.class.name, dry_run: @dry_run, remove_user_since: @remove_user_since,
          user_ids: user_ids)
        next if @dry_run

        user_ids.each { |user_id| ::DeleteUserWorker.perform_async(admin_id, user_id, DELETE_OPTIONS) }
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
