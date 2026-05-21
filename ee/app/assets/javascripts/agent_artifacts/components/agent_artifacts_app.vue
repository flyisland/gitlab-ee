<script>
import AgentArtifactsTable from './agent_artifacts_table.vue';
import AgentArtifactsFilteredSearch from './agent_artifacts_filtered_search.vue';
import SessionDetailsDrawer from './session_details_drawer.vue';

export default {
  name: 'AgentArtifactsApp',
  components: {
    AgentArtifactsTable,
    AgentArtifactsFilteredSearch,
    SessionDetailsDrawer,
  },
  data() {
    return {
      activeItem: null,
      filter: {},
    };
  },
  methods: {
    handleFilter(filter) {
      this.activeItem = null;
      this.filter = filter;
    },
  },
};
</script>
<template>
  <div>
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
      @close="activeItem = null"
    />
  </div>
</template>
