# frozen_string_literal: true

module Integrations
  module Notificationable
    extend ActiveSupport::Concern

    JH_SUPPORTED_EVENTS = %w[
      push issue confidential_issue merge_request note confidential_note
      tag_push pipeline wiki_page deployment vulnerability alert
    ].freeze

    included do
      prop_accessor(*JH_SUPPORTED_EVENTS.map { |event| ::Integrations::Base::ChatNotification::EVENT_CHANNEL[event] })
      prop_accessor :language_for_notify
    end

    class_methods do
      def default_languages
        [
          %w[简体中文 zh_CN].freeze,
          %w[English en].freeze
        ].freeze
      end
    end

    def supported_events
      JH_SUPPORTED_EVENTS
    end

    def webhook_placeholder
      '' # wecom does not need webhook field
    end

    def testable?
      false
    end

    def configurable_channels?
      true
    end

    private

    def custom_data(data)
      super.merge(markdown: true)
    end

    # rubocop: disable GitlabSecurity/PublicSend
    def event_active?(event)
      public_send(::IntegrationsHelper.integration_event_field_name(event))
    end
    # rubocop: enable GitlabSecurity/PublicSend

    # rubocop:disable Metrics/CyclomaticComplexity
    def get_message(object_kind, data)
      Gitlab::I18n.with_locale(language_for_notify || "zh_CN") do
        case object_kind
        when 'alert'
          Gitlab::ChatopsMessage::AlertMessage.new(data)
        when 'vulnerability'
          Gitlab::ChatopsMessage::VulnerabilityMessage.new(data)
        when "push", "tag_push"
          Gitlab::ChatopsMessage::PushMessage.new(data) if notify_for_ref?(data)
        when "issue"
          Gitlab::ChatopsMessage::IssueMessage.new(data) unless update?(data)
        when "merge_request"
          Gitlab::ChatopsMessage::MergeMessage.new(data) unless update?(data)
        when "note"
          Gitlab::ChatopsMessage::NoteMessage.new(data)
        when "pipeline"
          Gitlab::ChatopsMessage::PipelineMessage.new(data) if should_pipeline_be_notified?(data)
        when "wiki_page"
          Gitlab::ChatopsMessage::WikiPageMessage.new(data)
        when "deployment"
          Gitlab::ChatopsMessage::DeploymentMessage.new(data) if notify_for_ref?(data)
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def publish_notification(message, opts)
      if opts[:channel].blank? || !opts[:channel].is_a?(Array)
        log_error("Incorrect channel :#{opts[:channel]}, #{message.class} in #{id}")
        return
      end

      Gitlab::I18n.with_locale(language_for_notify || 'zh_CN') do
        yield if block_given?
      end
    end
  end
end
