<script>
import { GlAlert, GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import PageHeading from '~/vue_shared/components/page_heading.vue';
import { AGENTS_PLATFORM_SHOW_ROUTE } from '../../router/constants';
import OnboardingAction from './components/onboarding_action.vue';

export default {
  name: 'ProjectContextOnboardingPage',
  components: {
    GlAlert,
    GlButton,
    GlLink,
    GlSprintf,
    OnboardingAction,
    PageHeading,
  },
  data() {
    const inProgressWorkflowId = window.gon?.in_progress_onboarding_workflow_id;
    return {
      projectContextInitialized: Boolean(window.gon?.project_context_initialized),
      hasGitlabCiYml: Boolean(window.gon?.has_gitlab_ci_yml),
      hasAgentConfig: Boolean(window.gon?.has_agent_config),
      hasMrReviewInstructions: Boolean(window.gon?.has_mr_review_instructions),
      initializeContextPath: window.gon?.initialize_context_path,
      finishedWorkflowId: window.gon?.finished_onboarding_workflow_id,
      isInitializing: false,
      workflowId: inProgressWorkflowId,
      conflictMessage: inProgressWorkflowId ? window.gon?.in_progress_onboarding_message : null,
    };
  },
  computed: {
    agentSessionUrl() {
      const sessionWorkflowId = this.workflowId || this.finishedWorkflowId;
      if (!sessionWorkflowId) return null;
      const { href } = this.$router.resolve({
        name: AGENTS_PLATFORM_SHOW_ROUTE,
        params: { id: sessionWorkflowId },
      });
      return href;
    },
    isAlreadyInitialized() {
      return this.projectContextInitialized && !this.workflowId;
    },
    hasConflictWithoutWorkflow() {
      return Boolean(this.conflictMessage) && !this.workflowId;
    },
    hasConflictWithWorkflow() {
      return Boolean(this.conflictMessage) && Boolean(this.workflowId);
    },
    showInitializeButton() {
      return !this.projectContextInitialized && !this.workflowId && !this.conflictMessage;
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
  i18n: {
    improveCiButton: s__('DuoAgentsPlatform|Improve CI setup'),
    improveCiFallbackError: s__(
      'DuoAgentsPlatform|Something went wrong while starting the CI improvement workflow.',
    ),
    noGitlabCiYmlAlert: s__(
      'DuoAgentsPlatform|No .gitlab-ci.yml found on the default branch. Add a CI configuration file to use this feature.',
    ),
    initializeExecutionEnvButton: s__('DuoAgentsPlatform|Initialize execution environment'),
    initializeExecutionEnvFallbackError: s__(
      'DuoAgentsPlatform|Something went wrong while initializing the execution environment.',
    ),
    agentConfigPresentAlert: s__(
      'DuoAgentsPlatform|Execution environment has already been initialized.',
    ),
    initializeMrReviewInstructionsButton: s__(
      'DuoAgentsPlatform|Initialize code review instructions',
    ),
    initializeMrReviewInstructionsFallbackError: s__(
      'DuoAgentsPlatform|Something went wrong while initializing code review instructions.',
    ),
    mrReviewInstructionsPresentAlert: s__(
      'DuoAgentsPlatform|Code review instructions have already been initialized.',
    ),
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
      data-testid="project-context-initialized-alert"
    >
      <gl-sprintf
        v-if="finishedWorkflowId"
        :message="
          s__(
            'DuoAgentsPlatform|Project context has already been initialized. %{linkStart}View the agent session%{linkEnd} to find the merge request.',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="agentSessionUrl">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
      <template v-else>
        {{ s__('DuoAgentsPlatform|Project context has already been initialized.') }}
      </template>
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
      v-if="workflowId && !conflictMessage"
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

    <div class="gl-mt-6">
      <h2 class="gl-heading-2">{{ s__('DuoAgentsPlatform|Improve CI setup') }}</h2>
      <p>
        {{
          s__(
            'DuoAgentsPlatform|Analyze your .gitlab-ci.yml and get actionable improvement suggestions in a new draft merge request.',
          )
        }}
      </p>

      <onboarding-action
        gon-path-key="improve_ci_path"
        :fallback-error-message="$options.i18n.improveCiFallbackError"
        :button-label="$options.i18n.improveCiButton"
        :action-disabled="!hasGitlabCiYml"
        data-testid="improve-ci-action"
      >
        <template #prerequisite-alerts>
          <gl-alert
            v-if="!hasGitlabCiYml"
            variant="warning"
            :dismissible="false"
            data-testid="no-gitlab-ci-yml-alert"
          >
            {{ $options.i18n.noGitlabCiYmlAlert }}
          </gl-alert>
        </template>
      </onboarding-action>
    </div>

    <div class="gl-mt-6">
      <h2 class="gl-heading-2">
        {{ $options.i18n.initializeExecutionEnvButton }}
      </h2>
      <p>
        {{
          s__(
            'DuoAgentsPlatform|Creates a .gitlab/duo/agent-config.yml file so CI-launched Duo Agent Platform flows run in a container that matches your project tech stack.',
          )
        }}
      </p>

      <onboarding-action
        gon-path-key="initialize_execution_env_path"
        :fallback-error-message="$options.i18n.initializeExecutionEnvFallbackError"
        :button-label="$options.i18n.initializeExecutionEnvButton"
        :action-disabled="hasAgentConfig"
        data-testid="initialize-execution-env-action"
      >
        <template #prerequisite-alerts>
          <gl-alert
            v-if="hasAgentConfig"
            variant="success"
            :dismissible="false"
            data-testid="agent-config-present-alert"
          >
            {{ $options.i18n.agentConfigPresentAlert }}
          </gl-alert>
        </template>
      </onboarding-action>
    </div>

    <div class="gl-mt-6">
      <h2 class="gl-heading-2">
        {{ $options.i18n.initializeMrReviewInstructionsButton }}
      </h2>
      <p>
        {{
          s__(
            'DuoAgentsPlatform|Creates a .gitlab/duo/mr-review-instructions.yaml file so the Code Review Flow applies review standards tailored to your project languages and conventions.',
          )
        }}
      </p>

      <onboarding-action
        gon-path-key="initialize_mr_review_instructions_path"
        :fallback-error-message="$options.i18n.initializeMrReviewInstructionsFallbackError"
        :button-label="$options.i18n.initializeMrReviewInstructionsButton"
        :action-disabled="hasMrReviewInstructions"
        data-testid="initialize-mr-review-instructions-action"
      >
        <template #prerequisite-alerts>
          <gl-alert
            v-if="hasMrReviewInstructions"
            variant="success"
            :dismissible="false"
            data-testid="mr-review-instructions-present-alert"
          >
            {{ $options.i18n.mrReviewInstructionsPresentAlert }}
          </gl-alert>
        </template>
      </onboarding-action>
    </div>
  </div>
</template>
