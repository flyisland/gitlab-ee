import { within } from '@testing-library/vue';
import { setQueryVariant } from 'ee_jest/integration/helpers/setup_utils';
import { lastRequestVariables } from 'ee_jest/integration/core/operation_helpers';
import { getSystemDashboard } from 'ee_jest/integration/analytics_dashboards/fixture_variants';
import { systemDashboardResponse } from 'ee_jest/integration/analytics_dashboards/handlers';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import {
  findDashboardFilters,
  findDashboardTitle,
  findNotFound,
  findViewTabTitles,
  mountAnalyticsDashboard,
} from './test_setup';

const SLUG = 'dap_impact';
const { title: DASHBOARD_TITLE, views: VIEWS } =
  systemDashboardResponse.data.customSystemDashboard.config;

describe('DAP Impact dashboard', () => {
  let captureException;

  beforeEach(() => {
    captureException = jest.spyOn(Sentry, 'captureException');
  });

  describe('when the dashboard is available to the user', () => {
    beforeEach(() => {
      mountAnalyticsDashboard(SLUG);
    });

    it('renders the dashboard and its views', async () => {
      await waitForElement(() => findDashboardTitle(DASHBOARD_TITLE));

      expect(lastRequestVariables('getSystemDashboard')).toEqual({ slug: SLUG });
      expect(findViewTabTitles()).toEqual(VIEWS.map(({ title }) => title));
      expect(findDashboardFilters()).not.toBe(null);
      expect(findNotFound()).toBe(null);
    });
  });

  describe('when the feature flag is disabled', () => {
    beforeEach(() => {
      setQueryVariant(getSystemDashboard).featureFlagDisabled();

      mountAnalyticsDashboard(SLUG);
    });

    it('shows the not found state with a link back to the dashboards list', async () => {
      const notFound = await waitForElement(findNotFound);

      expect(getText(notFound)).toContain('Dashboard not found');
      expect(
        within(notFound)
          .getByRole('link', { name: 'View available dashboards' })
          .getAttribute('href'),
      ).toBe('/explore/analytics_dashboards');
    });

    it('does not render the dashboard, its views or its filters', async () => {
      await waitForElement(findNotFound);

      expect(findDashboardTitle(DASHBOARD_TITLE)).toBe(null);
      expect(findViewTabTitles()).toEqual([]);
      expect(findDashboardFilters()).toBe(null);
      expect(captureException).not.toHaveBeenCalled();
    });
  });
});
