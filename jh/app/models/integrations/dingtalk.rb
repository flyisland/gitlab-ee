# frozen_string_literal: true

module Integrations
  class Dingtalk < Integration
    include Gitlab::Routing

    # use corpid instead of corp_id
    # because in db/schema_spec.rb ends with _id will be considered as foreign key reference
    data_field :corpid

    validate :check_corpid_presence, if: :activated?
    validate :check_license, if: :activated?
    validate :check_creation_level, if: :activated?, on: :manual_change

    field :corpid,
      title: -> { s_('JH|DingTalkIntegration|DingTalk Corp Id') },
      help: -> { s_('JH|DingTalkIntegration|Your corp id provided by DingTalk') },
      required: true

    def self.find_by_corpid(corpid)
      # rubocop: disable CodeReuse/ActiveRecord
      for_instance.joins(:dingtalk_tracker_data)
                  .where('dingtalk_tracker_data.corpid': corpid)
                  .first
      # rubocop: enable CodeReuse/ActiveRecord
    end

    def self.to_param
      'dingtalk'
    end

    def self.supported_events
      %w[]
    end

    def self.title
      'DingTalk'
    end

    def self.description
      s_("JH|DingTalkIntegration|Perform common operations in DingTalk.")
    end

    def self.help
      key = "JH|DingTalkIntegration|Perform common operations by entering commands in DingTalk. " \
        "%{link_start}Learn more%{link_end}."
      link_start = ::Kernel.format('<a href="%{url}" target="_blank" rel="noopener noreferrer">'.html_safe,
        url: 'https://docs.gitlab.cn/jh/user/project/integrations/dingtalk_integration.html')
      ::Kernel.format(s_(key), link_start: link_start, link_end: '</a>'.html_safe)
    end

    # manual_change context only available in project level upsert
    # so check_license will focus on  all levels upsert
    def check_license
      return if ::License.feature_available?(:dingtalk_integration)

      errors.add(:base, s_('JH|DingTalkIntegration|Dingtalk Integration is deactivated. ' \
        'Please upgrade your JiHu GitLab to Premium Plan'))
    end

    def check_corpid_presence
      return if corpid.present?

      errors.add(:base, s_('JH|DingTalkIntegration|DingTalk Corp Id cannot be blank.'))
    end

    # so far we only enable dingtalk integration in self-management
    # for our client, they just need create integration on instance level
    # all groups and all projects will inherit integration from instance level
    # disable modify integration on group/project level in order to avoid client
    # config two different robot info
    def check_creation_level
      return if instance_level?

      errors.add(:base, s_('JH|DingTalkIntegration|Cannot update DingTalk Integration in Group or Project level'))
    end

    def data_fields
      dingtalk_tracker_data || build_dingtalk_tracker_data
    end

    def testable?
      false
    end

    def chat_responder
      ::Gitlab::Chat::Responder::Dingtalk
    end
  end
end
