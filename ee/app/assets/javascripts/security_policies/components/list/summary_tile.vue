<script>
import { GlCard, GlButton } from '@gitlab/ui';

export default {
  name: 'SummaryTile',
  components: { GlCard, GlButton },
  props: {
    title: {
      type: String,
      required: true,
    },
    count: {
      type: Number,
      required: false,
      default: 0,
    },
    status: {
      type: String,
      required: false,
      default: '',
    },
    actionLabel: {
      type: String,
      required: true,
    },
    actionHref: {
      type: String,
      required: false,
      default: '#',
    },
  },
};
</script>

<template>
  <gl-card>
    <div class="gl-flex gl-flex-col gl-gap-2">
      <span class="gl-mb-2 gl-font-bold">{{ title }}</span>
      <span class="gl-text-3xl gl-font-bold">{{ count }}</span>
      <span v-if="status" class="gl-text-sm gl-text-secondary">{{ status }}</span>
      <gl-button variant="link" size="small" :href="actionHref">
        {{ actionLabel }}
      </gl-button>
    </div>
  </gl-card>
</template>
