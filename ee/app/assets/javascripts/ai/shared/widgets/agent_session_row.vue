<script>
import {
  GlAvatar,
  GlAvatarLink,
  GlButton,
  GlLink,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { projectAutomateAgentSessionPath } from 'ee/lib/utils/path_helpers/project';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import getUserQuery from './graphql/get_user.query.graphql';
import { SESSION_STATUSES_AWAITING_INPUT } from './agent_session_constants';

export default {
  name: 'AgentSessionRow',
  components: {
    AgentStatusIcon,
    GlAvatar,
    GlAvatarLink,
    GlButton,
    GlLink,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    session: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      user: null,
    };
  },
  apollo: {
    user: {
      query: getUserQuery,
      variables() {
        return { id: this.session.userId };
      },
      skip() {
        return !this.session.userId;
      },
      update(data) {
        return data.user;
      },
    },
  },
  computed: {
    numericId() {
      return getIdFromGraphQLId(this.session.id);
    },
    sessionUrl() {
      const fullPath = this.session.project?.fullPath;
      return fullPath ? projectAutomateAgentSessionPath(fullPath, this.numericId) : null;
    },
    formattedDefinition() {
      return formatAgentDefinition(this.session.workflowDefinition);
    },
    isAwaitingInput() {
      return SESSION_STATUSES_AWAITING_INPUT.includes(this.session.status);
    },
    displayLabel() {
      if (this.isAwaitingInput) {
        return s__('DuoAgentPlatform|Awaiting your input');
      }
      return this.session.humanStatus;
    },
    numericUserId() {
      return this.session.userId ? getIdFromGraphQLId(this.session.userId) : null;
    },
  },
};
</script>

<template>
  <div
    class="gl-border-t gl-flex gl-items-center gl-justify-between gl-border-t-section gl-px-5 gl-py-4 first:gl-border-t-0"
    data-testid="agent-session-row"
  >
    <div class="gl-flex gl-items-center gl-gap-2">
      <agent-status-icon
        :status="session.status"
        :human-status="session.humanStatus"
        class="gl-mr-2"
      />
      <span class="gl-text-subtle" data-testid="session-title">
        {{ s__('DuoAgentPlatform|Session') }}
      </span>
      <gl-link
        v-if="sessionUrl"
        :href="sessionUrl"
        target="_blank"
        class="gl-font-bold"
        data-testid="session-id"
        >#{{ numericId }}</gl-link
      >
      <span v-else class="gl-text-subtle" data-testid="session-id">#{{ numericId }}</span>
      <span class="gl-lowercase gl-text-subtle" data-testid="session-definition">
        {{ formattedDefinition }}
      </span>
      <span class="gl-font-bold gl-lowercase" data-testid="session-display-label">
        {{ displayLabel }}
      </span>
    </div>
    <div class="gl-flex gl-items-center gl-gap-3">
      <gl-button
        v-if="sessionUrl && isAwaitingInput"
        :href="sessionUrl"
        target="_blank"
        size="small"
        variant="confirm"
        category="tertiary"
        data-testid="session-cta-button"
      >
        {{ s__('DuoAgentPlatform|View details') }}
      </gl-button>
      <template v-if="session.userId">
        <gl-skeleton-loader v-if="$apollo.queries.user.loading" :lines="1" :width="16" />
        <gl-avatar-link
          v-else-if="user"
          v-gl-tooltip.bottom
          :href="user.webPath"
          :title="user.name"
          :data-user-id="numericUserId"
          :data-username="user.username"
          class="js-user-link"
          data-testid="session-triggered-user"
        >
          <gl-avatar
            :src="user.avatarUrl"
            :entity-name="user.name"
            :alt="user.name"
            :size="16"
            shape="circle"
          />
        </gl-avatar-link>
      </template>
    </div>
  </div>
</template>
