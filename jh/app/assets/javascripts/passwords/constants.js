import { s__, __ } from '~/locale';

export const i18n = {
  BY_EMAIL: s__('JH|ResetPassword|Via Email'),
  BY_PHONE: s__('JH|ResetPassword|Via Phone'),
  RESET_PASSWORD: __('Reset password'),

  EMAIL: __('Email:'),
  REQUIRE_EMAIL_ADDRESS: s__('JH|Requires your primary JiHu GitLab email address.'),

  PHONE_INVALID: s__('JH|RealName|Please provide a valid phone number.'),
  SENDING_CODE: s__('JH|ResetPassword|Sending SMS Code...'),
  SEND_CODE: s__('JH|RealName|Get code'),
  SEND_CODE_ERROR: s__('JH|RealName|An error occurred while sending verification code'),
  USER_NOT_EXIST: s__('JH|ResetPassword|There is no user matches this phone'),
  SENDING_LIMIT_RATE_ERROR: s__(
    'JH|RealName|You can not send more verification code within one minute',
  ),
  PHONE_NUMBER: s__('JH|ResetPassword|Phone number'),
  ENTER_PHONE_NUMBER: s__('JH|ResetPassword|Please enter your JiHu GitLab phone number.'),
  REQUIRE_PHONE_NUMBER: s__('JH|ResetPassword|Requires your JiHu GitLab phone number.'),

  BACK: __('Back'),
  SMS_CODE: s__('JH|ResetPassword|SMS Code:'),
  CHECK_CODE_ERROR: s__('JH|RealName|Something happened when checking code'),
  CODE_FORM_DESCRIPTION: s__(
    'JH|ResetPassword|Please enter the verification code, valid for 10 minutes.',
  ),
};

export const phoneInvalidError = new Error(i18n.PHONE_INVALID);

export const noUserMatchPhoneError = new Error(i18n.USER_NOT_EXIST);
