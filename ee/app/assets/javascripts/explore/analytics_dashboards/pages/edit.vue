<script>
import { GlDashboardLayout, GlButton, GlEmptyState } from '@gitlab/ui';
import { s__ } from '~/locale';
import DashboardLoader from '~/explore/analytics_dashboards/components/dashboard_loader.vue';
import AnalyticsDashboardPanel from '~/analytics/shared/components/analytics_dashboard_panel.vue';
import { wrapVisualizationInPanel } from '../utils';
import DashboardSettingsDrawer from '../components/dashboard_settings_drawer.vue';
import AddPanelDrawer from '../components/add_panel_drawer.vue';

export default {
  name: 'ExploreAnalyticsDashboardEdit',
  components: {
    GlDashboardLayout,
    GlButton,
    GlEmptyState,
    DashboardLoader,
    AnalyticsDashboardPanel,
    DashboardSettingsDrawer,
    AddPanelDrawer,
  },
  data() {
    return {
      dashboard: null,
      isSettingsDrawerOpen: false,
      isAddPanelDrawerOpen: false,
    };
  },
  computed: {
    config() {
      return this.dashboard?.config || {};
    },
    panels() {
      return this.config?.panels || [];
    },
    hasPanels() {
      return Boolean(this.panels?.length);
    },
  },
  methods: {
    onDashboardLoaded(dashboard) {
      this.dashboard = dashboard;
    },
    openSettingsDrawer() {
      this.isAddPanelDrawerOpen = false;
      this.isSettingsDrawerOpen = true;
    },
    closeSettingsDrawer() {
      this.isSettingsDrawerOpen = false;
    },
    openAddPanelDrawer() {
      this.isSettingsDrawerOpen = false;
      this.isAddPanelDrawerOpen = true;
    },
    closeAddPanelDrawer() {
      this.isAddPanelDrawerOpen = false;
    },
    addPanel(visualization) {
      // Make sure panels is defined
      if (!this.dashboard.config.panels) this.dashboard.config.panels = [];

      this.dashboard.config.panels.push(wrapVisualizationInPanel(visualization));
      this.closeAddPanelDrawer();
    },
    onLayoutChange({ panels }) {
      this.dashboard.config.panels = panels;
    },
  },
  i18n: {
    addPanel: s__('AnalyticsDashboards|Add panel'),
  },
};
</script>
<template>
  <dashboard-loader @loaded="onDashboardLoaded">
    <template #dashboard="{ dashboardId, cellHeight, minCellHeight }">
      <gl-dashboard-layout
        :config="config"
        :cell-height="cellHeight"
        :min-cell-height="minCellHeight"
        :is-static-grid="false"
        @changed="onLayoutChange"
      >
        <template #actions>
          <div class="gl-flex gl-gap-2">
            <gl-button
              icon="plus"
              data-testid="dashboard-add-panel-button"
              @click="openAddPanelDrawer"
              >{{ $options.i18n.addPanel }}</gl-button
            >
            <gl-button
              icon="settings"
              :aria-label="s__('AnalyticsDashboards|Settings')"
              data-testid="dashboard-settings-button"
              @click="openSettingsDrawer"
            />
          </div>
        </template>

        <template #panel="{ panel: { title, tooltip, visualization, queryOverrides } }">
          <analytics-dashboard-panel
            :title="title"
            :tooltip="tooltip"
            :visualization="visualization"
            :query-overrides="queryOverrides"
          />
        </template>

        <template #empty-state>
          <div
            v-if="!hasPanels"
            class="gl-border gl-w-full gl-rounded-base gl-border-dashed gl-py-13"
          >
            <gl-empty-state
              :title="s__('AnalyticsDashboards|Start building your dashboard')"
              :description="
                s__(
                  'AnalyticsDashboards|Add panels to this dashboard to visualize your analytics data.',
                )
              "
              illustration-name="empty-epic-md"
            >
              <template #actions>
                <gl-button
                  variant="confirm"
                  icon="plus"
                  data-testid="empty-state-add-panel-button"
                  @click="openAddPanelDrawer"
                  >{{ $options.i18n.addPanel }}</gl-button
                >
              </template>
            </gl-empty-state>
          </div>
        </template>
      </gl-dashboard-layout>

      <dashboard-settings-drawer
        :dashboard-id="dashboardId"
        :dashboard-config="config"
        :open="isSettingsDrawerOpen"
        @close="closeSettingsDrawer"
      />

      <add-panel-drawer
        :open="isAddPanelDrawerOpen"
        @add-panel="addPanel"
        @close="closeAddPanelDrawer"
      />
    </template>
  </dashboard-loader>
</template>
