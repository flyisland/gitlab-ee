<script>
import { GlDisclosureDropdown, GlIcon, GlToggle, GlTruncate } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { FLOW_TRIGGERS_EDIT_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { flowTriggerEventLabels, scheduleSummaryLabels } from 'ee/ai/duo_agents_platform/utils';

export default {
  name: 'AutomationRow',
  components: {
    GlDisclosureDropdown,
    GlIcon,
    GlToggle,
    GlTruncate,
  },
  props: {
    automation: {
      type: Object,
      required: true,
    },
    isToggling: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['delete', 'toggle'],
  computed: {
    schedule() {
      return scheduleSummaryLabels(this.automation.filter)[0];
    },
    conditions() {
      return this.schedule ?? flowTriggerEventLabels(this.automation).join(', ');
    },
    actionItems() {
      return [
        {
          text: s__('DuoAgentsPlatform|Edit automation'),
          to: {
            name: FLOW_TRIGGERS_EDIT_ROUTE,
            params: { id: getIdFromGraphQLId(this.automation.id) },
          },
        },
        {
          text: s__('DuoAgentsPlatform|Delete automation'),
          action: () => this.$emit('delete', this.automation.id),
          variant: 'danger',
        },
      ];
    },
    toggleLabel() {
      return sprintf(
        s__('DuoAgentsPlatform|Turn automation on or off: %{description}'),
        { description: this.automation.description },
        false,
      );
    },
  },
};
</script>

<template>
  <li class="gl-border-b gl-flex gl-items-start gl-justify-between gl-gap-3 gl-px-5 gl-py-3">
    <div class="gl-flex gl-min-w-0 gl-grow gl-flex-col gl-gap-2">
      <span class="gl-font-bold" data-testid="automation-description">
        {{ automation.description }}
      </span>
      <span
        v-if="conditions"
        class="gl-flex gl-min-w-0 gl-items-center gl-gap-2 gl-text-subtle"
        data-testid="automation-conditions"
      >
        <gl-icon :name="schedule ? 'clock' : 'trigger-source'" class="gl-shrink-0" />
        <gl-truncate :text="conditions" with-tooltip />
      </span>
    </div>

    <div class="gl-flex gl-shrink-0 gl-items-center gl-gap-3">
      <gl-toggle
        :value="automation.active"
        :is-loading="isToggling"
        :label="toggleLabel"
        label-position="hidden"
        @change="$emit('toggle', { id: automation.id, active: $event })"
      />
      <gl-disclosure-dropdown
        :items="actionItems"
        :toggle-text="__('More actions')"
        text-sr-only
        icon="ellipsis_v"
        category="tertiary"
        no-caret
        placement="bottom-end"
      />
    </div>
  </li>
</template>
