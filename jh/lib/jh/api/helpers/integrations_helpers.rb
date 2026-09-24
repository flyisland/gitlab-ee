# frozen_string_literal: true

module JH
  module API
    module Helpers
      module IntegrationsHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :integrations
          def integrations
            super.merge(
              'feishu-bot' => [],
              'dingtalk' => [
                {
                  required: true,
                  name: :corpid,
                  type: String,
                  desc: 'DingTalk corp id'
                }
              ],
              'ones' => ::Integrations::OnesFields.api_arguments,
              'shimo' => [
                {
                  required: true,
                  name: :external_wiki_url,
                  type: String,
                  desc: 'Shimo workspace URL'
                }
              ],
              'ligaai' => ::Integrations::LigaaiFields.api_arguments,
              'feishu' => ::Integrations::Feishu.api_arguments,
              'wecom' => ::Integrations::Wecom.api_arguments
            )
          end

          override :integration_classes
          def integration_classes
            [
              ::Integrations::FeishuBot,
              ::Integrations::Dingtalk,
              ::Integrations::Ones,
              ::Integrations::Shimo,
              ::Integrations::Ligaai,
              ::Integrations::Feishu,
              ::Integrations::Wecom,
              *super
            ]
          end
        end
      end
    end
  end
end
