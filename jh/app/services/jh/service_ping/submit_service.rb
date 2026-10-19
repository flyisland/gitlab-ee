# frozen_string_literal: true

module JH
  module ServicePing
    module SubmitService
      extend ::Gitlab::Utils::Override

      JH_BASE_URL = 'https://version.gitlab.cn'
    end
  end
end
