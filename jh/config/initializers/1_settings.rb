# frozen_string_literal: true

Gitlab.jh do
  unless Rails.env.test?
    ENV['CLOUD_CONNECTOR_BASE_URL'] ||= 'https://cloud.jihulab.com'

    Settings.cloud_connector['base_url'] = ENV['CLOUD_CONNECTOR_BASE_URL']
  end

  Settings.omniauth['cas3'] ||= {}
  Settings.omniauth.cas3['session_duration'] ||= 8.hours
  Settings.omniauth['session_tickets'] ||= {}
  Settings.omniauth.session_tickets['cas3'] = 'ticket'
end
