# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module UserDetail
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable
      validates :pronouns, :pronunciation, :job_title, :bio, :linkedin, :twitter, :location, :company,
        content_validation: true, if: :should_validate_content?

      scope :by_encrypted_phone, ->(phone) { where(phone: ::Gitlab::CryptoHelper.aes256_gcm_encrypt(phone)) }
      scope :by_password_last_changed_at, ->(start_at, end_at) do
        where(password_last_changed_at: start_at..end_at)
      end
    end
  end
end
