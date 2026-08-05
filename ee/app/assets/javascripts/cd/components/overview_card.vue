<script>
import { GlButton } from '@gitlab/ui';

export default {
  name: 'OverviewCard',
  components: {
    GlButton,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    expanded: {
      type: Boolean,
      required: true,
    },
    expandAriaLabel: {
      type: String,
      required: true,
    },
    collapseAriaLabel: {
      type: String,
      required: true,
    },
  },
  emits: ['toggle'],
  computed: {
    rootBindings() {
      // Expanded cards span a full row. Collapsed cards stack full-width on
      // mobile and only share a row from the `sm` breakpoint up (gl-basis-0).
      return {
        class: this.expanded ? 'gl-basis-full' : 'gl-grow gl-basis-full sm:gl-basis-0',
        'data-testid': this.expanded ? 'overview-card-expanded' : 'overview-card-collapsed',
      };
    },
    buttonBindings() {
      return {
        icon: this.expanded ? 'minimize' : 'maximize',
        'aria-label': this.expanded ? this.collapseAriaLabel : this.expandAriaLabel,
        'data-testid': this.expanded ? 'collapse-button' : 'expand-button',
      };
    },
  },
};
</script>

<template>
  <div
    class="gl-min-w-0 gl-rounded-base gl-border-1 gl-border-solid gl-border-default gl-p-4"
    v-bind="rootBindings"
  >
    <div class="gl-mb-3 gl-flex gl-items-center gl-justify-between">
      <h3 class="gl-m-0 gl-text-sm gl-font-bold gl-uppercase gl-text-neutral-700">{{ title }}</h3>
      <gl-button
        v-bind="buttonBindings"
        category="tertiary"
        size="small"
        @click="$emit('toggle')"
      />
    </div>
    <slot></slot>
  </div>
</template>
