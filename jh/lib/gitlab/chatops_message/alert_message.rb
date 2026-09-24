# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class AlertMessage < ::Integrations::ChatMessage::AlertMessage
      include MessageHelper

      def initialize(params)
        super

        @markdown = params[:markdown] || false
      end

      def attachments
        <<~MSG.strip_heredoc
          [#{strip_markup(title)}](#{alert_url})
          #{s_('AlertManagement|Severity')}: #{severity_text}
          #{s_('AlertManagement|Events')}: #{events}
          #{s_('AlertManagement|Status')}: #{status_text}
          #{s_('AlertManagement|Start time')}: #{format_time(started_at)}
        MSG
      end

      def template_theme
        MESSAGE_THEMES[:error]
      end

      def message
        ::Kernel.format(s_("JH|CHAT_MESSAGE|Alert firing in %{project_link}"), project_link: project_link)
      end

      private

      def status_text
        case status.to_s
        when 'triggered'
          s_('AlertManagement|Triggered')
        when 'acknowledged'
          s_('AlertManagement|Acknowledged')
        when 'resolved'
          s_('AlertManagement|Resolved')
        when 'ignored'
          _('Ignored')
        end
      end

      def format_time(time)
        time = Time.zone.parse(time.to_s)
        time.strftime("%Y-%-m-%-d %T")
      end

      def project_link
        link(project_name, project_url)
      end
    end
  end
end
