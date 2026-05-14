<script>
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import { TYPENAME_AI_DUO_WORKFLOW } from '~/graphql_shared/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import { getAgentFlow } from 'ee/ai/duo_agents_platform/graphql/queries/get_agent_flow.query.graphql';
import { DUO_AGENTS_PLATFORM_POLLING_INTERVAL } from 'ee/ai/duo_agents_platform/constants';
import {
  formatAgentDefinition,
  formatAgentStatus,
  formatAgentFlowName,
} from 'ee/ai/duo_agents_platform/utils';
import { setAgentSessionStatus, setPanelTitle, setPanelSubtitle } from 'ee/ai/graphql';
import AgentFlowDetails from './components/agent_flow_details.vue';
import AgentFlowCancelationModal from './components/agent_flow_cancelation_modal.vue';

export default {
  name: 'DuoAgentsPlatformShow',
  components: {
    AgentFlowDetails,
    AgentFlowCancelationModal,
  },
  inject: {
    isFlyout: { default: false },
    isSidePanelView: { default: false },
  },
  data() {
    return {
      agentFlow: null,
      showCancelConfirmation: false,
      isCancelling: false,
    };
  },
  apollo: {
    agentFlow: {
      query: getAgentFlow,
      pollInterval: DUO_AGENTS_PLATFORM_POLLING_INTERVAL,
      variables() {
        return {
          workflowId: convertToGraphQLId(TYPENAME_AI_DUO_WORKFLOW, this.$route.params.id),
        };
      },
      update(data) {
        return data?.duoWorkflowWorkflows?.edges?.[0]?.node || {};
      },
      result() {
        if (this.isSidePanelView) {
          setAgentSessionStatus(this.agentFlow?.status);
          setPanelTitle(this.agentFlow?.project?.name);
          setPanelSubtitle(
            formatAgentFlowName(this.agentFlow?.workflowDefinition, this.$route?.params?.id),
          );
        }
      },
      error(err) {
        createAlert({
          message:
            err?.message ||
            s__('DuoAgentsPlatform|Something went wrong while fetching Agent Flows'),
          captureError: true,
        });
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.agentFlow.loading;
    },
    agentFlowDetailsProps() {
      return {
        isLoading: this.isLoading,
        status: this.agentFlow?.status || '',
        humanStatus: formatAgentStatus(this.agentFlow?.humanStatus),
        agentFlowDefinition: formatAgentDefinition(this.agentFlow?.workflowDefinition),
        duoMessages: this.agentFlow?.latestCheckpoint?.duoMessages || [],
        executorUrl: this.agentFlow?.lastExecutorLogsUrl || '',
        createdAt: this.agentFlow?.createdAt || '',
        updatedAt: this.agentFlow?.updatedAt || '',
        project: this.agentFlow?.project || {},
        userId: this.agentFlow?.userId || '',
        workflowId: this.$route.params.id?.toString() || '',
        canUpdateWorkflow: this.agentFlow?.userPermissions?.updateDuoWorkflow || false,
      };
    },
  },
  methods: {
    async confirmCancelSession() {
      this.isCancelling = true;
      this.showCancelConfirmation = false;

      try {
        await this.cancelSessionAPI();

        createAlert({
          message: s__('DuoAgentsPlatform|Session has been cancelled successfully.'),
          variant: 'success',
        });
      } catch (error) {
        const errorMessage =
          error.response?.data?.message ||
          s__('DuoAgentsPlatform|Failed to cancel session. Please try again.');

        createAlert({
          message: errorMessage,
          captureError: true,
          variant: 'danger',
        });
      } finally {
        this.isCancelling = false;
      }
    },
    async cancelSessionAPI() {
      const workflowId = this.$route.params.id;
      const url = `/api/v4/ai/duo_workflows/workflows/${workflowId}`;

      await axios.patch(url, {
        status_event: 'stop',
      });
    },
  },
};
</script>
<template>
  <div>
    <agent-flow-details
      :class="isFlyout ? 'gl-mx-3' : ''"
      v-bind="agentFlowDetailsProps"
      @cancel-session="showCancelConfirmation = true"
    />

    <agent-flow-cancelation-modal
      :visible="showCancelConfirmation"
      :loading="isCancelling"
      @hide="showCancelConfirmation = false"
      @confirm="confirmCancelSession"
    />
  </div>
</template>
