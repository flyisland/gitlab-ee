import Vue from 'vue';

import ScimToken from './components/scim_token.vue';

export function initScimTokenApp() {
  const el = document.getElementById('js-scim-token-app');

  if (!el) return null;

  const { endpointUrl, generateTokenPath } = el.dataset;

  return new Vue({
    el,
    name: 'ScimTokenRoot',
    provide: {
      initialEndpointUrl: endpointUrl,
      generateTokenPath,
    },
    render(createElement) {
      return createElement(ScimToken);
    },
  });
}
