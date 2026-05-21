import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createApolloClient from '~/lib/graphql';
import GitlabCreditsDashboardApp from './components/app.vue';
import { usageBillingCacheConfig } from './apollo_cache_config';

/**
 * @param {HTMLElement} el
 */
export function initGitlabCreditsDashboard(el) {
  if (!el) return null;

  const { namespacePath, userUsagePath } = el.dataset;

  Vue.use(VueApollo);
  const apolloProvider = new VueApollo({
    defaultClient: createApolloClient(
      {},
      {
        cacheConfig: usageBillingCacheConfig,
      },
    ),
  });

  return new Vue({
    el,
    apolloProvider,
    name: 'GitlabCreditsDashboardRoot',
    provide: {
      namespacePath,
      userUsagePath,
    },
    render(createElement) {
      return createElement(GitlabCreditsDashboardApp);
    },
  });
}
