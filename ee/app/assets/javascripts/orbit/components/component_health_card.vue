<script>
import { GlBadge, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { STATUS_HEALTHY, STATUS_UNKNOWN } from '../constants';

export default {
  name: 'ComponentHealthCard',
  compatConfig: { MODE: 3 },
  components: {
    GlBadge,
    GlIcon,
  },
  props: {
    component: {
      type: Object,
      required: true,
    },
  },
  computed: {
    variant() {
      return this.component.status === STATUS_HEALTHY ? 'success' : 'danger';
    },
    label() {
      switch (this.component.status) {
        case STATUS_HEALTHY:
          return s__('Orbit|Healthy');
        case STATUS_UNKNOWN:
          return s__('Orbit|No connection');
        default:
          return s__('Orbit|Unhealthy');
      }
    },
    dotClass() {
      return this.component.status === STATUS_HEALTHY
        ? 'gl-bg-status-success'
        : 'gl-bg-status-danger';
    },
  },
};
</script>

<template>
  <div
    class="gl-flex-1 gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-strong gl-p-4"
  >
    <div class="gl-flex gl-items-center gl-gap-3">
      <span
        class="gl-inline-block gl-h-3 gl-w-3 gl-flex-shrink-0 gl-self-center gl-rounded-full"
        :class="dotClass"
      ></span>
      <span class="gl-font-bold">{{ component.name }}</span>
      <gl-badge :variant="variant" size="sm">
        {{ label }}
      </gl-badge>
    </div>
    <div
      v-if="component.metadata"
      class="gl-mt-2 gl-flex gl-items-center gl-gap-2 gl-text-sm gl-text-subtle"
    >
      <gl-icon name="settings" :size="14" />
      <span>{{ s__('Orbit|Additional metadata if required') }}</span>
    </div>
  </div>
</template>
