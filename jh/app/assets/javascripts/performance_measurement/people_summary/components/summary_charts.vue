<script>
import { GlTabs, GlTab, GlLoadingIcon, GlSegmentedControl } from '@gitlab/ui';
import { GlLineChart } from '@gitlab/ui/src/charts';
import { zip } from 'lodash-es';
import { __ } from '~/locale';
import { CHART_RANGE_OPTIONS, CHART_TABS } from '../constants';
import { fetchChartData } from '../api';

export default {
  components: {
    GlTabs,
    GlTab,
    GlLineChart,
    GlSegmentedControl,
    GlLoadingIcon,
  },
  data() {
    return {
      chartData: [],
      currentTab: CHART_TABS[0].title,
      currentRange: 'day',
      loading: false,
    };
  },
  computed: {
    chartOptions() {
      return {
        animation: false,
        xAxis: { name: __('Time'), type: 'category' },
      };
    },
  },
  async mounted() {
    this.loading = true;
    try {
      const { date_list: dates, ...metrics } = await fetchChartData();

      this.chartData = Object.entries(metrics).map(([key, value]) => {
        return {
          name: key,
          data: zip(dates, value),
        };
      });
    } finally {
      this.loading = false;
    }
  },
  methods: {
    onRangeChange(range) {
      this.currentRange = range;
    },
  },
  CHART_RANGE_OPTIONS,
  CHART_TABS,
};
</script>

<template>
  <div class="flex-column gl-mt-6 gl-flex">
    <div class="justify-content-between gl-flex">
      <gl-tabs class="gl-w-full" data-testid="summary-chart-tabs">
        <gl-tab
          v-for="tab in $options.CHART_TABS"
          :key="tab.title"
          :title="tab.title"
          :data-testid="`summary-chart-tab-${tab.value}`"
          @click="currentTab = tab.title"
        />
      </gl-tabs>
    </div>
    <div class="justify-content-between gl-flex">
      <strong data-testid="summary-chart-title">
        {{ currentTab }}
      </strong>
      <div class="gl-flex gl-gap-3">
        <gl-segmented-control
          :options="$options.CHART_RANGE_OPTIONS"
          :value="currentRange"
          data-testid="summary-chart-range-segmented-control"
          @input="onRangeChange"
        />
      </div>
    </div>
    <gl-loading-icon v-if="loading" data-testid="summary-chart-loading-icon" />
    <gl-line-chart v-else :data="chartData" :option="chartOptions" data-testid="summary-chart" />
  </div>
</template>
