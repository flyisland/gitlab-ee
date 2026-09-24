<!-- eslint-disable vue/multi-word-component-names -->
<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { GlAreaChart } from '@gitlab/ui/src/charts';
import { debounce, uniq } from 'lodash-es';
import { mapActions, mapState, mapGetters } from 'vuex';
import { getDatesInRange, toISODateFormat } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import { xAxisLabelFormatter } from '~/contributors/utils';

export default {
  components: {
    GlAreaChart,
    GlLoadingIcon,
  },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    branch: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      masterChart: null,
      individualCharts: [],
      masterChartHeight: 264,
      individualChartHeight: 216,
    };
  },
  computed: {
    ...mapState(['chartData', 'loading']),
    ...mapGetters(['showChart', 'parsedData']),
    masterChartData() {
      const data = {};
      this.xAxisRange.forEach((date) => {
        data[date] = this.parsedData.total[date] || 0;
      });
      return [
        {
          name: __('Commits'),
          data: Object.entries(data),
        },
      ];
    },
    masterChartOptions() {
      return {
        ...this.getCommonChartOptions(true),
        yAxis: {
          name: __('Number of commits'),
        },
        grid: {
          bottom: 64,
          left: 64,
          right: 20,
          top: 20,
        },
      };
    },
    mappedChartData() {
      const byAuthorEmail = {};

      this.chartData.forEach(
        ({
          date,
          author_name: authorName,
          author_email: authorEmail,
          additions,
          deletions,
          effective_additions: effectiveAdditions,
          effective_deletions: effectiveDeletions,
        }) => {
          const normalizedEmail = authorEmail.toLowerCase();
          const authorData = byAuthorEmail[normalizedEmail];

          if (!authorData) {
            byAuthorEmail[normalizedEmail] = {
              name: authorName,
              commits: 1,
              dates: {
                [date]: 1,
              },
              effectiveAdditions,
              effectiveDeletions,
              additions,
              deletions,
            };
          } else {
            authorData.commits += 1;
            authorData.additions += additions;
            authorData.deletions += deletions;
            authorData.effectiveAdditions += effectiveAdditions;
            authorData.effectiveDeletions += effectiveDeletions;

            authorData.dates[date] = authorData.dates[date] ? authorData.dates[date] + 1 : 1;
          }
        },
      );

      return byAuthorEmail;
    },
    individualChartsData() {
      const maxNumberOfIndividualContributorsCharts = 100;
      const mappedChartsData = this.mappedChartData;
      return Object.keys(mappedChartsData)
        .map((email) => {
          const {
            additions,
            commits,
            dates,
            deletions,
            effectiveAdditions,
            effectiveDeletions,
            name,
          } = mappedChartsData[email];
          return {
            name,
            email,
            commits,
            additions,
            deletions,
            effectiveAdditions,
            effectiveDeletions,

            dates: [
              {
                name: __('Commits'),
                data: this.xAxisRange.map((date) => [date, dates[date] || 0]),
              },
            ],
          };
        })
        .sort((a, b) => b.commits - a.commits)
        .slice(0, maxNumberOfIndividualContributorsCharts);
    },
    individualChartOptions() {
      return {
        ...this.getCommonChartOptions(false),
        yAxis: {
          name: __('Commits'),
          max: this.individualChartYAxisMax,
        },
        grid: {
          bottom: 27,
          left: 64,
          right: 20,
          top: 8,
        },
      };
    },
    individualChartYAxisMax() {
      return this.individualChartsData.reduce((acc, item) => {
        const values = item.dates[0].data.map((value) => value[1]);
        return Math.max(acc, ...values);
      }, 0);
    },
    xAxisRange() {
      const dates = Object.keys(this.parsedData.total).sort((a, b) => new Date(a) - new Date(b));

      const firstContributionDate = new Date(dates[0]);
      const lastContributionDate = new Date(dates[dates.length - 1]);

      return getDatesInRange(firstContributionDate, lastContributionDate, toISODateFormat);
    },
    firstContributionDate() {
      return this.xAxisRange[0];
    },
    lastContributionDate() {
      return this.xAxisRange[this.xAxisRange.length - 1];
    },
    charts() {
      return uniq(this.individualCharts);
    },
  },
  mounted() {
    this.fetchChartData(this.endpoint);
  },
  methods: {
    ...mapActions(['fetchChartData']),
    getCommonChartOptions(isMasterChart) {
      return {
        xAxis: {
          type: 'time',
          name: '',
          data: this.xAxisRange,
          axisLabel: {
            formatter: xAxisLabelFormatter,
            showMaxLabel: false,
            showMinLabel: false,
          },
          boundaryGap: false,
          splitNumber: isMasterChart ? 24 : 18,
          // 28 days
          minInterval: 28 * 86400 * 1000,
          min: this.firstContributionDate,
          max: this.lastContributionDate,
        },
      };
    },
    onMasterChartCreated(chart) {
      this.masterChart = chart;
      this.masterChart.setOption({
        dataZoom: [{ type: 'slider' }],
      });
      this.masterChart.on('datazoom', debounce(this.setIndividualChartsZoom, 200));
    },
    onIndividualChartCreated(chart) {
      this.individualCharts.push(chart);
    },
    setIndividualChartsZoom(options) {
      this.charts.forEach((chart) =>
        chart.setOption(
          {
            dataZoom: {
              start: options.start,
              end: options.end,
              show: false,
            },
          },
          { lazyUpdate: true },
        ),
      );
    },
  },
};
</script>

