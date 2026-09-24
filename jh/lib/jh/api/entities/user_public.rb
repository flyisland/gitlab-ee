# frozen_string_literal: true

module JH
  module API
    module Entities
      module UserPublic
        extend ActiveSupport::Concern

        prepended do
          format_with(:decrypt_phone) do |phone|
            ::Gitlab::CryptoHelper.aes256_gcm_decrypt(phone) if phone.present?
          rescue StandardError
            nil
          end

          with_options(format_with: :decrypt_phone) do
            expose :phone, if: ->(_, _) { ::Gitlab.com? && ::Gitlab.jh? }
          end
        end
      end
    end
  end
end
