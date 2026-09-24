import EmailValidator from 'jh/pages/sessions/new/email_validator';
import PhoneValidator from 'jh/pages/sessions/new/phone_validator';
import VerificationCodeButton from 'jh/verification_code_button';

function deactivateTab(el) {
  el.classList.remove('active');
  el.classList.remove('gl-tab-nav-item-active');
}

function activateTab(el) {
  el.classList.add('active');
  el.classList.add('gl-tab-nav-item-active');
}

function swapTab(from, to) {
  deactivateTab(from);
  activateTab(to);
}

function clickCaptcha(container) {
  container.querySelector('.tencent-captcha')?.click();
}

function swapForm(from, to) {
  from.classList.add('hidden');
  to.classList.remove('hidden');
  clickCaptcha(to);
}

export const initRegistration = () => {
  const phoneTab = document.querySelector('.register-with-phone');
  const emailTab = document.querySelector('.register-with-email');

  const phoneForm = document.querySelector('.phone-registration-form');
  const emailForm = document.querySelector('.email-registration-form');

  if (phoneTab && phoneForm) {
    phoneTab.addEventListener('click', () => {
      swapForm(emailForm, phoneForm);
      swapTab(emailTab, phoneTab);
    });

    const verificationButton = new VerificationCodeButton();
    new PhoneValidator({ verificationButton }); // eslint-disable-line no-new
  }

  if (emailTab && emailForm) {
    emailTab.addEventListener('click', () => {
      swapForm(phoneForm, emailForm);
      swapTab(phoneTab, emailTab);
    });
    new EmailValidator(); // eslint-disable-line no-new
  }
};
