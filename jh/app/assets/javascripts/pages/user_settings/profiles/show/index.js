import 'ee/pages/user_settings/profiles/show';
import $ from 'jquery';
import PhoneValidator from 'jh/pages/sessions/new/phone_validator';
import { phoneNumberRegex } from 'jh/pages/sessions/new/constants';
import VerificationCodeButton from 'jh/verification_code_button';

const phoneInput = $(`.js-validate-phone`);

if (phoneInput.length > 0) {
  let currentAreaCode = '+86';
  const areaCodeRegexr = new RegExp(
    `\\+(${Object.keys(phoneNumberRegex)
      .map((code) => code.slice(1))
      .join('|')})`,
  );
  const currentPhoneNumber = phoneInput.val().replace(areaCodeRegexr, (match) => {
    if (match) {
      $('select.js-select-areacode').val(match);
      currentAreaCode = match;
    }
    return '';
  });
  const verificationField = $('.verification-code.form-group');
  const phoneField = $('.phone.form-group');

  const verificationButton = new VerificationCodeButton();
  new PhoneValidator({ verificationButton, currentPhoneNumber, currentAreaCode }); // eslint-disable-line no-new
  phoneInput.val(currentPhoneNumber);

  phoneInput.on('input', () => {
    const phone = phoneInput.val();
    if (phone && phone !== currentPhoneNumber) {
      verificationField.insertAfter(phoneField);
    } else {
      verificationField.remove();
    }
  });
  phoneInput.trigger('input');
}
