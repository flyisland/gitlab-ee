<script>
import { GlBadge } from '@gitlab/ui';
import {
  TEST_RUN_STATE_CONFIG,
  DEFAULT_TEST_RUN_CONFIG,
} from 'ee/security_orchestration/components/policies/constants';

export default {
  name: 'TestRunStatusBadge',
  components: {
    GlBadge,
  },
  props: {
    testRuns: {
      type: Object,
      required: false,
      default: null,
    },
  },
  computed: {
    testRun() {
      return this.testRuns?.nodes?.[0];
    },
    shouldShowBadge() {
      return Boolean(this.testRun);
    },
    badgeConfig() {
      return TEST_RUN_STATE_CONFIG[this.testRun?.state] || DEFAULT_TEST_RUN_CONFIG;
    },
  },
};
</script>

<template>
  <gl-badge
    v-if="shouldShowBadge"
    :variant="badgeConfig.variant"
    :icon="badgeConfig.icon"
    size="sm"
    data-testid="test-run-badge"
  >
    {{ badgeConfig.text }}
  </gl-badge>
</template>
