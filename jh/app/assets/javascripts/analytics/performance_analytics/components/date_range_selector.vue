<script>
import { GlButton, GlButtonGroup, GlDaterangePicker } from '@gitlab/ui';
import { n__, __, sprintf } from '~/locale';
import {
  DATE_RANGE_LIST,
  DATE_RANGE_LIMIT,
  DEFAULT_SELECT_RANGE,
  FROM_LABEL,
  TO_LABEL,
} from 'jh/analytics/performance_analytics/constants';
import { nDaysBefore } from '~/lib/utils/datetime_utility';

const DATE_RANGE_BUTTONS = DATE_RANGE_LIST.map((count) => {
  return {
    days: count,
    text: n__('JH|PerformanceAnalytics|Last %d day', 'JH|PerformanceAnalytics|Last %d days', count),
  };
});

export default {
  name: 'DateRangeSelector',
  components: {
    GlButtonGroup,
    GlButton,
    GlDaterangePicker,
  },
  props: {
    currentDate: {
      type: Date,
      required: true,
    },
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
  },
  data() {
    return {
      selectedRange: DEFAULT_SELECT_RANGE,
    };
  },
  computed: {
    dateRange() {
      return { startDate: this.startDate, endDate: this.endDate };
    },
  },
  maxDateRange: DATE_RANGE_LIMIT,
  dateRangeButtons: DATE_RANGE_BUTTONS,
  i18n: {
    dateRangeTooltip: sprintf(__('Date range limited to %{number} days'), {
      number: DATE_RANGE_LIMIT,
    }),
    fromLabel: FROM_LABEL,
    toLabel: TO_LABEL,
  },
  methods: {
    switchButtonDateRange(days) {
      this.selectedRange = days;
      const startDate = nDaysBefore(this.currentDate, days - 1, { utc: true });
      const endDate = this.currentDate;
      this.updateSelectedDate({ startDate, endDate });
    },
    dateRangeChanged({ startDate, endDate }) {
      if (startDate && endDate) {
        this.selectedRange = null;
        this.updateSelectedDate({ startDate, endDate });
      }
    },
    updateSelectedDate({ startDate, endDate }) {
      this.$emit('updateDate', { startDate, endDate });
    },
  },
};
</script>

<template>
  <div class="date-range-selector gl-inline-flex gl-flex-col lg:gl-flex-row">
    <gl-button-group class="date-button-group gl-mb-2 lg:gl-mb-0">
      <gl-button
        v-for="item in $options.dateRangeButtons"
        :key="`${item.days}-days`"
        :selected="item.days === selectedRange"
        :data-testid="`last-${item.days}-days`"
        @click="switchButtonDateRange(item.days)"
        >{{ item.text }}</gl-button
      >
    </gl-button-group>
    <gl-daterange-picker
      class="gl-flex gl-flex-col lg:gl-flex-row"
      label-class="gl-mb-2 lg:gl-mb-0"
      start-picker-class="gl-flex gl-flex-col lg:gl-flex-row lg:gl-items-center lg:gl-mr-3 gl-mb-2 lg:gl-mb-0"
      end-picker-class="gl-flex gl-flex-col lg:gl-flex-row lg:gl-items-center gl-mb-2 lg:gl-mb-0"
      :default-start-date="startDate"
      :default-end-date="currentDate"
      :max-date-range="$options.maxDateRange"
      :default-max-date="currentDate"
      :same-day-selection="true"
      :tooltip="$options.i18n.dateRangeTooltip"
      :value="dateRange"
      :from-label="$options.i18n.fromLabel"
      :to-label="$options.i18n.toLabel"
      @input="dateRangeChanged"
    />
  </div>
</template>
