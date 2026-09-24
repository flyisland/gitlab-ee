import Vue from 'vue';
import VueApollo from 'vue-apollo';
import PerformanceAnalytics from 'jh/analytics/performance_analytics/components/index.vue';
import { convertObjectPropsToCamelCase, parseBoolean } from '~/lib/utils/common_utils';
import createDefaultClient from '~/lib/graphql';
import createStore from 'jh/analytics/performance_analytics/store';
import { trackingPerformanceLoaded } from 'jh/analytics/performance_analytics/utils';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  const el = document.querySelector('#js-performance-analytics-app');

  if (el) {
    const dataset = convertObjectPropsToCamelCase(el.dataset);

    const store = createStore({
      isGroup: parseBoolean(dataset.isGroup),
      projectId: dataset.projectId ? parseInt(dataset.projectId, 10) : null,
      fullPath: dataset.fullPath,
      groupId: parseInt(dataset.groupId, 10),
      branch: dataset?.defaultBranch || '',
    });

    trackingPerformanceLoaded();
    // eslint-disable-next-line no-new
    new Vue({
      el,
      components: {
        PerformanceAnalytics,
      },
      apolloProvider,
      store,
      render(createElement) {
        return createElement(PerformanceAnalytics);
      },
    });
  }
};
