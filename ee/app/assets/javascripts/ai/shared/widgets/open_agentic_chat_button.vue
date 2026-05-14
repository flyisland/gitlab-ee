<script>
import { GlButton } from '@gitlab/ui';
import { openDuoChatWithAgent } from 'ee/ai/utils';
import {
  duoAgenticChatEventHub,
  DUO_CHAT_TOOL_COMPLETED_EVENT,
} from 'ee/ai/duo_agentic_chat/events/event_hub';
import duoChatAvailableQuery from '../../graphql/duo_chat_available.query.graphql';

export default {
  name: 'OpenAgenticChatButton',
  components: {
    GlButton,
  },
  props: {
    buttonText: {
      type: String,
      required: true,
    },
    resourceId: {
      type: String,
      required: true,
    },
    agent: {
      type: Object,
      required: true,
    },
    welcomeMessage: {
      type: String,
      required: false,
      default: null,
    },
    predefinedPrompts: {
      type: Array,
      required: false,
      default: null,
    },
    buttonOptions: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  apollo: {
    duoChatAvailable: {
      query: duoChatAvailableQuery,
      update(data) {
        return data?.currentUser?.duoChatAvailable ?? false;
      },
      error() {
        this.duoChatAvailable = false;
      },
    },
  },
  emits: ['tool-completed'],
  data() {
    return {
      duoChatAvailable: false,
    };
  },
  mounted() {
    duoAgenticChatEventHub.$on(DUO_CHAT_TOOL_COMPLETED_EVENT, this.onToolCompleted);
  },
  beforeDestroy() {
    duoAgenticChatEventHub.$off(DUO_CHAT_TOOL_COMPLETED_EVENT, this.onToolCompleted);
  },
  methods: {
    onClick() {
      openDuoChatWithAgent({
        agent: this.agent,
        resourceId: this.resourceId,
        welcomeMessage: this.welcomeMessage,
        predefinedPrompts: this.predefinedPrompts,
      });
    },
    onToolCompleted(payload) {
      this.$emit('tool-completed', payload);
    },
  },
};
</script>
<template>
  <gl-button v-if="duoChatAvailable" icon="tanuki-ai" v-bind="buttonOptions" @click="onClick">{{
    buttonText
  }}</gl-button>
</template>
