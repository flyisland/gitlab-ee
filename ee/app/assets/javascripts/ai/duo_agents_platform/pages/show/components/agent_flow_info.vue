<script>
import {
  GlBadge,
  GlButton,
  GlLink,
  GlSkeletonLoader,
  GlTooltipDirective,
  GlIcon,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { getAgentStatusBadge } from 'ee/ai/duo_agents_platform/utils';
import { AGENT_PLATFORM_CANCELABLE_STATUSES } from 'ee/ai/duo_agents_platform/constants';
import { projectAutomateAgentSessionPath } from 'ee/lib/utils/path_helpers/project';
import AgentFlowTriggeredUser from '../../../components/common/agent_flow_triggered_user.vue';

export default {
  components: {
    GlBadge,
    GlButton,
    GlLink,
    GlSkeletonLoader,
    GlIcon,
    AgentFlowTriggeredUser,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isLoading: {
      required: true,
      type: Boolean,
    },
    status: {
      required: true,
      type: String,
    },
    humanStatus: {
      required: true,
      type: String,
    },
    agentFlowDefinition: {
      required: true,
      type: String,
    },
    executorUrl: {
      required: false,
      type: String,
      default: '',
    },
    createdAt: {
      type: String,
      required: false,
      default: '',
    },
    updatedAt: {
      type: String,
      required: false,
      default: '',
    },
    project: {
      type: Object,
      required: true,
    },
    userId: {
      required: true,
      type: String,
    },
    canUpdateWorkflow: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['cancel-session'],
  computed: {
    itemStatus() {
      return getAgentStatusBadge(this.status);
    },
    jobId() {
      const id = this.executorUrl.split('/').pop();
      if (!id || Number.isNaN(Number(id))) {
        return null;
      }
      return `#${id}`;
    },
    projectAgentSessionsUrl() {
      const sessionId = this.$route.params.id;
      const projectFullPath = this.project?.fullPath;

      return sessionId && projectFullPath
        ? projectAutomateAgentSessionPath(projectFullPath, sessionId)
        : '';
    },
    canCancelSession() {
      return AGENT_PLATFORM_CANCELABLE_STATUSES.includes(this.status);
    },
    buttonTooltip() {
      return this.canUpdateWorkflow
        ? ''
        : s__('DuoAgentsPlatform|You do not have permission to cancel this session.');
    },
    payload() {
      return [
        {
          key: s__('AI|AI Item'),
          value: this.agentFlowDefinition,
        },
        {
          key: s__('DuoAgentPlatform|Session ID'),
          value: `#${this.$route.params.id}`,
          link: this.projectAgentSessionsUrl,
        },
        {
          key: 'Type',
          value: s__('DuoAgentPlatform|Flow'),
        },
        {
          key: __('Project'),
          value: this.project?.name,
          link: this.project?.webUrl,
        },
        {
          key: __('Group'),
          value: this.project?.namespace?.name,
          link: this.project?.namespace?.webUrl,
        },
        {
          key: __('Triggered by'),
          value: null,
          isTriggeredUser: true,
        },
        {
          key: __('Status'),
          value: this.humanStatus,
          status: this.status,
        },
        {
          key: __('Started'),
          value: this.formatTimestamp(this.createdAt),
        },
        {
          key: __('Last updated'),
          value: this.formatTimestamp(this.updatedAt),
        },
        {
          key: s__('DuoAgentPlatform|Job ID'),
          value: this.jobId,
          link: this.executorUrl,
        },
      ].map((entry) => {
        return { ...entry, value: entry.value ? entry.value : __('N/A') };
      });
    },
  },
  methods: {
    formatTimestamp(isoString) {
      if (!isoString) {
        return __('N/A');
      }

      try {
        const date = new Date(isoString);
        if (Number.isNaN(date.getTime())) {
          return __('N/A');
        }
        return localeDateFormat.asDateTime.format(date);
      } catch (error) {
        return __('N/A');
      }
    },
  },
};
</script>
<template>
  <div>
    <div class="gl-ml-4">
      <span class="gl-mb-2 gl-flex gl-flex-row gl-items-center gl-pt-3">
        <gl-icon
          name="information-o"
          :aria-label="s__('DuoAgentPlatform|Session information')"
          :size="24"
          variant="disabled"
        />
        <div class="gl-ml-3 gl-font-bold" data-testid="session-info-heading">
          {{ s__('DuoAgentPlatform|Session information') }}
        </div>
      </span>
      <ul class="gl-list-none gl-p-0">
        <li v-for="entry in payload" :key="entry.key" class="gl-mb-2 gl-py-2">
          <span class="gl-mb-2 gl-text-subtle" data-testid="info-title">
            {{ sprintf(__('%{label}:'), { label: entry.key }) }}
          </span>
          <gl-skeleton-loader v-if="isLoading" :lines="1" />
          <template v-else>
            <agent-flow-triggered-user
              v-if="entry.isTriggeredUser"
              class="gl-link"
              :is-loading="isLoading"
              :user-id="userId"
            />
            <span v-else data-testid="info-value">
              <gl-link v-if="entry.link" :href="entry.link">{{ entry.value }}</gl-link>
              <gl-badge
                v-else-if="entry.key === 'Status'"
                class="gl-mr-3"
                :icon="itemStatus.icon"
                icon-size="sm"
                :variant="itemStatus.variant"
              >
                {{ entry.value }}
              </gl-badge>
              <template v-else>{{ entry.value }}</template>
            </span>
          </template>
        </li>
      </ul>
    </div>

    <div v-if="canCancelSession" class="gl-border-b gl-ml-4 gl-py-4">
      <div class="gl-flex gl-gap-3">
        <span v-gl-tooltip="buttonTooltip">
          <gl-button
            category="secondary"
            variant="danger"
            :disabled="!canUpdateWorkflow"
            data-testid="cancel-session-button"
            @click="$emit('cancel-session')"
          >
            {{ s__('DuoAgentsPlatform|Cancel session') }}
          </gl-button>
        </span>
      </div>
    </div>
  </div>
</template>
