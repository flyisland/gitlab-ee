import { initVueApp } from '~/lib/utils/vue3compat/init_vue_app';
import App from './components/list/app.vue';
import createApolloProvider from './apollo';

export default (el) => {
  if (!el) return null;

  const { namespacePath, organizationId, emptyListSvgPath, newPolicyPath, listPath } = el.dataset;

  return initVueApp({
    el,
    apolloProvider: createApolloProvider(),
    name: 'PolicyStoreListRoot',
    provide: {
      namespacePath: namespacePath || '',
      organizationId,
      emptyListSvgPath,
      newPolicyPath: newPolicyPath || '',
      listPath: listPath || '',
    },
    component: App,
  });
};
