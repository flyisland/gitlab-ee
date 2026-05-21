<script>
import AgentFlowSessionMessage from './agent_flow_session_message.vue';

export default {
  name: 'AgentFlowFailedState',
  components: {
    AgentFlowSessionMessage,
  },
  props: {
    updatedAt: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <agent-flow-session-message
    icon="status_failed"
    icon-variant="danger"
    :title="s__('DuoAgentPlatform|Session failed')"
    :timestamp="updatedAt"
    data-testid="agent-flow-failed-state"
  />
</template>
