# frozen_string_literal: true

module Integrations
  class Wecom < Integration
    include Base::ChatNotification
    include Notificationable

    validate :check_channel_name_format, if: :activated?

    WECOM_ROBOT_WEBHOOK_KEY_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

    # assign this fixed url to pass webhook validation in Base::ChatNotification
    WECOM_WEBHOOK_URL = "https://developer.work.weixin.qq.com/document/path/91770"

    WECOM_DOC_URL = 'https://docs.gitlab.cn/jh/user/project/integrations/wecom_integration_and_notification.html'

    field :language_for_notify,
      type: :select,
      title: -> { _('Language') },
      choices: default_languages,
      required: true

    field :notify_only_broken_pipelines,
      type: :checkbox,
      title: -> { s_('JH|INTEGRATION|Notify only broken pipelines') },
      help: -> { s_('JH|INTEGRATION|Do not send notifications for successful pipelines.') }

    field :notify_only_when_pipeline_status_changes,
      type: :checkbox,
      section: Integrations::Base::Integration::SECTION_TYPE_CONFIGURATION,
      description: -> { _('Send notifications only when the pipeline status changes.') }

    field :branches_to_be_notified,
      type: :select,
      title: -> { s_('Integrations|Branches for which notifications are to be sent') },
      choices: branch_choices

    field :labels_to_be_notified,
      title: -> { s_('JH|INTEGRATION|Labels to be notified') },
      placeholder: '~backend,~frontend',
      help: -> do
        s_('JH|INTEGRATION|Send notifications for issue, merge request, and comment ' \
          'events with the listed labels only. Leave blank to receive notifications for all events.')
      end

    field :labels_to_be_notified_behavior,
      type: :select,
      title: -> { s_('JH|INTEGRATION|Labels to be notified behavior') },
      choices: -> do
        [
          [s_('JH|INTEGRATION|Match any of the labels'), MATCH_ANY_LABEL],
          [s_('JH|INTEGRATION|Match all of the labels'), MATCH_ALL_LABELS]
        ]
      end

    def self.to_param
      'wecom'
    end

    def self.requires_webhook?
      false
    end

    def self.help
      key = "JH|INTEGRATION|Sends notifications about project events to Wecom group chat. " \
        "%{link_start}How do I set up this service?%{link_end}"
      link_start = ::Kernel.format('<a href="%{url}" target="_blank" rel="noopener noreferrer">', url: WECOM_DOC_URL)
      ::Kernel.format(s_(key), link_start: link_start, link_end: '</a>')
    end

    def self.title
      s_('JH|INTEGRATION|Wecom notifications')
    end

    def self.description
      s_('JH|INTEGRATION|Send notifications about project events to Wecom.')
    end

    def initialize_properties
      super

      self.language_for_notify = 'zh_CN' if language_for_notify.nil?
      self.webhook = WECOM_WEBHOOK_URL
    end

    def default_channel_placeholder
      s_('JH|INTEGRATION|Wecom group robot webhook key separated by comma')
    end

    override :requires_webhook?

    private

    def check_channel_name_format
      supported_events.each do |event|
        next unless event_active?(event)

        channel_names = event_channel_value(event)&.split(',')&.map(&:strip)

        unless channel_names&.all? { |m| WECOM_ROBOT_WEBHOOK_KEY_REGEX.match?(m) }
          errors.add(:base, s_('JH|INTEGRATION|Please input valid Wecom group robot webhook key'))
          next
        end
      end
    end

    def notify(message, opts)
      publish_notification(message, opts) do
        client = ::Gitlab::Wecom::Client.new
        formatter = ::Gitlab::Wecom::Formatter.new(message: message)

        # WECOM API DOES NOT support send message to groups in batch
        opts[:channel].each do |channel|
          response = client.send_message(formatter.respond_notification, channel)

          next unless response && !response.success?

          log_error('Wecom Notify HTTP error response',
            request_host: response.request.uri.host,
            response_code: response.code,
            response_body: response.body)
        end
      end
    end
  end
end
