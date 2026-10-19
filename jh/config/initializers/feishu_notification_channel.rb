# frozen_string_literal: true

# The registry is reloadable, so register again after every code reload.
Rails.application.config.to_prepare do
  Gitlab::Notifications::Channels.register(:feishu) { Gitlab::Feishu::NotificationChannel }
end
