<script>
import { InputRequestedMessage } from '@gitlab/duo-ui';
import AgentFlowUserApproval from './agent_flow_user_approval.vue';

export default {
  name: 'MessageApprovalRequest',
  components: {
    InputRequestedMessage,
    AgentFlowUserApproval,
  },
  inject: {
    canResumeWorkflow: {
      default: false,
    },
    canUpdateWorkflow: {
      default: false,
    },
  },
  props: {
    message: {
      required: true,
      type: Object,
    },
  },
  computed: {
    showApproval() {
      return this.canResumeWorkflow && this.canUpdateWorkflow && this.message.isLastMessage;
    },
  },
};
</script>
<template>
  <div>
    <input-requested-message :message="message" v-on="$listeners" />
    <agent-flow-user-approval v-if="showApproval" class="gl-mt-3" />
  </div>
</template>
