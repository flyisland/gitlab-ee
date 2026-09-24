# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class DeploymentMessage < ::Integrations::ChatMessage::DeploymentMessage
      include MessageHelper

      def attachments
        title = ::Kernel.format(s_("JH|CHAT_MESSAGE|%{project_link} with job %{deployment_link} by %{user_link}"),
          project_link: project_link,
          deployment_link: deployment_link,
          user_link: user_link)
        <<-MSG.strip_heredoc
          #{title}
          #{commit_link}: #{strip_markup(commit_title)}
        MSG
      end

      def template_theme
        case status
        when 'created', 'success'
          MESSAGE_THEMES[:success]
        when 'running'
          MESSAGE_THEMES[:running]
        when 'failed'
          MESSAGE_THEMES[:error]
        when 'canceled'
          MESSAGE_THEMES[:cancel]
        when 'skipped', 'blocked'
          MESSAGE_THEMES[:warning]
        end
      end

      private

      def message
        if running?
          ::Kernel.format(s_("JH|CHAT_MESSAGE|Starting deploy to %{environment}"),
            environment: strip_markup(environment))
        else
          ::Kernel.format(s_("JH|CHAT_MESSAGE|Deploy to %{environment} %{status}"),
            environment: strip_markup(environment),
            status: humanized_status)
        end
      end

      def humanized_status
        case status
        when 'created'
          s_('Deployment|Created')
        when 'running'
          s_('Deployment|Running')
        when 'success'
          _('Succeeded')
        when 'failed'
          s_('Deployment|Failed')
        when 'canceled'
          s_('Deployment|Cancelled')
        when 'skipped'
          s_('Deployment|Skipped')
        when 'blocked'
          s_('Deployment|Waiting')
        else
          _("Unknown")
        end
      end
    end
  end
end
