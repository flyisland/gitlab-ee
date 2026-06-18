<script>
import { GlSkeletonLoader } from '@gitlab/ui';
import {
  DuoChatContextConversation as DuoChatConversation,
  MESSAGE_MODEL_ROLES,
} from '@gitlab/duo-ui';
import emptyJobPendingSvg from '@gitlab/svgs/dist/illustrations/empty-state/empty-job-pending-md.svg?url';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { getMessageData } from 'ee/ai/duo_agents_platform/utils';
import { AGENT_PLATFORM_STATUS_FAILED } from 'ee/ai/duo_agents_platform/constants';
import { WorkflowUtils } from 'ee/ai/duo_agentic_chat/utils/workflow_utils';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowSessionMessage from 'ee/ai/duo_agents_platform/components/common/agent_flow_session_message.vue';
import MessageApprovalRequest from 'ee/ai/duo_agents_platform/components/common/message_approval_request.vue';

export default {
  name: 'AgentActivityLogs',
  components: {
    ActivityLogs,
    DuoChatConversation,
    GlSkeletonLoader,
    AgentFlowEmptyState,
    AgentFlowSessionMessage,
  },
  mixins: [glFeatureFlagsMixin()],
  provide() {
    return {
      markdownClass: 'md',
      canResumeWorkflow: this.canResumeWorkflow,
      canUpdateWorkflow: this.canUpdateWorkflow,
    };
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
    user: {
      type: Object,
      required: false,
      default: () => ({}),
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
    chatMessages() {
      if (!this.useChatBubbles || !this.hasLogs) {
        return [];
      }

      const normalized = WorkflowUtils.normalizeDuoMessages(this.duoMessages);
      const messages = WorkflowUtils.transformChatMessages(normalized).map((msg) => ({
        ...msg,
        // Keep original message_type as role instead of 'assistant' so messages
        // route through MessageMap (which uses our messageRenderers) rather than
        // the assistant-bubble path that shows copy buttons.
        role: msg.role === 'assistant' ? msg.message_type : msg.role,
      }));

      // Mark the last request message so the approval renderer knows to show buttons
      const lastRequest = messages.findLast(
        (msg) => msg.message_type === MESSAGE_MODEL_ROLES.request,
      );
      if (lastRequest) {
        lastRequest.isLastMessage = true;
      }

      return messages;
    },
    useChatBubbles() {
      return this.glFeatures.duoSessionChatBubbles;
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
  messageRenderers: [
    {
      component: MessageApprovalRequest,
      matchMessage: (message) => message.message_type === MESSAGE_MODEL_ROLES.request,
    },
  ],
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
    <div class="gl-relative gl-flex gl-flex-col gl-overflow-x-hidden gl-px-4 gl-py-6">
      <div>
        <template v-if="isLoading">
          <gl-skeleton-loader class="gl-ml-4" />
          <gl-skeleton-loader class="gl-ml-4 gl-mt-4" />
        </template>
        <template v-else>
          <agent-flow-empty-state
            :created-at="createdAt"
            :has-logs="hasLogs"
            :updated-at="updatedAt"
            :status="status"
            :user="user"
            :use-chat-bubbles="useChatBubbles"
          />
          <template v-if="hasLogs">
            <duo-chat-conversation
              v-if="useChatBubbles"
              :messages="chatMessages"
              :message-renderers="$options.messageRenderers"
              :show-delimiter="false"
              :with-feedback="false"
              :enable-code-insertion="false"
              data-testid="session-chat-bubbles"
            />
            <template v-else>
              <activity-logs
                :items="filteredLogs"
                :can-resume-workflow="canResumeWorkflow"
                :can-update-workflow="canUpdateWorkflow"
              />
              <!-- Only shown with logs; without logs, failed state is in AgentFlowEmptyState -->
              <agent-flow-session-message
                v-if="hasFailed"
                icon="status_failed"
                icon-variant="danger"
                :title="s__('DuoAgentPlatform|Session failed')"
                :timestamp="updatedAt"
                data-testid="agent-flow-failed-state"
              />
            </template>
          </template>
        </template>
      </div>
    </div>
  </div>
</template>
