# frozen_string_literal: true

module CheckPhoneAndCode
  include VisitorIdCode
  include MergeAreaCodeAndPhone
  include EncryptPhone

  private

  def check_verification_code
    case controller_name
    when 'phones'
      check_code_for_phones_page
    when 'profiles'
      check_code_for_profiles_page
    when 'registrations'
      check_code_for_registrations_page
    when 'users'
      check_code_for_reset_password_page
    end
  end

  def verification_message(verification, vcode)
    if !verification
      s_('JH|RealName|Verification code is nonexist.')
    elsif verification.created_at < 10.minutes.ago
      s_('JH|RealName|Verification code is outdated.')
    elsif verification.code != vcode
      s_('JH|RealName|Verification code is incorrect.')
    end
  end

  def check_code_for_reset_password_page
    check_code_for_phones_page
  end

  def check_code_for_phones_page
    merge_area_code_and_phone
    encrypt_phone
    verification = Phone::VerificationCode.for_visitor(visitor_id_code, params[:phone]).first
    verification_message(verification, params[:verification_code])
  end

  def check_code_for_registrations_page
    merge_area_code_and_phone_with_user
    encrypt_phone_with_user
    verification = Phone::VerificationCode.for_visitor(visitor_id_code, user_resource[:phone]).first
    verification_message(verification, user_resource[:verification_code])
  end

  def check_code_for_profiles_page
    merge_area_code_and_phone_with_user
    encrypt_phone_with_user
    return if user_resource[:phone] == current_user.phone

    verification = Phone::VerificationCode.for_visitor(visitor_id_code, user_resource[:phone]).first

    message = verification_message(verification, user_resource[:verification_code])

    return unless message

    respond_to do |format|
      format.html { redirect_back_or_default(default: { action: 'show' }, options: { alert: message }) }
      format.json { render json: { message: message } }
    end
  end
end
