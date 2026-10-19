# frozen_string_literal: true

module Gitlab
  module Wecom
    # Builds the WeCom template card for a notification.
    #
    # Everything on the card comes from the notification email that was built
    # for the same person: its subject, its canonical link, and the project it
    # names. That keeps the card free of per-event knowledge, and keeps it from
    # saying anything the recipient's own email would not have said.
    #
    # The card is a pointer, not a copy. Reading the thing it points at still
    # goes through GitLab's own access checks.
    class NotificationCard
      CARD_TYPE = 'text_notice'
      TITLE_LIMIT = 100

      # Mail threading convention, not a translated string.
      REPLY_PREFIX = 'Re: '

      # The quote block carries no link of its own; tapping the card already
      # opens what the notification is about.
      QUOTE_AREA_PLAIN = 0

      # Shipped with every GitLab deployment, so this needs no configuration.
      ICON_PATH = '/apple-touch-icon.png'

      # WeCom opens the url in a browser when the card is tapped.
      CARD_ACTION_URL = 1

      def initialize(title:, url: nil, project: nil, reason: nil, excerpt: nil)
        @title = title
        @url = url
        @project = project
        @reason = reason
        @excerpt = excerpt
      end

      def to_h
        {
          card_type: CARD_TYPE,
          source: { icon_url: icon_url, desc: s_('JH|WeCom|JiHu GitLab') },
          main_title: { title: title },
          quote_area: quote_area,
          horizontal_content_list: content_list,
          card_action: { type: CARD_ACTION_URL, url: url.presence || instance_url }
        }.compact
      end

      private

      attr_reader :url, :project, :reason, :excerpt

      # Omitted entirely rather than left empty, so a card with nothing to quote
      # shows no blank block.
      def quote_area
        return if excerpt.blank?

        { type: QUOTE_AREA_PLAIN, quote_text: excerpt }
      end

      # The email subject threads a conversation, so it repeats the project and
      # carries a Re: prefix. Both are noise on a card: the project has a row of
      # its own, and there is no thread to follow.
      def title
        text = @title.to_s.strip.delete_prefix(REPLY_PREFIX)
        text = text.delete_prefix("#{project} | ") if project.present?

        text.truncate(TITLE_LIMIT)
      end

      # Every notification about an issue or a merge request threads under the
      # same subject, so the subject alone cannot say whether someone was
      # assigned, mentioned or merely subscribed. The reason can.
      def content_list
        rows = [
          { keyname: s_('JH|WeCom|Project'), value: project },
          { keyname: s_('JH|WeCom|Reason'), value: reason_label }
        ].select { |row| row[:value].present? }

        rows.presence
      end

      # Reasons, not events: a notification added upstream needs nothing here.
      # An unrecognised reason drops the row rather than showing its slug.
      def reason_label
        case reason
        when ::NotificationReason::ASSIGNED then s_('JH|WeCom|Assigned to you')
        when ::NotificationReason::REVIEW_REQUESTED then s_('JH|WeCom|Review requested')
        when ::NotificationReason::MENTIONED then s_('JH|WeCom|You were mentioned')
        when ::NotificationReason::SUBSCRIBED then s_('JH|WeCom|Subscribed')
        end
      end

      # Fetched by the recipient's WeCom client, not by WeCom's servers. It
      # points at the instance's own asset so that no phone is asked to reach an
      # unrelated host; where the instance is unreachable the card simply
      # renders without an icon.
      def icon_url
        ::Gitlab::Utils.append_path(instance_url, ICON_PATH)
      end

      # WeCom rejects a text_notice card without a card_action url.
      def instance_url
        ::Gitlab.config.gitlab.url
      end
    end
  end
end
