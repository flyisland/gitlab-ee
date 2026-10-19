# frozen_string_literal: true

module FreeTrial
  class RemindFreeTrialUserWorker
    include ApplicationWorker

    feature_category :not_owned

    sidekiq_options retry: 3

    idempotent!

    deduplicate :until_executing

    data_consistency :always

    queue_namespace :free_trial_management

    loggable_arguments 0, 1, 2, 3

    ERROR_TOTAL_METRIC = :free_trial_mailer_error_total
    EXECUTION_TOTAL_METRIC = :free_trial_mailer_execution_total

    def perform(user_id, remind_type, trial_end_date)
      return unless Gitlab.com?

      user = User.find_by_id(user_id)
      return if user.blank? || UserCustomAttribute.by_user_id(user_id).by_key(remind_type).exists?

      send_reminder_email(remind_type, trial_end_date, user_id)
      UserCustomAttribute.upsert_custom_attributes([{ user_id: user.id, key: remind_type, value: Time.current.to_s }])
    end

    private

    def send_reminder_email(remind_type, trial_end_date, user_id)
      ::Notify.free_trial_remind_notification(user_id, trial_end_date).deliver_now
    rescue Net::SMTPUnknownError => err
      error_label = { version: Gitlab.version_info.to_s, mailer_category: remind_type, status_code: err.response.status,
                      error_message: err.response.string[0..20] }
      ::Gitlab::Metrics.counter(ERROR_TOTAL_METRIC, ERROR_TOTAL_METRIC, error_label).increment
      raise err
    rescue StandardError => err
      error_label = { version: Gitlab.version_info.to_s, mailer_category: remind_type,
                      error_message: err.message[0..30] }
      ::Gitlab::Metrics.counter(ERROR_TOTAL_METRIC, ERROR_TOTAL_METRIC, error_label).increment
      raise err
    ensure
      ::Gitlab::Metrics.counter(EXECUTION_TOTAL_METRIC, EXECUTION_TOTAL_METRIC,
        { version: Gitlab.version_info.to_s, mailer_category: remind_type }).increment
    end
  end
end
