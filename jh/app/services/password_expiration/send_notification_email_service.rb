# frozen_string_literal: true

module PasswordExpiration
  class SendNotificationEmailService
    def initialize(batch_size = 1000)
      @password_expires_in_days = ::Gitlab::CurrentSettings.password_expires_in_days.day
      @password_expires_notice_before_days = ::Gitlab::CurrentSettings.password_expires_notice_before_days.day
      @batch_size = batch_size
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      return unless ::Gitlab::PasswordExpirationSystem.enabled?

      time_slot_started_at = Time.current + @password_expires_notice_before_days - @password_expires_in_days
      start_at = time_slot_started_at.to_date.beginning_of_day
      end_at = time_slot_started_at.to_date.end_of_day

      UserDetail.includes(:user)
                .by_password_last_changed_at(start_at, end_at)
                .find_each(batch_size: @batch_size) do |user_detail|
        email_notice_to_user user_detail
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def email_notice_to_user(user_detail)
      expiration_time = user_detail.password_last_changed_at + @password_expires_in_days
      Notify.notice_password_is_expiring_email(user_detail.user, expiration_time.to_date).deliver_later
    end
  end
end
