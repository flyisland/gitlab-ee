import 'ee/pages/trial_registrations/new';

import EmailValidator from 'jh/pages/sessions/new/email_validator';
import PhoneValidator from 'jh/pages/sessions/new/phone_validator';
import VerificationCodeButton from 'jh/verification_code_button';
import initPasswordValidator from 'ee/password/password_validator';

const verificationButton = new VerificationCodeButton();
new PhoneValidator({ verificationButton }); // eslint-disable-line no-new
initPasswordValidator();

if (window.gon.dot_com) {
  new EmailValidator(); // eslint-disable-line no-new
}
