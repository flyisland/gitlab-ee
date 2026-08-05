<script>
import { humanize } from '~/lib/utils/text_utility';

// Ordered palette: colours are assigned in sequence to each new component name
// encountered, and reused if the same component name appears again later.
export const COMPONENT_COLORS = [
  'gl-text-blue-500',
  'gl-text-green-500',
  'gl-text-orange-500',
  'gl-text-purple-500',
  'gl-text-red-500',
  'gl-text-teal-500',
];

export default {
  name: 'ComponentLabel',
  props: {
    componentName: {
      type: String,
      required: true,
    },
    colorIndex: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  computed: {
    capitalizedName() {
      return humanize(this.componentName);
    },
    colorClass() {
      return COMPONENT_COLORS[this.colorIndex % COMPONENT_COLORS.length];
    },
  },
};
</script>

<template>
  <span>
    <span class="gl-font-bold" :class="colorClass" data-testid="component-label-name">{{
      capitalizedName
    }}</span>
    <span class="gl-mx-1" data-testid="component-label-separator">·</span>
  </span>
</template>
