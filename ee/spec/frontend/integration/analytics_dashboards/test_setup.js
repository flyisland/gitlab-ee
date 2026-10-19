import setWindowLocation from 'helpers/set_window_location_helper';
import { getText, registerBootstrappedApp, screen } from 'ee_jest/integration/helpers/test_helpers';
import initAnalyticsDashboards from '~/explore/analytics_dashboards';

const EXPLORE_ANALYTICS_DASHBOARDS_PATH = '/explore/analytics_dashboards';

export function mountAnalyticsDashboard(slug) {
  setWindowLocation(`${EXPLORE_ANALYTICS_DASHBOARDS_PATH}/${slug}`);

  const el = document.createElement('div');
  el.id = 'js-explore-analytics-dashboards';
  el.dataset.exploreAnalyticsDashboardsPath = EXPLORE_ANALYTICS_DASHBOARDS_PATH;
  el.dataset.dataSourceClickhouse = 'true';
  document.body.appendChild(el);

  return registerBootstrappedApp(initAnalyticsDashboards());
}

export const findViewTabTitles = () => screen.queryAllByRole('tab').map((tab) => getText(tab));

export const findDashboardTitle = (title) => screen.queryByRole('heading', { name: title });

export const findDashboardFilters = () => screen.queryByTestId('dashboard-filters');

export const findNotFound = () => screen.queryByTestId('dashboard-not-found');
