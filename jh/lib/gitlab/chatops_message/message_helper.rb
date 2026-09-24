# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    module MessageHelper
      extend ActiveSupport::Concern
      MESSAGE_SIZE_LIMIT = 3500

      # match [img](/uploads/xxxx/img.png)
      UPLOAD_LINK_REGEX = %r{(\[[^\]]*\]\()(/uploads/[^)]*\))}

      # match [xxx](yyy)
      MARK_LINK_REGEX = %r{\[[^\]]*\]\(([^)]*)\)}

      HTTP_REGEX = %r{http(s)?://}

      # match <img></img>, <img>, <img />
      IMG_TAG_REGEX = %r{<img[^>]+>|</img>}

      # match ![name](http(s)://example.com/image.png)
      PREVIEW_LINK_REGEX = %r{!(\[.+\]\([^)]*\))}

      MESSAGE_THEMES = {
        success: 0,
        warning: 1,
        error: 2,
        cancel: 3,
        running: 4
      }.freeze

      def ref_type_text
        ref_type == 'tag' ? _('Tag') : _('branch')
      end

      # known issue: if bad link exists in code block such as `` and ```, it will also be sanitized
      def limit_output(output)
        if output.length <= MESSAGE_SIZE_LIMIT
          sanitize_link(output)
        else
          s_('JH|CHAT_MESSAGE|Content length exceeds maximum allowed to display.')
        end
      end

      def severity_text
        case severity.to_s
        when 'critical'
          s_('severity|Critical')
        when 'high'
          s_('severity|High')
        when 'medium'
          s_('severity|Medium')
        when 'low'
          s_('severity|Low')
        when 'info'
          s_('severity|Info')
        when 'unknown'
          s_('severity|Unknown')
        end
      end

      # used in message formatter to give background color in notification
      def template_theme
        MESSAGE_THEMES[:success]
      end

      private

      def sanitize_link(output)
        output
          .then { |content| add_project_url_in_upload_link(content) }
          .then { |content| convert_preview_link_to_normal_link(content) }
          .then { |content| remove_img_tag(content) }
          .then { |content| remove_not_http_link(content) }
      end

      def remove_img_tag(content)
        content.gsub(IMG_TAG_REGEX, '')
      end

      def remove_not_http_link(content)
        content.gsub(MARK_LINK_REGEX) { |str| Regexp.last_match(1)&.match?(HTTP_REGEX) ? str : '' }
      end

      def convert_preview_link_to_normal_link(content)
        content.gsub(PREVIEW_LINK_REGEX, "\\1")
      end

      def add_project_url_in_upload_link(output)
        output.gsub(UPLOAD_LINK_REGEX, "\\1#{project_url}\\2")
      end
    end
  end
end
