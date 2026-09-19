import { initVueApp } from '~/lib/utils/vue3compat/init_vue_app';
import App from './components/detail/app.vue';
import createApolloProvider from './apollo';

export default (el) => {
  if (!el) return null;

  const { organizationId, policyId, listPath, editPath } = el.dataset;

  return initVueApp({
    el,
    apolloProvider: createApolloProvider(),
    name: 'PolicyStoreDetailRoot',
    provide: {
      organizationId,
      policyId,
      listPath: listPath || '',
      editPath: editPath || '',
    },
    component: App,
  });
};
