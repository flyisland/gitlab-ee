import Vue from 'vue';
import { parseBoolean } from '@gitlab/frontend-utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import PhoneVerificationApp from './app.vue';

export const initPhoneVerification = () => {
  const mountEl = document.querySelector('#js-phone-verification-show');
  const data = mountEl.dataset;
  const paths = convertObjectPropsToCamelCase(JSON.parse(data.paths), { deep: true });

  new Vue({
    el: mountEl,
    provide: {
      paths,
      oauthUser: parseBoolean(data.oauthUser),
      termsPath: data.termsPath || '',
    },
    render(h) {
      return h(PhoneVerificationApp);
    },
  });
};
