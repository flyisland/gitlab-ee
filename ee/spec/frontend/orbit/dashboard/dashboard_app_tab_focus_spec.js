import Vue from 'vue';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import createMockApollo from 'helpers/mock_apollo_helper';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import DashboardApp from 'ee/orbit/dashboard/dashboard_app.vue';
import createDashboardRouter from 'ee/orbit/dashboard/router';
import dashboardGroupsQuery from 'ee/orbit/dashboard/graphql/dashboard_groups.query.graphql';
import { executeOrbitNamedQuery, fetchGraphStatus, fetchOrbitSchema } from 'ee/orbit/api/orbit_api';
import { buildOrbitGroup } from '../mock_data';

jest.mock('ee/orbit/api/orbit_api');
jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);
Vue.use(VueRouter);

// Mounts the real router and pages: the Overview-only siblings must come and go around the tabs.
describe('OrbitDashboardApp tab focus', () => {
  let wrapper;
  let router;

  const findTab = (label) =>
    wrapper.findAll('a.gl-tab-nav-item').wrappers.find((tab) => tab.text() === label).element;

  const mountAt = async (path) => {
    router = createDashboardRouter('/');
    await router.push(path);
    wrapper = mountExtended(DashboardApp, {
      router,
      apolloProvider: createMockApollo([
        [
          dashboardGroupsQuery,
          jest.fn().mockResolvedValue({
            data: { groups: { count: 1, nodes: [buildOrbitGroup({ phase: 'SYNCING' })] } },
          }),
        ],
      ]),
      propsData: { duoAccessible: true, orbitSettingsEnabled: true },
      provide: {
        trialAvailable: false,
        currentUserId: 1,
        defaultGroupMissing: true,
        preferencesPath: '/-/profile/preferences',
        gqlQueriesEnabled: true,
        canAskDuoForQueries: false,
      },
      attachTo: document.body,
    });
    await waitForPromises();
  };

  beforeEach(() => {
    fetchOrbitSchema.mockResolvedValue({ data: { nodes: [], edges: [] } });
    fetchGraphStatus.mockResolvedValue({ data: {} });
    executeOrbitNamedQuery.mockResolvedValue({ data: { result: { nodes: [], edges: [] } } });
  });

  it.each`
    from           | label
    ${'/schema'}   | ${'Overview'}
    ${'/overview'} | ${'Schema'}
  `('keeps focus on the $label tab when the user opens it from $from', async ({ from, label }) => {
    await mountAt(from);
    const tab = findTab(label);
    tab.focus();
    expect(document.activeElement).toBe(tab);

    tab.click();
    await waitForPromises();

    expect(document.activeElement).toBe(tab);
  });
});
