<script>
import { GlBadge } from '@gitlab/ui';
import { humanize } from '~/lib/utils/text_utility';
import { s__, sprintf } from '~/locale';

const STATUS_VARIANTS = {
  running: 'info',
  finished: 'success',
  completed: 'success',
  success: 'success',
  failed: 'danger',
  error: 'danger',
  input_required: 'warning',
  paused: 'warning',
};

export default {
  name: 'SubagentBadge',
  components: {
    GlBadge,
  },
  props: {
    componentName: {
      type: String,
      required: true,
    },
    subsessionId: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    capitalizedName() {
      return humanize(this.componentName);
    },
    statusText() {
      return this.status ? humanize(this.status.toLowerCase()) : null;
    },
    sessionLabel() {
      return sprintf(s__('DuoAgentPlatform|%{name} session %{id}'), {
        name: this.capitalizedName,
        id: this.subsessionId,
      });
    },
    statusVariant() {
      return (this.status && STATUS_VARIANTS[this.status.toLowerCase()]) || 'neutral';
    },
  },
};
</script>

<template>
  <span class="gl-inline-flex gl-items-center gl-gap-2">
    <span>{{ sessionLabel }}</span>
    <gl-badge variant="neutral">{{ s__('DuoAgentPlatform|Subagent') }}</gl-badge>
    <gl-badge v-if="status" :variant="statusVariant">{{ statusText }}</gl-badge>
  </span>
</template>
