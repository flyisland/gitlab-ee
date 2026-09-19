<script>
import { camelCase } from 'lodash-es';
import { GlStackedColumnChart } from '@gitlab/ui/src/charts';
import { GL_COLOR_NEUTRAL_300, DATA_VIZ_BLUE_500 } from '@gitlab/ui/src/tokens/build/js/tokens';
import {
  listenSystemColorSchemeChange,
  removeListenerSystemColorSchemeChange,
} from '~/lib/utils/css_utils';
import { getSeverityColors } from 'ee/security_dashboard/utils/chart_utils';
import { REPORT_TYPE_COLORS } from 'ee/security_dashboard/components/shared/vulnerability_report/constants';

const COUNT_BAR_COLOR = GL_COLOR_NEUTRAL_300;
const DEFAULT_LINE_COLOR = DATA_VIZ_BLUE_500;

export default {
  name: 'MttrOverTimeChart',
  components: {
    GlStackedColumnChart,
  },
  props: {
    mttrSeries: {
      type: Array,
      required: true,
    },
    countSeries: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      severityColors: {},
    };
  },
  computed: {
    lines() {
      return this.mttrSeries.map(({ name, data }) => ({ name, data }));
    },
    secondaryData() {
      return [{ name: this.countSeries.name, data: this.countSeries.data, type: 'bar' }];
    },
    groupBy() {
      return this.countSeries.data.map(([startDate]) => startDate);
    },
    customPalette() {
      // Ordered to match the chart's series: MTTR lines first, then the count bar (secondary axis).
      return [
        ...this.mttrSeries.map(({ id }) => this.seriesColor(id) || DEFAULT_LINE_COLOR),
        COUNT_BAR_COLOR,
      ];
    },
  },
  mounted() {
    this.setSeverityColors();
    listenSystemColorSchemeChange(this.setSeverityColors);
  },
  destroyed() {
    removeListenerSystemColorSchemeChange(this.setSeverityColors);
  },
  methods: {
    setSeverityColors() {
      this.severityColors = getSeverityColors();
    },
    seriesColor(seriesId) {
      const normalizedId = camelCase(seriesId);
      return this.severityColors[normalizedId] || REPORT_TYPE_COLORS[normalizedId];
    },
  },
  chartOptions: {
    animation: false,
    yAxis: [
      {
        // eslint-disable-next-line @gitlab/require-i18n-strings
        axisLabel: { formatter: '{value}d' },
      },
      {
        minInterval: 1,
      },
    ],
    // Note: This is a workaround to remove the extra whitespace when the chart has no title
    // Once https://gitlab.com/gitlab-org/gitlab-services/design.gitlab.com/-/issues/2199 has been fixed, this can be removed
    grid: {
      left: '10px',
      right: '10px',
      bottom: '10px',
      top: '10px',
      containLabel: true,
    },
  },
};
</script>

<template>
  <gl-stacked-column-chart
    :lines="lines"
    :secondary-data="secondaryData"
    :group-by="groupBy"
    :option="$options.chartOptions"
    :custom-palette="customPalette"
    :include-legend-avg-max="false"
    x-axis-title=""
    y-axis-title=""
    presentation="tiled"
    x-axis-type="category"
    responsive
    height="auto"
    class="gl-h-full gl-w-full"
  />
</template>
