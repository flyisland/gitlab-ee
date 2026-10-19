# frozen_string_literal: true

module JH
  module Gitlab
    CN_URL = 'https://jihulab.com'

    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    module ClassMethods
      def hk?
        ENV['SAAS_REGION'] == 'HK'
      end

      def promo_host
        'about.gitlab.cn'
      end

      def com_url
        ::Gitlab.hk? ? 'https://gitlab.hk' : 'https://jihulab.com'
      end

      def staging_com_url
        ::Gitlab.hk? ? 'https://staging.gitlab.hk' : 'https://staging.jihulab.com'
      end

      def subdomain_regex
        ::Gitlab.hk? ? %r{\Ahttps://[a-z0-9-]+\.gitlab\.hk\z} : %r{\Ahttps://[a-z0-9-]+\.jihulab\.com\z}
      end

      def dev_url
        'https://dev.gitlab.cn'
      end

      def commom_purchase_url
        'https://about.gitlab.cn/upgrade-plan'
      end

      def about_pricing_url
        "https://about.gitlab.cn/pricing"
      end

      def about_pricing_faq_url
        "https://about.gitlab.cn/pricing#faq"
      end

      def doc_url
        'https://docs.gitlab.cn'
      end

      def community_forum_url
        'https://forum.gitlab.cn'
      end
    end

    def self.com_except_hk?
      ::Gitlab::Saas.enabled? && ::Gitlab.hk?
    end
  end
end
