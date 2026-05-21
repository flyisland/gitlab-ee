<script>
import { GlBadge, GlDisclosureDropdown, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';

const SEVERITY_VARIANTS = {
  critical: 'danger',
  high: 'warning',
  medium: 'neutral',
};

export default {
  name: 'PolicyRow',
  components: { GlBadge, GlDisclosureDropdown, GlLink },
  props: {
    policy: {
      type: Object,
      required: true,
    },
  },
  emits: ['edit', 'delete'],
  data() {
    return {
      menuItems: [
        { text: s__('SecurityOrchestration|Edit'), action: 'edit' },
        { text: s__('SecurityOrchestration|Delete'), action: 'delete' },
      ],
    };
  },
  computed: {
    severityVariant() {
      return SEVERITY_VARIANTS[this.policy.severity] || 'muted';
    },
    statusVariant() {
      return this.policy.status === 'active' ? 'success' : 'neutral';
    },
  },
  methods: {
    handleAction(action) {
      this.$emit(action);
    },
  },
};
</script>

<template>
  <div class="gl-border-b gl-flex gl-items-center gl-gap-3 gl-py-3">
    <gl-link :href="`#${policy.id}`" class="gl-flex-grow gl-font-bold">{{ policy.name }}</gl-link>
    <gl-badge variant="info">{{ policy.type }}</gl-badge>
    <gl-badge :variant="severityVariant">{{ policy.severity }}</gl-badge>
    <gl-badge :variant="statusVariant">{{ policy.status }}</gl-badge>
    <gl-disclosure-dropdown icon="ellipsis_v" no-caret :items="menuItems" @action="handleAction" />
  </div>
</template>
