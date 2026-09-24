# frozen_string_literal: true

module Integrations
  class Feishu < Integration
    include Base::ChatNotification
    include Notificationable

    validate :check_settings, if: :activated?
    validate :check_channel_exists_in_feishu, if: :activated?

    # we need save both channel name and corresponding feishu id
    prop_accessor :feishu_groups_name_id_hash

    # assign this fixed url to pass webhook validation in Base::ChatNotification
    FEISHU_WEBHOOK_URL = "https://open.feishu.cn/open-apis"

    FEISHU_DOC_URL = 'https://docs.gitlab.cn/jh/user/project/integrations/feishu_integration_and_notification.html'
    def self.to_param
      'feishu'
    end

    # try to remove html_safe
    def self.help
      # rubocop:disable Gitlab/NoCodeCoverageComment
      # :nocov:
      key = "JH|INTEGRATION|Sends notifications about project events to Feishu group chat. " \
        "%{link_start}How do I set up this service?%{link_end}"
      link_start = ::Kernel.format('<a href="%{url}" target="_blank" rel="noopener noreferrer">', url: FEISHU_DOC_URL)
      ::Kernel.format(s_(key), link_start: link_start, link_end: '</a>')
      # :nocov:
      # rubocop:enable Gitlab/NoCodeCoverageComment
    end

    def self.title
      s_('JH|INTEGRATION|FeiShu notifications')
    end

    def self.description
      s_('JH|INTEGRATION|Send notifications about project events to FeiShu.')
    end

    def initialize_properties
      super

      self.language_for_notify = 'zh_CN' if language_for_notify.nil?
      self.webhook = FEISHU_WEBHOOK_URL
    end

    def check_settings
      return if ::Gitlab::CurrentSettings.feishu_enabled?

      errors.add(:base, s_('JH|INTEGRATION|Please check your settings for Feishu Integration ' \
        'in JiHu GitLab, e.g. App ID and App Secret'))
    end

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

    def default_channel_placeholder
      s_('JH|INTEGRATION|Dev Group, Ops Group(Feishu group names separated by comma)')
    end

    private

    def check_channel_exists_in_feishu
      return unless ::Gitlab::CurrentSettings.feishu_enabled?

      feishu_groups = ::Gitlab::Feishu::Client.build.groups_contains_bot
      if feishu_groups.nil?
        return errors.add(:base, s_('JH|INTEGRATION|Validate FeiShu Group Error, please follow FeiShu Integration ' \
          'document verify the settings.'))
      end

      self.feishu_groups_name_id_hash = feishu_groups

      supported_events.each do |event|
        next unless event_active?(event)

        channel_names = event_channel_value(event)&.split(',')&.map(&:strip)

        if channel_names.blank?
          errors.add(:base, s_('JH|INTEGRATION|Please input valid FeiShu group name'))
          next
        end

        channel_names.each do |name|
          unless feishu_groups.key?(name)
            errors.add(:base, ::Kernel.format(s_('JH|INTEGRATION|JiHu GitLab bot is not found in FeiShu group ' \
              '%{name}, please add the bot first'), name: name))
          end
        end
      end
    end

    def notify(message, opts)
      publish_notification(message, opts) do
        client = ::Gitlab::Feishu::Client.build
        formatter = ::Gitlab::Feishu::Formatter.new(message: message)

        opts[:channel].each do |channel|
          feishu_id = feishu_groups_name_id_hash[channel]
          if feishu_id.blank?
            log_error("Incorrect feishu channel: #{channel} 's chat_id, #{message.class} in #{id}")
            next
          end

          response = client.send_message(formatter.respond_notification(feishu_id), type: :group)

          next unless response && !response.success?

          log_error('FeiShu Notify HTTP error response',
            request_host: response.request.uri.host,
            response_code: response.code,
            response_body: response.body)
        end
      end
    end
  end
end
