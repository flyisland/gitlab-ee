<script>
import { PLAN_READINESS_LEVELS, READINESS_SCORE_BAR_COUNT } from './constants';
import { getVariantColor } from './utils';

export default {
  name: 'ReadinessBar',
  props: {
    readinessLevel: {
      type: Object,
      required: true,
      validator: (value) => Object.keys(PLAN_READINESS_LEVELS).includes(value.value),
    },
    ariaLabel: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    pillBgClass() {
      return getVariantColor(this.readinessLevel.variant);
    },
    pillStyle() {
      const { barsToFill } = this.readinessLevel;
      return {
        width: `${(barsToFill / READINESS_SCORE_BAR_COUNT) * 100}%`,
        backgroundColor: this.pillBgClass,
      };
    },
  },
};
</script>
<template>
  <span
    class="gl-relative gl-block gl-h-2 gl-w-11 gl-rounded-sm gl-bg-status-neutral"
    role="status"
    :aria-label="ariaLabel"
  >
    <span class="gl-absolute gl-block gl-h-2 gl-rounded-sm" :style="pillStyle"></span>
  </span>
</template>
