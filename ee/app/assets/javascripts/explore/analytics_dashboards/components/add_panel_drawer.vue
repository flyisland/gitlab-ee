<script>
import { GlDrawer, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DRAWER_Z_INDEX } from '~/lib/utils/constants';
import { getContentWrapperHeight } from '~/lib/utils/dom_utils';
import DataExplorer from 'ee/vue_shared/components/data_explorer/data_explorer.vue';
import { wrapGlqlInVisualization } from '../utils';

export default {
  name: 'AddPanelDrawer',
  components: {
    GlDrawer,
    GlButton,
    DataExplorer,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    open: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['close', 'add-panel'],
  data() {
    return {
      query: '',
      submittedQuery: '',
    };
  },
  computed: {
    drawerHeaderHeight() {
      return getContentWrapperHeight();
    },
    isQueryBlank() {
      return this.query.trim() === '';
    },
    hasPendingChanges() {
      return this.query !== this.submittedQuery;
    },
    isAddToDashboardDisabled() {
      return this.isQueryBlank || this.hasPendingChanges;
    },
    addToDashboardTooltip() {
      if (this.isQueryBlank) {
        return s__('AnalyticsDashboards|Enter and run a query to add it to the dashboard.');
      }

      if (this.hasPendingChanges) {
        return s__(
          'AnalyticsDashboards|You have pending changes. Run the query to add the latest version to the dashboard.',
        );
      }

      return '';
    },
  },
  methods: {
    handleAddPanel() {
      this.$emit('add-panel', wrapGlqlInVisualization(this.submittedQuery.trim()));
    },
  },
  DRAWER_Z_INDEX,
};
</script>
<template>
  <gl-drawer
    :open="open"
    :header-height="drawerHeaderHeight"
    :z-index="$options.DRAWER_Z_INDEX"
    variant="sidebar"
    class="!gl-w-full !gl-max-w-4xl"
    data-testid="add-panel-drawer"
    @close="$emit('close')"
  >
    <template #title>
      <h4 class="gl-m-0">{{ s__('AnalyticsDashboards|Add panel') }}</h4>
    </template>

    <template #default>
      <data-explorer v-model="query" @submit="submittedQuery = $event" />
    </template>

    <template #footer>
      <div class="gl-flex gl-w-full gl-items-center gl-gap-3">
        <span v-gl-tooltip :title="addToDashboardTooltip" data-testid="add-to-dashboard-tooltip">
          <gl-button
            variant="confirm"
            :disabled="isAddToDashboardDisabled"
            data-testid="add-to-dashboard-button"
            @click="handleAddPanel"
          >
            {{ s__('AnalyticsDashboards|Add to dashboard') }}
          </gl-button>
        </span>
        <gl-button data-testid="add-panel-cancel-button" @click="$emit('close')">
          {{ s__('AnalyticsDashboards|Cancel') }}
        </gl-button>
      </div>
    </template>
  </gl-drawer>
</template>
