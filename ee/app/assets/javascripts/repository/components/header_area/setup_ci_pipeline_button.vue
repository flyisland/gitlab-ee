<script>
import { GlButton } from '@gitlab/ui';
import { sendDuoChatCommand } from 'ee/ai/utils';
import { s__ } from '~/locale';

const DEFAULT_AGENT_ID = 'gid://gitlab/Ai::FoundationalChatAgent/ci_expert_agent-v1';
export default {
  name: 'SetupCiPipelineButton',
  components: {
    GlButton,
  },
  inject: ['resourceId'],
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
    },
  },
};
</script>
<template>
  <gl-button class="gl-hidden @md/panel:gl-flex @md/panel:gl-w-auto" @click="callDuo">
    {{ __('Set up a CI/CD pipeline') }}
  </gl-button>
</template>
