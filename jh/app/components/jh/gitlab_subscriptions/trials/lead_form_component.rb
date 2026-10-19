# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module Trials
      module LeadFormComponent
        extend ::Gitlab::Utils::Override

        private

        override :form_data
        def form_data
          super.merge({
            phone_number: ::Gitlab::CryptoHelper.aes256_gcm_decrypt(user.phone),
            country: 'CN',
            state: ::Gitlab.hk? ? 'HK' : 'BJ'
          })
        end
      end
    end
  end
end
