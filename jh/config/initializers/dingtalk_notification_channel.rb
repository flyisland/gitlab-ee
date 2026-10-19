# frozen_string_literal: true

# The registry is reloadable, so register again after every code reload.
Rails.application.config.to_prepare do
  Gitlab::Notifications::Channels.register(:dingtalk) { Gitlab::Dingtalk::NotificationChannel }
end
