<script>
/* eslint-disable vue/no-unused-properties */
import { isEmpty } from 'lodash-es';
import SingleStat from '~/analytics/analytics_dashboards/components/visualizations/single_stat.vue';
import { fetchPeopleSummary } from '../api';
import { ACTIVITY_METRICS, STATISTICS_I18N } from '../constants';

export default {
  name: 'SummaryStatistics',
  components: {
    SingleStat,
  },
  props: {
    filters: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      loaded: false,
      summary: {},
    };
  },
  computed: {
    codeValidityRatio() {
      const { summary } = this;

      if (isEmpty(summary) || !summary.code_lines) return 0;

      return `${((summary.valid_code_lines / summary.code_lines) * 100).toFixed(2)}%`;
    },
    validityRatioOptions() {
      return {
        title: this.$options.i18n.validityRatioTitle,
      };
    },
  },
  mounted() {
    this.fetchPeopleSummary();
  },
  methods: {
    async fetchPeopleSummary() {
      this.summary = await fetchPeopleSummary();
    },
    statOptions({ title }) {
      return {
        title,
      };
    },
  },
  ACTIVITY_METRICS,
  i18n: STATISTICS_I18N,
};
</script>

<template>
  <div class="flex-column gl-flex gl-justify-between">
    <p class="gl-font-md gl-mb-5 gl-mt-6 gl-font-bold">{{ $options.i18n.activityMetricsTitle }}</p>
    <div class="justify-content-between gl-flex gl-gap-3">
      <single-stat
        v-for="stat in $options.ACTIVITY_METRICS"
        :key="stat.key"
        :data="summary[stat.key]"
        :options="statOptions(stat)"
        class="gl-mt-2"
      />
    </div>
  </div>
</template>
