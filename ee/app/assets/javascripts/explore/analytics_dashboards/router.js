import { __ } from '~/locale';
import ceRouter from '~/explore/analytics_dashboards/router';
import { EDIT_DASHBOARD_PATH } from './constants';
import DashboardEdit from './pages/edit.vue';

export default (basePath, breadcrumbState) => {
  const router = ceRouter(basePath, breadcrumbState);

  // Add the edit route for EE
  router.addRoute({
    name: 'dashboard-edit',
    path: `/:slug/${EDIT_DASHBOARD_PATH}`,
    component: DashboardEdit,
    meta: {
      getName: () => __('Edit'),
      getParents: () => [
        {
          text: breadcrumbState.name,
          to: `/${breadcrumbState.slug}`,
        },
      ],
    },
  });

  return router;
};
