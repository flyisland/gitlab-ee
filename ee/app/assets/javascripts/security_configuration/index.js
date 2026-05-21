import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '~/lib/utils/common_utils';
import createDefaultClient from '~/lib/graphql';
import SecurityConfigurationApp from './components/app.vue';

Vue.use(VueApollo);

export const initSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  const {
    groupFullPath,
    namespaceId,
    securityInventoryPath,
    canManageAttributes,
    canReadScanProfiles,
  } = el.dataset;

  return new Vue({
    el,
    name: 'SecurityConfigurationRoot',
    apolloProvider: new VueApollo({
      defaultClient: createDefaultClient(),
    }),
    provide: {
      groupFullPath,
      namespaceId,
      securityInventoryPath,
      canManageAttributes: parseBoolean(canManageAttributes),
      canReadScanProfiles: parseBoolean(canReadScanProfiles),
    },
    render(createElement) {
      return createElement(SecurityConfigurationApp);
    },
  });
};
