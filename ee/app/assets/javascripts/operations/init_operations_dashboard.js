import Vue from 'vue';
import createStore from 'ee/vue_shared/dashboards/store';
import DashboardComponent from './components/dashboard/dashboard.vue';

export function initOperationsDashboard() {
  const el = document.getElementById('js-operations');

  if (!el) {
    return null;
  }

  const {
    listPath,
    addPath,
    emptyDashboardSvgPath,
    emptyDashboardHelpPath,
    operationsDashboardHelpPath,
  } = el.dataset;

  return new Vue({
    el,
    name: 'DashboardComponentRoot',
    store: createStore(),
    components: {
      DashboardComponent,
    },
    render(createElement) {
      return createElement(DashboardComponent, {
        props: {
          listPath,
          addPath,
          emptyDashboardSvgPath,
          emptyDashboardHelpPath,
          operationsDashboardHelpPath,
        },
      });
    },
  });
}
