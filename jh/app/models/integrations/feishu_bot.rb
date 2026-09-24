# frozen_string_literal: true

module Integrations
  class FeishuBot < Integration
    include Gitlab::Routing

    validate :validate_license, if: :activated?
    validate :validate_creation_level, if: :activated?, on: :manual_change

    def self.to_param
      'feishu_bot'
    end

    def self.supported_events
      %w[]
    end

    def self.title
      s_("JH|FeishuBotIntegration|Feishu Bot")
    end

    def self.description
      s_("JH|FeishuBotIntegration|Perform common operations in Feishu Bot.")
    end

    def self.help
      key = "JH|FeishuBotIntegration|Perform common operations by entering commands in Feishu Bot. " \
        "%{link_start}Learn more%{link_end}."
      link_start = format('<a href="%{url}" target="_blank" rel="noopener noreferrer">'.html_safe,
        url: 'https://docs.gitlab.cn/jh/user/project/integrations/feishu_bot_command.html')
      format(s_(key), link_start: link_start, link_end: '</a>'.html_safe)
    end

    def testable?
      false
    end

    def chat_responder
      ::Gitlab::Chat::Responder::Feishu
    end

    private

    # manual_change context only available in project level upsert
    # so validate_license_and_feature_flag will focus on  all levels upsert
    def validate_license
      return if ::License.feature_available?(:feishu_bot_integration)

      errors.add(:base, s_('JH|FeishuBotIntegration|Feishu Bot Integration is deactivated. ' \
        'Please upgrade your JiHu GitLab to Starter Plan'))
    end

    # so far we only enable feishu integration in self-management
    # for our client, they just need create integration on instance level
    # all groups and all projects will inherit integration from instance level
    # disable modify integration on group/project level in order to avoid client
    # config two different robot info
    def validate_creation_level
      return if instance_level?

      errors.add(:base, s_('JH|FeishuBotIntegration|Cannot update Feishu Bot Integration in Group or Project level'))
    end
  end
end
