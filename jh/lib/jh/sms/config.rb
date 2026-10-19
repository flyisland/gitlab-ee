# frozen_string_literal: true

module JH
  module Sms
    class Config < Hashie::Dash
      property :area_codes
      property :secret_id
      property :secret_key
      property :region
      property :app_id
      property :template_id_zh
      property :template_id_en
      property :sign_name_zh
      property :sign_name_en
    end
  end
end
