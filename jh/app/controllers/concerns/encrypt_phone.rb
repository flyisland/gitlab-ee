# frozen_string_literal: true

module EncryptPhone
  include UserResourceKey

  private

  # e.g: "+8615612341234" -> "OVj5kV60tFF70495B1kq..."
  def encrypt_phone
    params[:phone] = Gitlab::CryptoHelper.aes256_gcm_encrypt(params[:phone])
  end

  def encrypt_phone_with_user
    user_resource[:phone] = Gitlab::CryptoHelper.aes256_gcm_encrypt(user_resource[:phone])
  end
end
