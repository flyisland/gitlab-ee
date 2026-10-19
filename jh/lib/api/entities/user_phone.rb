# frozen_string_literal: true

module API
  module Entities
    class UserPhone < UserSafe
      expose :phone do |user|
        ::Gitlab::CryptoHelper.aes256_gcm_decrypt(user.phone)
      end
    end
  end
end
