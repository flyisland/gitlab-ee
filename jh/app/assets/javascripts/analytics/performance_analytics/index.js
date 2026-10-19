import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '@gitlab/frontend-utils';
import PerformanceAnalytics from 'jh/analytics/performance_analytics/components/index.vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
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
