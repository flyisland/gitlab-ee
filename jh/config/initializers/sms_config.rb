# frozen_string_literal: true

require 'tencentcloud-sdk-common'
require 'tencentcloud-sdk-sms'

Rails.application.reloader.to_prepare do
  JH::Sms.configure do |config|
    config.area_codes = Set.new(YAML.load_file(File.expand_path('../js_sms_area_codes.yml', __dir__)))
    config.secret_id = ENV['TC_ID']
    config.secret_key = ENV['TC_KEY']
    config.region = 'ap-beijing'
    config.app_id = ENV['TC_APP_ID']
    config.template_id_zh = ENV['TC_TEMPLATE_ID']
    config.template_id_en = ENV['TC_TEMPLATE_ID_ENGLISH']
    config.sign_name_zh = ENV['TC_SIGN_NAME']
    config.sign_name_en = ENV['TC_SIGN_NAME_ENGLISH']
  end
end
