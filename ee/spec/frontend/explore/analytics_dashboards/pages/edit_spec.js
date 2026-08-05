import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlEmptyState, GlDashboardLayout } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import ExploreAnalyticsDashboardEdit from 'ee/explore/analytics_dashboards/pages/edit.vue';
import DashboardSettingsDrawer from 'ee/explore/analytics_dashboards/components/dashboard_settings_drawer.vue';
import AddPanelDrawer from 'ee/explore/analytics_dashboards/components/add_panel_drawer.vue';
import DashboardLoader from '~/explore/analytics_dashboards/components/dashboard_loader.vue';
import AnalyticsDashboardPanel from '~/analytics/shared/components/analytics_dashboard_panel.vue';
import getDashboardQuery from '~/explore/analytics_dashboards/graphql/get_dashboard.query.graphql';
import { mockDashboardResponse } from '../mock_data';

Vue.use(VueApollo);

describe('ExploreAnalyticsDashboardEdit', () => {
  let wrapper;

  const mockBreadcrumbState = { name: '', slug: '', update: jest.fn() };

  const mockResolvedQuery = (queryResponse = mockDashboardResponse) =>
    createMockApollo([[getDashboardQuery, jest.fn().mockResolvedValue({ data: queryResponse })]]);

  const emptyDashboardResponse = {
    customDashboard: {
      ...mockDashboardResponse.customDashboard,
      config: {
        ...mockDashboardResponse.customDashboard.config,
        panels: [],
      },
    },
  };

  const createComponent = ({ requestHandlers, stubs = {} } = {}) => {
    wrapper = shallowMountExtended(ExploreAnalyticsDashboardEdit, {
      apolloProvider: requestHandlers || mockResolvedQuery(),
      provide: { breadcrumbState: mockBreadcrumbState },
      mocks: { $route: { params: { slug: '3' } } },
      stubs: { DashboardLoader, ...stubs },
    });
  };

  // Renders the panel scoped slot for each configured panel so the panel
  // contents can be asserted under a shallow mount.
  const GlDashboardLayoutStub = {
    name: 'GlDashboardLayoutStub',
    props: ['config'],
    template: `
      <div>
        <div v-for="(panel, index) in config.panels" :key="index">
          <slot name="panel" :panel="panel"></slot>
        </div>
      </div>
    `,
  };

  const findAddPanelButton = () => wrapper.findByTestId('dashboard-add-panel-button');
  const findEmptyStateAddPanelButton = () => wrapper.findByTestId('empty-state-add-panel-button');
  const findSettingsButton = () => wrapper.findByTestId('dashboard-settings-button');
  const findEmptyState = () => wrapper.findComponent(GlEmptyState);
  const findSettingsDrawer = () => wrapper.findComponent(DashboardSettingsDrawer);
  const findAddPanelDrawer = () => wrapper.findComponent(AddPanelDrawer);
  const findDashboardLayout = () => wrapper.findComponent(GlDashboardLayout);
  const findPanels = () => wrapper.findAllComponents(AnalyticsDashboardPanel);

  describe('actions', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('shows the Add Panel button', () => {
      expect(findAddPanelButton().exists()).toBe(true);
      expect(findAddPanelButton().text()).toContain('Add panel');
    });

    it('shows the Settings cog button', () => {
      expect(findSettingsButton().exists()).toBe(true);
      expect(findSettingsButton().attributes('icon')).toBe('settings');
    });
  });

  describe('empty state', () => {
    it('does not show when there are panels', async () => {
      createComponent();
      await waitForPromises();

      expect(findEmptyState().exists()).toBe(false);
    });

    it('shows when there are no panels', async () => {
      createComponent({
        requestHandlers: mockResolvedQuery(emptyDashboardResponse),
      });
      await waitForPromises();

      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().props()).toMatchObject({
        title: 'Start building your dashboard',
        description: 'Add panels to this dashboard to visualize your analytics data.',
        illustrationName: 'empty-epic-md',
      });
    });
  });

  describe('settings drawer', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the settings drawer', () => {
      expect(findSettingsDrawer().exists()).toBe(true);
    });

    it('passes the correct props to the settings drawer', () => {
      expect(findSettingsDrawer().props()).toMatchObject({
        open: false,
        dashboardConfig: expect.any(Object),
        dashboardId: 'gid://gitlab/Analytics::CustomDashboards::Dashboard/3',
      });
    });

    describe('when the settings button is clicked', () => {
      beforeEach(async () => {
        findSettingsButton().vm.$emit('click');
        await nextTick();
      });

      it('opens the settings drawer', () => {
        expect(findSettingsDrawer().props('open')).toBe(true);
      });

      describe('when the settings drawer emits close', () => {
        beforeEach(async () => {
          findSettingsDrawer().vm.$emit('close');
          await nextTick();
        });

        it('closes the settings drawer', () => {
          expect(findSettingsDrawer().props('open')).toBe(false);
        });
      });
    });
  });

  describe('add panel drawer', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the add panel drawer', () => {
      expect(findAddPanelDrawer().exists()).toBe(true);
    });

    it('is closed by default', () => {
      expect(findAddPanelDrawer().props('open')).toBe(false);
    });

    describe('when the add panel button is clicked', () => {
      beforeEach(async () => {
        findAddPanelButton().vm.$emit('click');
        await nextTick();
      });

      it('opens the add panel drawer', () => {
        expect(findAddPanelDrawer().props('open')).toBe(true);
      });

      describe('when the add panel drawer emits close', () => {
        beforeEach(async () => {
          findAddPanelDrawer().vm.$emit('close');
          await nextTick();
        });

        it('closes the add panel drawer', () => {
          expect(findAddPanelDrawer().props('open')).toBe(false);
        });
      });
    });

    describe('when there are no panels', () => {
      beforeEach(async () => {
        createComponent({
          requestHandlers: mockResolvedQuery(emptyDashboardResponse),
        });
        await waitForPromises();
      });

      it('opens the add panel drawer when the empty state add panel button is clicked', async () => {
        expect(findAddPanelDrawer().props('open')).toBe(false);

        findEmptyStateAddPanelButton().vm.$emit('click');
        await nextTick();

        expect(findAddPanelDrawer().props('open')).toBe(true);
      });
    });
  });

  describe('drawer mutual exclusivity', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('closes the settings drawer when the add panel drawer is opened', async () => {
      findSettingsButton().vm.$emit('click');
      await nextTick();
      expect(findSettingsDrawer().props('open')).toBe(true);

      findAddPanelButton().vm.$emit('click');
      await nextTick();

      expect(findAddPanelDrawer().props('open')).toBe(true);
      expect(findSettingsDrawer().props('open')).toBe(false);
    });

    it('closes the add panel drawer when the settings drawer is opened', async () => {
      findAddPanelButton().vm.$emit('click');
      await nextTick();
      expect(findAddPanelDrawer().props('open')).toBe(true);

      findSettingsButton().vm.$emit('click');
      await nextTick();

      expect(findSettingsDrawer().props('open')).toBe(true);
      expect(findAddPanelDrawer().props('open')).toBe(false);
    });
  });

  describe('dashboard layout', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('renders the dashboard layout with the loaded config', () => {
      const { config } = mockDashboardResponse.customDashboard;

      expect(findDashboardLayout().props('config')).toEqual({
        ...config,
        // Each panel is assigned a unique id by the dashboard loader.
        panels: config.panels.map((panel) => ({
          ...panel,
          id: expect.stringMatching(/^panel-\d+$/),
        })),
      });
    });

    it('renders an editable (non-static) grid', () => {
      expect(findDashboardLayout().props('isStaticGrid')).toBe(false);
    });

    describe('panels', () => {
      const { panels } = mockDashboardResponse.customDashboard.config;

      beforeEach(async () => {
        createComponent({ stubs: { GlDashboardLayout: GlDashboardLayoutStub } });
        await waitForPromises();
      });

      it('renders a panel for each configured panel', () => {
        expect(findPanels()).toHaveLength(panels.length);
      });

      it('passes the panel config to each rendered panel', () => {
        findPanels().wrappers.forEach((panel, index) => {
          expect(panel.props()).toMatchObject({
            title: panels[index].title,
            visualization: panels[index].visualization,
          });
        });
      });
    });

    describe('when the layout emits a change', () => {
      const reorderedPanels = [
        { id: 'panel-2', gridAttributes: { xPos: 0, yPos: 0, width: 3, height: 1 } },
        { id: 'panel-1', gridAttributes: { xPos: 3, yPos: 0, width: 3, height: 1 } },
      ];

      beforeEach(async () => {
        findDashboardLayout().vm.$emit('changed', { panels: reorderedPanels });
        await nextTick();
      });

      it('updates the layout config with the new panels', () => {
        expect(findDashboardLayout().props('config').panels).toEqual(reorderedPanels);
      });
    });
  });

  describe('adding a panel', () => {
    const visualization = { type: 'Glql', options: {} };

    beforeEach(async () => {
      createComponent();
      await waitForPromises();

      findAddPanelButton().vm.$emit('click');
      await nextTick();

      findAddPanelDrawer().vm.$emit('add-panel', visualization);
      await nextTick();
    });

    it('appends the new panel to the layout config', () => {
      const { panels } = findDashboardLayout().props('config');
      const initialCount = mockDashboardResponse.customDashboard.config.panels.length;

      expect(panels).toHaveLength(initialCount + 1);
      expect(panels[panels.length - 1]).toMatchObject({
        id: expect.stringMatching(/^panel-\d+$/),
        visualization,
        gridAttributes: { width: 6, height: 3 },
      });
    });

    it('closes the add panel drawer', () => {
      expect(findAddPanelDrawer().props('open')).toBe(false);
    });
  });
});
