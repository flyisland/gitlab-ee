# frozen_string_literal: true

module JH
  module SaasTestHelper
    extend ::Gitlab::Utils::Override

    override :get_next_url
    def get_next_url
      "https://next.jihulab.com"
    end
  end
end
