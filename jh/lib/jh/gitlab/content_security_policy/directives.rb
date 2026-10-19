# frozen_string_literal: true

module JH
  module Gitlab
    module ContentSecurityPolicy
      module Directives
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :frame_src
          def frame_src
            "#{super} https://*.qq.com/ https://turing.captcha.qcloud.com https://*.geetest.com"
          end

          override :script_src
          def script_src
            "#{super} https://*.qq.com/ https://turing.captcha.qcloud.com https://*.geetest.com"
          end

          def style_src
            "#{super} http://*.geetest.com https://*.geetest.com"
          end

          override :connect_src
          def connect_src
            "#{super} https://jihuxinxi.datasink.sensorsdata.cn"
          end
        end
      end
    end
  end
end
