<script>
import { GlIcon } from '@gitlab/ui';
import { getAgentStatusIconVariant } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'AgentStatusIcon',
  components: {
    GlIcon,
  },
  props: {
    status: {
      required: true,
      type: String,
    },
    humanStatus: {
      required: true,
      type: String,
    },
  },
  computed: {
    itemStatus() {
      return getAgentStatusIconVariant(this.status);
    },
  },
};
</script>

<template>
  <gl-icon
    :name="itemStatus.icon"
    :aria-label="humanStatus"
    :size="12"
    :variant="itemStatus.variant"
  />
</template>
