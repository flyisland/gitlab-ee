import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import BurnCharts from './components/burn_charts.vue';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

export default () => {
  // generate burndown chart (if data available)
  const container = '.burndown-chart';
  const chartEl = document.querySelector(container);

  if (chartEl) {
    const { startDate, dueDate, milestoneId, burndownEventsPath } = chartEl.dataset;
    const isLegacy = parseBoolean(chartEl.dataset.isLegacy);

    // eslint-disable-next-line no-new
    new Vue({
      el: container,
      name: 'BurnChartsRoot',
      components: {
        BurnCharts,
      },
      apolloProvider,
      render(createElement) {
        return createElement('burn-charts', {
          props: {
            showNewOldBurndownToggle: isLegacy,
            burndownEventsPath,
            startDate,
            dueDate,
            milestoneId,
          },
        });
      },
    });
  }
};
