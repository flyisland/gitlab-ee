<script>
import { GlAlert, GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { AGENTS_PLATFORM_SHOW_ROUTE } from '../../router/constants';

export default {
  name: 'ProjectContextOnboardingPage',
  components: {
    GlAlert,
    GlButton,
    GlLink,
    GlSprintf,
    PageHeading,
  },
  data() {
    return {
      hasAgentsMd: Boolean(window.gon?.has_agents_md),
      initializeContextPath: window.gon?.initialize_context_path,
      isInitializing: false,
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
    isAlreadyInitialized() {
      return this.hasAgentsMd && !this.workflowId;
    },
    hasConflictWithoutWorkflow() {
      return Boolean(this.conflictMessage) && !this.workflowId;
    },
    hasConflictWithWorkflow() {
      return Boolean(this.conflictMessage) && Boolean(this.workflowId);
    },
    showInitializeButton() {
      return !this.hasAgentsMd && !this.workflowId && !this.conflictMessage;
    },
  },
  methods: {
    async initializeProjectContext() {
      this.isInitializing = true;
      this.conflictMessage = null;

      try {
        if (!this.initializeContextPath) {
          throw new Error(s__('DuoAgentsPlatform|Initialize context path not configured.'));
        }
        const { data } = await axios.post(this.initializeContextPath);

        this.workflowId = data?.workflow_id;
      } catch (error) {
        const status = error.response?.status;
        const message = error.response?.data?.message;

        if (status === 409) {
          this.conflictMessage = message;
          this.workflowId = error.response?.data?.workflow_id || null;
          return;
        }

        createAlert({
          message:
            message ||
            s__('DuoAgentsPlatform|Something went wrong while initializing project context.'),
          captureError: true,
          error,
        });
      } finally {
        this.isInitializing = false;
      }
    },
  },
};
</script>
<template>
  <div>
    <page-heading>
      <template #heading>
        {{ s__('DuoAgentsPlatform|Set up your project for Duo Agent Platform') }}
      </template>
      <template #description>
        {{
          s__(
            'DuoAgentsPlatform|Initialize your project context to help Duo Agent Platform understand your codebase. This creates an AGENTS.md file, sub-AGENTS.md files for key directories, and skill and rule stubs in a new merge request.',
          )
        }}
      </template>
    </page-heading>

    <gl-alert
      v-if="isAlreadyInitialized"
      variant="success"
      :dismissible="false"
      data-testid="agents-md-present-alert"
    >
      {{ s__('DuoAgentsPlatform|Project context has already been initialized.') }}
    </gl-alert>

    <gl-alert
      v-if="hasConflictWithoutWorkflow"
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
      <gl-sprintf
        :message="
          s__(
            'DuoAgentsPlatform|Workflow started. %{linkStart}View the agent session%{linkEnd} to track progress.',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="agentSessionUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <gl-alert
      v-if="hasConflictWithWorkflow"
      variant="info"
      :dismissible="false"
      data-testid="conflict-in-progress-alert"
    >
      <gl-sprintf
        :message="
          s__(
            'DuoAgentsPlatform|%{message} %{linkStart}View the agent session%{linkEnd} to track progress.',
          )
        "
      >
        <template #message>{{ conflictMessage }}</template>
        <template #link="{ content }">
          <gl-link :href="agentSessionUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <gl-button
      v-if="showInitializeButton"
      variant="confirm"
      :loading="isInitializing"
      :disabled="isInitializing"
      data-testid="initialize-project-context-button"
      @click="initializeProjectContext"
    >
      {{ s__('DuoAgentsPlatform|Initialize project context') }}
    </gl-button>
  </div>
</template>