<template>
  <div>
    <div v-if="loading" class="contributors-loader text-center">
      <gl-loading-icon :inline="true" size="xl" />
    </div>

    <div v-else-if="showChart" class="contributors-charts">
      <h4 class="gl-mb-2 gl-mt-5">{{ __('Commits to') }} {{ branch }}</h4>
      <span>{{ __('Excluding merge commits. Limited to 6,000 commits.') }}</span>
      <gl-area-chart
        class="gl-mb-5"
        responsive
        width="auto"
        :data="masterChartData"
        :option="masterChartOptions"
        :height="masterChartHeight"
        @created="onMasterChartCreated"
      />
      <div class="row">
        <div
          v-for="(contributor, index) in individualChartsData"
          :key="index"
          class="col-lg-6 col-12 gl-my-5"
        >
          <h4 class="gl-mb-2 gl-mt-0">{{ contributor.name }}</h4>
          <p class="gl-mb-3">
            {{ n__('%d commit', '%d commits', contributor.commits) }} ({{ contributor.email }})
          </p>
          <p
            v-if="contributor.additions !== 0 || contributor.deletions !== 0"
            class="gl-mb-3 gl-flex gl-items-center"
            data-testid="code-lines-content"
          >
            <span class="gl-mr-3 gl-text-green-500" data-testid="code-lines-additions"
              >+ {{ n__('JH|%d line', 'JH|%d lines', contributor.additions) }}</span
            >
            <span class="gl-text-red-500" data-testid="code-lines-deletions"
              >- {{ n__('JH|%d line', 'JH|%d lines', contributor.deletions) }}</span
            >
          </p>
          <p
            v-if="contributor.effectiveAdditions !== 0 || contributor.effectiveDeletions !== 0"
            class="gl-mb-3 gl-flex gl-items-center"
            data-testid="effective-code-lines-content"
          >
            <span class="gl-mr-3 gl-text-green-500" data-testid="effective-code-lines-additions"
              >+
              {{
                n__('JH|%d effective line', 'JH|%d effective lines', contributor.effectiveAdditions)
              }}</span
            >
            <span class="gl-text-red-500" data-testid="effective-code-lines-deletions"
              >-
              {{
                n__('JH|%d effective line', 'JH|%d effective lines', contributor.effectiveDeletions)
              }}</span
            >
          </p>

          <gl-area-chart
            responsive
            width="auto"
            :data="contributor.dates"
            :option="individualChartOptions"
            :height="individualChartHeight"
            @created="onIndividualChartCreated"
          />
        </div>
      </div>
    </div>
  </div>
</template>
