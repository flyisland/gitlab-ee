# frozen_string_literal: true

module TrialStatusWidgetHelper
  def account_trial_notification_data
    return {} unless current_user

    attribute = current_user.custom_attributes.by_key(::JH::User::FREE_TRIAL_LEFT_DAYS).first
    days_left = attribute.present? ? attribute.value.to_i : nil
    updated_at = attribute.present? ? attribute.updated_at.to_time.iso8601 : nil

    { days_left: days_left, updated_at: updated_at }
  end
end
