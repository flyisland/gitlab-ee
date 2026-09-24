<script>
import { GlLink, GlTooltipDirective } from '@gitlab/ui';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { projectAutomateAgentSessionPath } from 'ee/lib/utils/path_helpers/project';
import { AGENTS_PLATFORM_SHOW_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import { formatAgentStatus, formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import { AGENT_PLATFORM_STATUS_BADGE } from 'ee/ai/duo_agents_platform/constants';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import { AGENT_SESSION_INBOX_STATUS_LABELS, STATUS_TEXT_CLASS } from './constants';

export default {
  name: 'AgentSessionInboxItem',
  components: { GlLink, AgentStatusIcon, TimeAgoTooltip },
  directives: { GlTooltip: GlTooltipDirective },
  props: {
    item: {
      required: true,
      type: Object,
    },
  },
  computed: {
    numericId() {
      return getIdFromGraphQLId(this.item.id);
    },
    title() {
      return this.item.title || null;
    },
    tooltipText() {
      return this.title ? `${this.title} #${this.numericId}` : `#${this.numericId}`;
    },
    flowName() {
      return formatAgentDefinition(this.item.workflowDefinition);
    },
    sessionRoute() {
      return { name: AGENTS_PLATFORM_SHOW_ROUTE, params: { id: this.numericId } };
    },
    sessionUrl() {
      const fullPath = this.item.project?.fullPath;
      return fullPath ? projectAutomateAgentSessionPath(fullPath, this.numericId) : null;
    },
    statusLabel() {
      return (
        AGENT_SESSION_INBOX_STATUS_LABELS[this.item.status] ??
        formatAgentStatus(this.item.humanStatus)
      );
    },
    statusTextClass() {
      const { variant } = AGENT_PLATFORM_STATUS_BADGE[this.item.status] ?? {};
      return STATUS_TEXT_CLASS[variant] ?? STATUS_TEXT_CLASS.neutral;
    },
    linkHoverStyles() {
      return [
        'hover:gl-bg-subtle',
        'hover:gl-no-underline',
        'focus-visible:gl-no-underline',
        'active:gl-no-underline',
        'focus-visible:active:gl-no-underline',
      ];
    },
  },
  methods: {
    handleItemSelected(event) {
      if (event.metaKey || event.ctrlKey || event.shiftKey) return;
      event.preventDefault();
      this.$router.push(this.sessionRoute);
    },
  },
};
</script>
<template>
  <gl-link
    :href="sessionUrl"
    class="gl-flex gl-flex-col gl-p-4"
    :class="linkHoverStyles"
    @click="handleItemSelected"
  >
    <div class="gl-flex gl-items-center gl-justify-between">
      <div class="gl-flex gl-min-w-0 gl-items-center gl-gap-2">
        <agent-status-icon :status="item.status" :human-status="statusLabel" />
        <span
          class="gl-shrink-0 gl-text-sm gl-font-semibold"
          :class="statusTextClass"
          data-testid="item-status-label"
          >{{ statusLabel }}</span
        >
      </div>
      <time-ago-tooltip
        :time="item.updatedAt"
        class="gl-shrink-0 gl-pl-3 gl-text-sm gl-text-subtle"
        data-testid="item-updated-date"
      />
    </div>
    <strong
      v-gl-tooltip
      class="gl-min-w-0 gl-truncate gl-text-strong"
      :title="tooltipText"
      data-testid="item-title"
      >{{ title }}</strong
    >
    <div class="gl-min-w-0 gl-truncate gl-text-sm gl-text-subtle" data-testid="item-metadata">
      <span aria-hidden="true">#</span>{{ numericId }} <span aria-hidden="true"> · </span
      >{{ flowName
      }}<template v-if="item.project">
        <span aria-hidden="true"> · </span>{{ item.project.name }}</template
      >
    </div>
  </gl-link>
</template>
