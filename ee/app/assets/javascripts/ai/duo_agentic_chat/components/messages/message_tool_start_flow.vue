<script>
import { GlIcon, GlLink } from '@gitlab/ui';
import { capitalize, upperCase } from 'lodash-es';
import AgentStatusIcon from 'ee/ai/shared/widgets/agent_status_icon.vue';
import { captureException } from '~/sentry/sentry_browser_wrapper';
import getFlowStatusQuery from 'ee/ai/graphql/get_flow_status.query.graphql';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { TYPENAME_AI_DUO_WORKFLOW } from '~/graphql_shared/constants';
import { visitUrl } from '~/lib/utils/url_utility';
import { EventsTracker } from '../../tracking/events_tracker';

const POLL_INTERVAL = 10000;
const TERMINAL_STATUSES = ['FINISHED', 'FAILED', 'STOPPED'];

export default {
  name: 'MessageToolStartFlow',
  components: {
    AgentStatusIcon,
    GlIcon,
    GlLink,
  },
  apollo: {
    flowStatus: {
      query: getFlowStatusQuery,
      variables() {
        return { id: convertToGraphQLId(TYPENAME_AI_DUO_WORKFLOW, this.workflowId) };
      },
      skip() {
        return !this.workflowId || TERMINAL_STATUSES.includes(this.internalStatus);
      },
      pollInterval: POLL_INTERVAL,
      update(data) {
        return data.duoWorkflowWorkflows?.edges?.[0]?.node?.status ?? null;
      },
      error(error) {
        captureException(error, { tags: { feature_category: 'duo_chat' } });
      },
    },
  },
  props: {
    message: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      flowStatus: null,
    };
  },
  computed: {
    toolResponse() {
      try {
        return JSON.parse(this.message.tool_info?.tool_response?.content ?? '{}');
      } catch {
        return {};
      }
    },
    flowName() {
      return this.toolResponse.flow_name ?? '';
    },
    workflowId() {
      return this.toolResponse.workflow_id ?? null;
    },
    sessionUrl() {
      return this.toolResponse.session_url ?? null;
    },
    internalStatus() {
      return this.flowStatus ?? upperCase(this.toolResponse?.status);
    },
    humanStatus() {
      return capitalize(this.internalStatus) ?? '';
    },
    toolName() {
      return this.message.tool_info?.name ?? '';
    },
  },
  methods: {
    handleSessionUrlClick(event) {
      event.preventDefault();
      EventsTracker.trackClickThroughFlowWidget({ toolName: this.toolName });
      visitUrl(this.sessionUrl, true);
    },
  },
};
</script>

<template>
  <div
    class="gl-border gl-inline-flex !gl-w-fit gl-items-center gl-gap-2 gl-rounded-r-[1rem] gl-rounded-tl-[1rem] gl-border-default gl-bg-default gl-p-4"
    data-testid="start-flow-message"
  >
    <span aria-hidden="true">
      <agent-status-icon :status="internalStatus" :human-status="humanStatus" />
    </span>
    <span>
      {{ flowName }}
      <template v-if="workflowId">#{{ workflowId }}</template>
    </span>
    <gl-link
      v-if="sessionUrl"
      :href="sessionUrl"
      target="_blank"
      class="gl-inline-flex gl-items-center gl-gap-1"
      @click="handleSessionUrlClick"
    >
      <strong>{{ humanStatus }}</strong>
      <gl-icon name="arrow-right" aria-hidden="true" />
    </gl-link>
    <strong v-else>{{ humanStatus }}</strong>
  </div>
</template>
