# frozen_string_literal: true

module JH
  module Gitlab
    module ExpiringSubscriptionMessage
      extend ::Gitlab::Utils::Override

      private

      override :namespace_block_changes_message
      def namespace_block_changes_message
        if auto_renew
          support_link = '<a href="https://support.gitlab.cn">support.gitlab.cn</a>'.html_safe

          _('We tried to automatically renew your subscription for %{strong}%{namespace_name}%{strong_close} on %{expires_on} but something went wrong so your subscription was downgraded to the free plan. Don\'t worry, your data is safe. We suggest you check your payment method and get in touch with our support team (%{support_link}). They\'ll gladly help with your subscription renewal.') % { strong: strong, strong_close: strong_close, namespace_name: namespace.name, support_link: support_link, expires_on: subscribable.expires_at.to_date.iso8601 }
        else
          pricing_url = 'https://about.gitlab.cn/pricing/'
          pricing_link_start = format('<a href="%{url}">'.html_safe, url: pricing_url)
          support_email = '<a href="mailto:support@gitlab.cn">support@gitlab.cn</a>'.html_safe

          s_('Subscription|Your subscription for %{strong}%{namespace_name}%{strong_close} has expired and you are now on %{pricing_link_start}the GitLab Free tier%{pricing_link_end}. Don\'t worry, your data is safe. Get in touch with our support team (%{support_email}). They\'ll gladly help with your subscription renewal.') % { strong: strong, strong_close: strong_close, support_email: support_email, pricing_link_start: pricing_link_start, pricing_link_end: '</a>'.html_safe, namespace_name: namespace.name }
        end
      end
    end
  end
end
