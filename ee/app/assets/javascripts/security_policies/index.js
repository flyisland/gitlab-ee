import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import App from './components/app.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default (el, namespaceType) => {
  if (!el) return null;

  const { namespacePath, rootNamespacePath } = el.dataset;

  return new Vue({
    apolloProvider,
    el,
    name: 'SecurityPoliciesV2AppRoot',
    provide: {
      namespacePath,
      namespaceType,
      rootNamespacePath,
    },
    render(createElement) {
      return createElement(App);
    },
  });
};
