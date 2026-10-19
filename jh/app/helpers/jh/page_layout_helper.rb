# frozen_string_literal: true

module JH
  module PageLayoutHelper
    def front_monitor_enabled?
      ENV.key?('RUM_URL') && ::Gitlab.com?
    end

    def rum_config
      config_data = ::Gitlab::Json.parse(ENV['RUM_CONFIG'] || "{}")
      {
        'id' => config_data['id'] || '',
        'reportApiSpeed' => config_data['reportApiSpeed'] || false,
        'reportAssetSpeed' => config_data['reportAssetSpeed'] || false
      }
    end
  end
end
