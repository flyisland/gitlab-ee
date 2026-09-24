# frozen_string_literal: true

module JH
  module Gitlab
    module Auth
      module OAuth
        module Provider
          module ClassMethods
            LABELS = { "dingtalk" => "DingTalk", "wecom" => "WeCom" }.freeze

            # Mirrors the upstream precedence: an explicitly configured `label`
            # wins, then these defaults, then the titleized provider name.
            #
            # Callers pass the provider either as a Symbol (views iterate
            # `Provider.providers`) or as a String, so normalize first.
            def label_for(name)
              name = name.to_s
              config = config_for(name)

              (config && config['label']) || LABELS[name] || super
            end
          end
        end
      end
    end
  end
end
