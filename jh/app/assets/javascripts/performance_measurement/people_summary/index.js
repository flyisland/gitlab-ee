import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import PeopleSummaryApp from './app.vue';

export const initPeopleSummary = () => {
  const el = document.querySelector('.js-performance-people-summary');

  if (!el) return false;

  Vue.use(VueApollo);
  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient({}),
  });

  return new Vue({
    el,
    apolloProvider,
    render(h) {
      return h(PeopleSummaryApp);
    },
  });
};
