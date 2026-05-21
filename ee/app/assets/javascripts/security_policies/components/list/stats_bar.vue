<script>
import { GlIcon } from '@gitlab/ui';

export default {
  name: 'StatsBar',
  components: { GlIcon },
  props: {
    stats: {
      type: Array,
      required: true,
      validator: (items) => items.every((s) => 'icon' in s && 'count' in s && 'label' in s),
    },
  },
};
</script>

<template>
  <div class="gl-border-b gl-flex gl-gap-5 gl-pb-4">
    <div v-for="(stat, index) in stats" :key="index" class="gl-flex gl-items-center gl-gap-2">
      <gl-icon :name="stat.icon" :variant="stat.variant" />
      <span class="gl-font-bold">{{ stat.count }}</span>
      <span class="gl-text-secondary">{{ stat.label }}</span>
    </div>
  </div>
</template>
