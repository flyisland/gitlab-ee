import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { initSinglePageApplication } from '~/vue_shared/spa';
import { cdMockTypePolicies } from './graphql/mock_resolvers';
import { createRouter } from './router';

export const initCdRoot = () => {
  const el = document.querySelector('.js-cd-root');
  if (!el) {
    return null;
  }

  const { baseRoute } = el.dataset;
  const router = createRouter(baseRoute);

  // Create Apollo client with typePolicies for @client service mocks.
  // When the backend ships CdApplication.services, remove the cacheConfig
  // and revert to the default: apolloCacheConfig: {} in initSinglePageApplication.
  Vue.use(VueApollo);
  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient({}, { cacheConfig: { typePolicies: cdMockTypePolicies } }),
  });

  return initSinglePageApplication({
    name: 'CdRoot',
    el,
    router,
    // Skip auto Apollo creation — we provide our own above.
    apolloCacheConfig: null,
    options: { apolloProvider },
  });
};
