import Vue from 'vue';

import ResetPasswordForm from 'jh/passwords/reset_password_form.vue';

export const initResetPassword = () => {
  const el = document.getElementById('js-reset-password');

  if (!el) return false;

  const { emailAction, phoneAction } = el.dataset;

  const provide = {
    emailFormAction: emailAction,
    phoneFormAction: phoneAction,
  };

  return new Vue({
    el,
    provide,
    render(createElement) {
      return createElement(ResetPasswordForm);
    },
  });
};
