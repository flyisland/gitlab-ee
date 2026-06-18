<script>
import { GlAlert, GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { AGENTS_PLATFORM_SHOW_ROUTE } from '../../../router/constants';

export default {
  name: 'OnboardingAction',
  components: {
    GlAlert,
    GlButton,
    GlLink,
    GlSprintf,
  },
  props: {
    gonPathKey: {
      type: String,
      required: true,
    },
    fallbackErrorMessage: {
      type: String,
      required: true,
    },
    buttonLabel: {
      type: String,
      required: true,
    },
    actionDisabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['workflow-started'],
  data() {
    return {
      actionPath: window.gon?.[this.gonPathKey],
      isRunning: false,
      workflowId: null,
      conflictMessage: null,
    };
  },
  computed: {
    agentSessionUrl() {
      if (!this.workflowId) return null;
      const { href } = this.$router.resolve({
        name: AGENTS_PLATFORM_SHOW_ROUTE,
        params: { id: this.workflowId },
      });
      return href;
    },
    showActionButton() {
      return !this.actionDisabled && !this.workflowId && !this.conflictMessage;
    },
  },
  methods: {
    async runAction() {
      this.isRunning = true;
      this.conflictMessage = null;

      try {
        if (!this.actionPath) {
          throw new Error(this.fallbackErrorMessage);
        }
        const { data } = await axios.post(this.actionPath);

        this.workflowId = data?.workflow_id;
        this.$emit('workflow-started', { workflowId: this.workflowId });
      } catch (error) {
        const status = error.response?.status;
        const message = error.response?.data?.message;

        if (status === 409) {
          this.conflictMessage = message;
          this.workflowId = error.response?.data?.workflow_id || null;
          return;
        }

        createAlert({
          message: message || this.fallbackErrorMessage,
          captureError: true,
          error,
        });
      } finally {
        this.isRunning = false;
      }
    },
  },
  i18n: {
    workflowStartedAlert: s__(
      'DuoAgentsPlatform|Workflow started. %{linkStart}View the agent session%{linkEnd} to track progress.',
    ),
    conflictInProgressAlert: s__(
      'DuoAgentsPlatform|%{message} %{linkStart}View the agent session%{linkEnd} to track progress.',
    ),
  },
};
</script>
<template>
  <div>
    <slot name="prerequisite-alerts"></slot>

    <gl-alert
      v-if="conflictMessage && !workflowId"
      variant="warning"
      :dismissible="false"
      data-testid="conflict-alert"
    >
      {{ conflictMessage }}
    </gl-alert>

    <gl-alert
      v-if="workflowId"
      variant="info"
      :dismissible="false"
      data-testid="workflow-started-alert"
    >
      <gl-sprintf :message="$options.i18n.workflowStartedAlert">
        <template #link="{ content }">
          <gl-link :href="agentSessionUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <gl-alert
      v-if="conflictMessage && workflowId"
      variant="info"
      :dismissible="false"
      data-testid="conflict-in-progress-alert"
    >
      <gl-sprintf :message="$options.i18n.conflictInProgressAlert">
        <template #message>{{ conflictMessage }}</template>
        <template #link="{ content }">
          <gl-link :href="agentSessionUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <gl-button
      v-if="showActionButton"
      variant="confirm"
      :loading="isRunning"
      :disabled="isRunning"
      data-testid="action-button"
      @click="runAction"
    >
      {{ buttonLabel }}
    </gl-button>
  </div>
</template>
