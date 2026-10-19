<script>
import { GlToken } from '@gitlab/ui';
import { flowTriggerEventLabels } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'FlowTriggerEventTokens',
  components: {
    GlToken,
  },
  props: {
    flowTrigger: {
      type: Object,
      required: true,
    },
  },
  computed: {
    labels() {
      return flowTriggerEventLabels(this.flowTrigger);
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-wrap gl-gap-2 gl-whitespace-nowrap">
    <gl-token v-for="label in labels" :key="label" view-only>
      {{ label }}
    </gl-token>
  </div>
</template>
