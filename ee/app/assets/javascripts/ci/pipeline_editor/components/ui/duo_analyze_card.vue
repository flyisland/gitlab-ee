<script>
import { GlButton, GlCard } from '@gitlab/ui';
import TANUKI_AI_ILLUSTRATION from '@gitlab/svgs/dist/illustrations/tanuki-ai-sm.svg?url';
import { s__ } from '~/locale';
import { sendDuoChatCommand } from 'ee/ai/utils';

const DEFAULT_AGENT_ID = 'gid://gitlab/Ai::FoundationalChatAgent/ci_expert_agent-v1';

export default {
  name: 'DuoAnalyzeCard',
  components: {
    GlButton,
    GlCard,
  },
  inject: ['resourceId'],
  emits: ['create-empty-config-file'],
  tanukiAiIllustrationPath: TANUKI_AI_ILLUSTRATION,
  methods: {
    callDuo() {
      sendDuoChatCommand({
        // eslint-disable-next-line @gitlab/no-hardcoded-urls
        question: '/pipeline_authoring',
        resourceId: this.resourceId,
        agenticPrompt: s__(
          'Pipelines|Analyze this repository and create a CI/CD pipeline that meets the needs of the project.',
        ),
        agent: { id: DEFAULT_AGENT_ID },
      });

      this.$emit('create-empty-config-file');
    },
  },
};
</script>
<template>
  <gl-card
    class="ai-card gl-w-[250px] gl-max-w-[500px] gl-shadow-[0_4px_12px_var(--gl-color-alpha-dark-8),0_0_1px_var(--gl-color-alpha-dark-24)]"
    header-class="ai-card-header gl-border-bottom-none gl-pt-5 gl-pb-3"
    body-class="ai-card-body gl-flex gl-flex-col gl-items-center gl-justify-center gl-text-center gl-pt-0 gl-pb-6"
  >
    <template #header>
      <img
        :src="$options.tanukiAiIllustrationPath"
        class="tanuki-ai-icon"
        :alt="s__('Pipelines|Tanuki AI icon')"
        aria-hidden="true"
      />
      <span class="gl-block gl-text-center gl-font-bold">{{
        s__('Pipelines|AI-generated pipeline')
      }}</span>
    </template>
    <template #default>
      <p class="gl-h-11">
        {{
          s__(
            'Pipelines|Use GitLab Duo to analyze your repository and create a matching CI/CD pipeline.',
          )
        }}
      </p>
      <gl-button
        class="ai-card-button gl-mt-3 !gl-text-neutral-0"
        icon="tanuki-ai"
        data-testid="analyze-repository-button"
        @click="callDuo"
      >
        {{ s__('Pipelines|Analyze repository') }}
      </gl-button>
    </template>
  </gl-card>
</template>
<style scoped>
.ai-card {
  background-color: var(--gl-color-theme-indigo-50);
  border: 1px solid var(--gl-color-theme-indigo-500);
}

:deep(.ai-card-header) {
  background-color: var(--gl-color-theme-indigo-50);
  position: relative;
}

:deep(.ai-card-body) {
  background-color: var(--gl-color-theme-indigo-50) !important;
}

:deep(.tanuki-ai-icon) {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translate(-50%, -65%);
  width: 48px;
  height: 48px;
}

:deep(.ai-card-button) {
  background-color: var(--gl-color-theme-indigo-500) !important;
  border: 1px solid var(--gl-color-theme-indigo-700) !important;
}
</style>
