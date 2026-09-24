# frozen_string_literal: true

module JH
  module ServicePing
    module SubmitService
      extend ::Gitlab::Utils::Override

      JH_BASE_URL = 'https://version.gitlab.cn'

      private

      override :base_url
      def base_url
        ENV['VERSION_DOT_HOST'] || JH_BASE_URL
      end
    end
  end
end
