<script>
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import AgentArtifactsTable from './agent_artifacts_table.vue';
import AgentArtifactsFilteredSearch from './agent_artifacts_filtered_search.vue';
import SessionDetailsDrawer from './session_details_drawer.vue';
import SessionDetailsBody from './session_details_body.vue';
import AuditEventDetailsPanel from './audit_event_details_panel.vue';

export default {
  name: 'AgentArtifactsApp',
  components: {
    AgentArtifactsTable,
    AgentArtifactsFilteredSearch,
    SessionDetailsDrawer,
    SessionDetailsBody,
    AuditEventDetailsPanel,
  },
  data() {
    return {
      activeItem: null,
      filter: {},
      selectedEvent: null,
      isFullPage: false,
    };
  },
  computed: {
    sessionName() {
      return this.activeItem?.workflowDefinition
        ? formatAgentDefinition(this.activeItem.workflowDefinition)
        : '';
    },
  },
  methods: {
    handleFilter(filter) {
      this.activeItem = null;
      this.selectedEvent = null;
      this.isFullPage = false;
      this.filter = filter;
    },
    handleDrawerClose() {
      this.activeItem = null;
      this.selectedEvent = null;
    },
    handleFullPageClose() {
      this.isFullPage = false;
      this.selectedEvent = null;
      this.activeItem = null;
    },
  },
};
</script>
<template>
  <div>
    <div
      v-if="isFullPage && activeItem && selectedEvent"
      class="@container/panel gl-flex gl-flex-col gl-gap-5 @xl/panel:gl-flex-row"
    >
      <session-details-body
        :active-item="activeItem"
        :session-id="activeItem.id"
        class="gl-w-full @xl/panel:gl-w-1/2"
        @select="selectedEvent = $event"
      />
      <audit-event-details-panel
        :event="selectedEvent"
        :session-name="sessionName"
        :workflow-definition="activeItem.workflowDefinition"
        :is-full-page="true"
        class="gl-w-full @xl/panel:gl-w-1/2"
        @close="handleFullPageClose"
      />
    </div>

    <template v-else>
      <agent-artifacts-filtered-search class="gl-mt-5" @filter="handleFilter" />

      <agent-artifacts-table
        class="gl-mt-5"
        :active-item="activeItem"
        :filter="filter"
        @row-click="activeItem = $event"
      />

      <session-details-drawer
        v-if="activeItem"
        :active-item="activeItem"
        :selected-event="selectedEvent"
        :session-name="sessionName"
        @close="handleDrawerClose"
        @select="selectedEvent = $event"
        @back="selectedEvent = null"
        @maximize="isFullPage = true"
      />
    </template>
  </div>
</template>
