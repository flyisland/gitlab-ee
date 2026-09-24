import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import PasswordExpirationApp from './components/app.vue';

export const initPasswordExpiration = () => {
  const el = document.querySelector('.js-password-expiration');
  if (!el) {
    return false;
  }

  const provide = {
    passwordExpirationEnabledData: parseBoolean(el.dataset.passwordExpirationEnabled),
    passwordExpiresInDaysData: parseInt(el.dataset.passwordExpiresInDays, 10),
    passwordExpiresNoticeBeforeDaysData: parseInt(el.dataset.passwordExpiresNoticeBeforeDays, 10),
  };

  return new Vue({
    el,
    provide,
    render(createElement) {
      return createElement(PasswordExpirationApp);
    },
  });
};
