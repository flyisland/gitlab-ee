<script>
import ViewFinder from './components/view_finder.vue';
import SummaryHeader from './components/summary_header.vue';
import SummaryStatistics from './components/summary_statistics.vue';
import SummaryCharts from './components/summary_charts.vue';
import SummaryTable from './components/summary_table.vue';

export default {
  name: 'PeopleSummaryApp',
  components: {
    SummaryHeader,
    SummaryStatistics,
    SummaryCharts,
    SummaryTable,
    ViewFinder,
  },
  data() {
    return {
      filters: {},
    };
  },
  methods: {
    onFilterUpdated(val) {
      this.filters = val;
    },
    saveView() {
      // do something here with the view and name combining filters.
    },
  },
};
</script>
<template>
  <div class="gl-bg-white gl-pt-5">
    <view-finder @save="saveView" />
    <summary-header @change="onFilterUpdated" />
    <summary-statistics :filters="filters" />
    <summary-charts />
    <summary-table />
  </div>
</template>
