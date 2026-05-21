<script>
import { GlSkeletonLoader } from '@gitlab/ui';
import emptyJobPendingSvg from '@gitlab/svgs/dist/illustrations/empty-state/empty-job-pending-md.svg?url';
import { s__ } from '~/locale';
import { getMessageData } from 'ee/ai/duo_agents_platform/utils';
import { AGENT_PLATFORM_STATUS_FAILED } from 'ee/ai/duo_agents_platform/constants';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowFailedState from 'ee/ai/duo_agents_platform/components/common/agent_flow_failed_state.vue';

export default {
  components: {
    ActivityLogs,
    GlSkeletonLoader,
    AgentFlowEmptyState,
    AgentFlowFailedState,
  },
  props: {
    createdAt: {
      type: String,
      required: true,
    },
    duoMessages: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
    status: {
      required: true,
      type: String,
    },
    updatedAt: {
      type: String,
      required: true,
    },
    userId: {
      type: String,
      required: true,
    },
    canResumeWorkflow: {
      type: Boolean,
      required: true,
    },
    canUpdateWorkflow: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      selectedFilter: 'verbose',
    };
  },
  computed: {
    hasLogs() {
      return this.duoMessages && this.duoMessages.length > 0;
    },
    filteredLogs() {
      if (this.selectedFilter === 'important') {
        return this.duoMessages.filter((item, index) => {
          // Always include the first item (start message)
          // https://gitlab.com/gitlab-org/gitlab/-/issues/562418
          if (index === 0) {
            return true;
          }

          const messageData = getMessageData(item);
          return messageData && messageData.level && messageData.level > 0;
        });
      }
      return this.duoMessages;
    },
    hasFailed() {
      return this.status === AGENT_PLATFORM_STATUS_FAILED;
    },
  },
  emptyJobPendingSvg,
  filterOptions: [
    {
      value: 'verbose',
      text: s__('DuoAgentsPlatform|Full view'),
    },
    {
      value: 'important',
      text: s__('DuoAgentsPlatform|Concise view'),
    },
  ],
};
</script>
<template>
  <div class="gl-h-full">
    <div class="gl-relative gl-flex gl-flex-col gl-overflow-x-hidden gl-px-4 gl-pt-6">
      <div>
        <template v-if="isLoading">
          <gl-skeleton-loader class="gl-ml-4" />
          <gl-skeleton-loader class="gl-ml-4 gl-mt-4" />
        </template>
        <template v-else>
          <agent-flow-empty-state
            :created-at="createdAt"
            :is-loading="isLoading"
            :has-logs="hasLogs"
            :updated-at="updatedAt"
            :status="status"
            :user-id="userId"
          />
          <template v-if="hasLogs">
            <activity-logs
              :items="filteredLogs"
              :can-resume-workflow="canResumeWorkflow"
              :can-update-workflow="canUpdateWorkflow"
            />
            <agent-flow-failed-state v-if="hasFailed" :updated-at="updatedAt" />
          </template>
        </template>
      </div>
    </div>
  </div>
</template>
