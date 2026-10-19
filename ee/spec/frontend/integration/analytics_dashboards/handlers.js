import { join } from 'node:path';
import { HttpResponse } from 'msw';
import { loadFixturesMap } from 'ee_jest/integration/core/fixture_utils';
import { getActiveVariant } from 'ee_jest/integration/core/fixture_variant_schema';
import './fixture_variants/get_system_dashboard';

const FIXTURES_PATH = join(
  'tmp/tests/frontend/fixtures-ee/graphql/explore/analytics_dashboards/integration/',
);
const fixtures = loadFixturesMap(FIXTURES_PATH);

export const systemDashboardResponse = fixtures.getSystemDashboard;

const OPERATION_HANDLERS = {
  getSystemDashboard: () => getActiveVariant('getSystemDashboard') ?? systemDashboardResponse,
  getAnalyticsDashboardFrecentGroups: () => fixtures.getAnalyticsDashboardFrecentGroups,
  getAnalyticsDashboardTopLevelGroups: () => fixtures.getAnalyticsDashboardTopLevelGroups,
};

export function handleAnalyticsDashboardOperation({ operationName }) {
  const handler = OPERATION_HANDLERS[operationName];

  if (!handler) {
    return null;
  }

  return HttpResponse.json(handler());
}

export const analyticsDashboardRestEndpoints = [];
