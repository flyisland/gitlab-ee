<script>
import { mapState } from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import PerformanceValueFilters from 'jh/analytics/performance_analytics/components/performance_value_filters.vue';
import PerformanceBoard from 'jh/analytics/performance_analytics/components/performance_board.vue';
import PerformanceTable from 'jh/analytics/performance_analytics/components/performance_table.vue';

export default {
  name: 'PerformanceAnalytics',
  components: {
    PerformanceValueFilters,
    PerformanceBoard,
    PerformanceTable,
    GlLoadingIcon,
  },
  computed: {
    ...mapState({
      groupId: (state) => state.groupId,
      fullPath: (state) => state.fullPath,
      loading: (state) => state.loading,
    }),
  },
};
</script>

<template>
  <div class="performance-analytics-app">
    <performance-value-filters class="gl-mb-6" :group-id="groupId" :full-path="fullPath" />
    <gl-loading-icon v-if="loading" size="lg" />
    <template v-else>
      <performance-board />
      <performance-table />
    </template>
  </div>
</template>
