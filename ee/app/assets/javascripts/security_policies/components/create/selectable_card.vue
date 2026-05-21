<script>
import { GlButton, GlIcon } from '@gitlab/ui';

export default {
  name: 'SelectableCard',
  components: { GlButton, GlIcon },
  props: {
    item: {
      type: Object,
      required: true,
    },
    selected: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select'],
};
</script>

<template>
  <gl-button
    class="gl-w-full gl-cursor-pointer !gl-justify-start gl-rounded-base gl-bg-default gl-p-3 gl-text-left"
    :class="selected ? ['gl-border-2', 'gl-border-blue-500'] : ['gl-border', 'gl-border-default']"
    @click="$emit('select', item.id)"
  >
    <div class="gl-flex gl-items-center gl-gap-3">
      <gl-icon :name="item.icon" class="gl-shrink-0 gl-text-secondary" />
      <div class="gl-py-2">
        <p class="gl-mb-1 gl-text-sm gl-font-bold">{{ item.label }}</p>
        <p class="gl-mb-0 gl-text-sm gl-text-secondary">{{ item.description }}</p>
      </div>
    </div>
  </gl-button>
</template>
