/* eslint-disable @jihu-fe/prefer-ee-modules */
import '~/pages/registrations/new';
import { trackNewRegistrations } from 'ee/google_tag_manager';
import initPasswordValidator from 'jh/password/password_validator';
import { setupArkoseLabsForSignup } from 'ee/arkose_labs';
import FormErrorTracker from '~/pages/shared/form_error_tracker';
import EmailValidator from 'jh/pages/sessions/new/email_validator';
import { initRegistration } from 'jh/registration';

trackNewRegistrations();

// Warning: initPasswordValidator has to run after initPasswordInput
// (which is executed when '~/pages/registrations/new' is imported)
initPasswordValidator();

setupArkoseLabsForSignup();

// Warning: run after all input initializations
// eslint-disable-next-line no-new
new FormErrorTracker();

const { dot_com: dotCom, phone_registration: phoneRegistration } = window.gon;

if (dotCom) {
  if (phoneRegistration) {
    initRegistration();
  } else {
    new EmailValidator(); // eslint-disable-line no-new
  }
}
