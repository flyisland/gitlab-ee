# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class PipelineMessage < ::Integrations::ChatMessage::PipelineMessage
      include MessageHelper

      def template_theme
        case status
        when 'success'
          detailed_status == "passed with warnings" ? MESSAGE_THEMES[:warning] : MESSAGE_THEMES[:success]
        when 'failed'
          MESSAGE_THEMES[:error]
        when 'canceled'
          MESSAGE_THEMES[:cancel]
        when 'skipped'
          MESSAGE_THEMES[:warning]
        else
          MESSAGE_THEMES[:success]
        end
      end

      private

      def message
        # reuse upstream translation
        ::Kernel.format(s_("ChatMessage|%{project_link}: Pipeline %{pipeline_link} of %{ref_type} %{ref_link} by " \
          "%{user_combined_name} %{humanized_status} in %{duration}"),
          project_link: project_link,
          pipeline_link: pipeline_link,
          ref_type: ref_type_text,
          ref_link: ref_link,
          user_combined_name: strip_markup(user_combined_name),
          humanized_status: humanized_status,
          duration: pretty_duration(duration))
      end

      def humanized_status
        case status
        when 'success'
          if detailed_status == "passed with warnings"
            s_("ChatMessage|has passed with warnings")
          else
            s_("ChatMessage|has passed")
          end
        when 'failed'
          s_("ChatMessage|has failed")
        when 'created'
          s_('CiStatusLabel|created')
        when 'waiting_for_resource'
          s_('CiStatusLabel|waiting for resource')
        when 'preparing'
          s_('CiStatusLabel|preparing')
        when 'pending'
          s_('CiStatusLabel|pending')
        when 'running'
          s_('CiStatusText|Running')
        when 'canceled'
          s_('CiStatusText|Canceled')
        when 'skipped'
          s_('CiStatusLabel|skipped')
        when 'manual'
          s_('CiStatusText|Manual')
        when 'scheduled'
          s_('JH|CHAT_MESSAGE|scheduled')
        end
      end
    end
  end
end
