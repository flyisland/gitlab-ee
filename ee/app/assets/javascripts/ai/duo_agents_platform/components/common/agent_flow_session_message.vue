<script>
import { GlIcon } from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'AgentFlowSessionMessage',
  components: {
    GlIcon,
    TimeAgoTooltip,
  },
  props: {
    icon: {
      type: String,
      required: true,
    },
    iconVariant: {
      type: String,
      required: false,
      default: 'subtle',
    },
    title: {
      type: String,
      required: true,
    },
    timestamp: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <li class="gl-mb-5 gl-flex gl-items-start" data-testid="agent-flow-session-message">
    <div class="gl-relative gl-mr-4 gl-flex gl-flex-col gl-items-center">
      <div class="gl-border gl-flex gl-rounded-full gl-bg-strong gl-p-2">
        <gl-icon :name="icon" :variant="iconVariant" data-testid="session-message-icon" />
      </div>
    </div>

    <div class="gl-flex-1 gl-pt-1">
      <div class="gl-mb-2 gl-flex gl-justify-between">
        <strong class="gl-text-strong" data-testid="log-entry-title">{{ title }}</strong>
        <time-ago-tooltip
          :time="timestamp"
          css-class="gl-text-subtle gl-text-sm"
          data-testid="log-entry-timestamp"
        />
      </div>

      <div class="gl-py-2">
        <slot></slot>
      </div>
    </div>
  </li>
</template>
