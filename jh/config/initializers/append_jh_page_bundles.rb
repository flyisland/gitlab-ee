# frozen_string_literal: true

Rails.application.configure do
  config.assets.precompile << 'page_bundles/performance_analytics.css'
  config.assets.precompile << 'page_bundles/phone.css'
  config.assets.precompile << 'page_bundles/signin.css'
  config.assets.precompile << 'page_bundles/password_reset.css'
end
