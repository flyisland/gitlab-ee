# frozen_string_literal: true

# rubocop:disable Rails/ApplicationController
class SmsController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true

  include Recaptcha::Adapters::ControllerMethods
  include VisitorIdCode
  include MergeAreaCodeAndPhone
  include EncryptPhone

  before_action :require_phone
  before_action :check_captcha
  before_action :merge_area_code_and_phone

  use_renderers :json

  def verification_code
    unencrypted_phone = params[:phone]
    encrypt_phone

    phone_verification = Phone::VerificationCode.find_or_initialize_by(phone: params[:phone])
    if phone_verification.created_at && phone_verification.created_at > 1.minute.ago
      render json: { status: 'SENDING_LIMIT_RATE_ERROR' }
    elsif (code = JH::Sms::TencentSms.send_code(unencrypted_phone)) # rubocop:disable Lint/AssignmentInCondition
      phone_verification.assign_attributes(
        phone: params[:phone],
        visitor_id_code: visitor_id_code,
        code: code,
        created_at: Time.zone.now)
      phone_verification.save!

      render json: { status: 'OK' }
    else
      render json: { status: 'SENDING_CODE_ERROR' }
    end

  rescue StandardError => e
    render json: { status: 'ERROR', message: e }
  end

  private

  def require_phone
    render json: { status: 'PARAMS_BLANK_ERROR' } unless params[:phone]
  end

  def check_captcha
    render json: { status: 'RECAPTCHA_ERROR' } unless captcha_confirmed?
  end

  def captcha_confirmed?
    if ::JH::Captcha::Geetest.enabled?
      Recaptcha.geetest_captcha_verify_via_api_call(params[:geetest_captcha_response], {})
    elsif ::JH::Captcha::TencentCloud.enabled?
      ::JH::Captcha::TencentCloud.verify!(params[:ticket], request.ip, params[:rand_str])
    else
      Gitlab::Recaptcha.load_configurations!
      verify_recaptcha
    end
  end
end
# rubocop:enable Rails/ApplicationController
