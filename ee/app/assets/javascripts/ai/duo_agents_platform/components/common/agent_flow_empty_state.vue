<script>
import { GlIcon, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import { getDayDifference } from '~/lib/utils/datetime/date_calculation_utility';
import { helpPagePath } from '~/helpers/help_page_helper';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import { AGENT_PLATFORM_SESSION_RETENTION_LENGTH } from '../../constants';
import AgentFlowTriggeredUser from './agent_flow_triggered_user.vue';

export default {
  name: 'AgentFlowEmptyState',
  components: {
    GlIcon,
    GlLink,
    GlSprintf,
    TimeAgoTooltip,
    AgentFlowTriggeredUser,
  },
  props: {
    createdAt: {
      type: String,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    hasLogs: {
      type: Boolean,
      required: true,
    },
    updatedAt: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      required: true,
    },
    userId: {
      type: String,
      required: true,
    },
  },
  computed: {
    isWithinRetention() {
      const daysSinceUpdate = getDayDifference(new Date(this.updatedAt), new Date());
      return daysSinceUpdate <= AGENT_PLATFORM_SESSION_RETENTION_LENGTH;
    },
    isFailed() {
      return this.status === 'FAILED';
    },
    emptyStateItems() {
      if (!this.isWithinRetention) {
        return null;
      }

      const items = [];
      const isCreating = !this.hasLogs && !this.status;

      // First item: Session creation status
      items.push({
        id: isCreating ? 'creating-session' : 'created-session',
        icon: isCreating ? 'status_running' : 'status_success',
        text: isCreating
          ? s__('DuoAgentPlatform|Creating session')
          : s__('DuoAgentPlatform|Created session'),
        content: isCreating ? s__('DuoAgentPlatform|Takes a few seconds...') : null,
        showUser: !isCreating,
        variant: 'subtle',
        timestamp: this.createdAt,
      });

      // Second item: Job or failure status
      if (!this.hasLogs && this.status) {
        items.push({
          id: this.isFailed ? 'session-failed' : 'starting-job',
          icon: this.isFailed ? 'status_failed' : 'status_running',
          text: this.isFailed
            ? s__('DuoAgentPlatform|Session failed')
            : s__('DuoAgentPlatform|Starting job'),
          content: !this.isFailed ? s__('DuoAgentPlatform|Takes a few minutes...') : null,
          variant: this.isFailed ? 'danger' : 'subtle',
          timestamp: this.isFailed ? this.updatedAt : this.createdAt,
        });
      }

      return items;
    },
    retentionMessage() {
      return s__(
        'DuoAgentPlatform|Activity deleted after 30 days of inactivity. %{linkStart}Learn more.%{linkEnd}',
      );
    },
    showRetentionMessage() {
      return !this.isWithinRetention && !this.hasLogs;
    },
  },
  sessionRetentionPath: helpPagePath('user/duo_agent_platform/sessions/_index', {
    anchor: '#session-retention',
  }),
};
</script>

<template>
  <div
    v-if="showRetentionMessage"
    class="gl-p-4 gl-text-center"
    data-testid="retention-message-container"
  >
    <gl-sprintf :message="retentionMessage">
      <template #link="{ content }">
        <gl-link :href="$options.sessionRetentionPath" target="_blank">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
  </div>

  <ul v-else class="gl-list-none gl-p-0">
    <li v-for="item in emptyStateItems" :key="item.id" class="gl-mb-5 gl-flex gl-items-start">
      <div class="gl-relative gl-mr-4 gl-flex gl-flex-col gl-items-center">
        <div class="gl-border gl-rounded-full gl-bg-strong gl-p-2">
          <gl-icon :name="item.icon" :variant="item.variant" />
        </div>
      </div>

      <div class="gl-flex-1 gl-pt-2">
        <div class="gl-mb-2 gl-flex gl-justify-between">
          <strong class="gl-text-strong" data-testid="log-entry-title">{{ item.text }}</strong>
          <time-ago-tooltip
            :time="item.timestamp"
            css-class="gl-text-subtle"
            data-testid="log-entry-timestamp"
          />
        </div>

        <span v-if="item.showUser" data-testid="triggered-user-container">
          {{ __('by') }}
          <agent-flow-triggered-user class="gl-link" :is-loading="isLoading" :user-id="userId" />
        </span>
        <span v-if="item.content">{{ item.content }}</span>
      </div>
    </li>
  </ul>
</template>
