# frozen_string_literal: true

module FreeTrial
  class BlockFreeTrialUserService
    FREE_TRIAL_ENDS = 'blocked_by_free_trial_ends'

    MAILER_CATEGORY = :block_free_trial
    ERROR_TOTAL_METRIC = :free_trial_mailer_error_total
    EXECUTION_TOTAL_METRIC = :free_trial_mailer_execution_total

    def initialize(user_id)
      @user_id = user_id
    end

    def execute
      user = User.find_by_id(@user_id)
      return if user.blank? || user.blocked?

      if user.block
        current = Time.current.to_s
        UserCustomAttribute.upsert_custom_attributes([{ user_id: user.id, key: FREE_TRIAL_ENDS, value: current }])
        send_block_email(user)
      else
        messages = user.errors.full_messages
        Sidekiq.logger.error(class: self.class, message: messages.uniq.join('. '))
      end
    end

    def send_block_email(user)
      ::Notify.free_trial_ends_notification(user.id).deliver_now
    rescue Net::SMTPUnknownError => err
      error_label = { version: Gitlab.version_info.to_s, mailer_category: MAILER_CATEGORY,
                      status_code: err.response.status, error_message: err.response.string[0..20] }
      ::Gitlab::Metrics.counter(ERROR_TOTAL_METRIC, ERROR_TOTAL_METRIC, error_label).increment
      raise err
    rescue StandardError => err
      error_label = { version: Gitlab.version_info.to_s, mailer_category: MAILER_CATEGORY,
                      error_message: err.message[0..30] }
      ::Gitlab::Metrics.counter(ERROR_TOTAL_METRIC, ERROR_TOTAL_METRIC, error_label).increment
      raise err
    ensure
      ::Gitlab::Metrics.counter(EXECUTION_TOTAL_METRIC, EXECUTION_TOTAL_METRIC,
        { version: Gitlab.version_info.to_s, mailer_category: MAILER_CATEGORY }).increment
    end
  end
end
