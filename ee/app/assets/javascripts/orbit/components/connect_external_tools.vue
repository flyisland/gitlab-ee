<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { s__ } from '~/locale';
import { buildApiUrl } from '~/api/api_utils';

const mcpEndpoint = `${window.location.origin}${buildApiUrl('/api/:version/orbit/mcp')}`;
// eslint-disable-next-line @gitlab/require-i18n-strings
const glabInstallCommand = 'glab orbit setup';

export default defineComponent({
  name: 'OrbitConnectExternalTools',
  compatConfig: { MODE: 3 },
  components: { GlButton, GlIcon, ClipboardButton },
  emits: ['quick-start'],
  mcpEndpoint,
  glabInstallCommand,
  i18n: {
    title: s__('Orbit|Use Orbit with your tools'),
    subhead: s__(
      'Orbit|Query Orbit directly, or power up your agents with GitLab context. Using Orbit outside of GitLab uses GitLab Credits.',
    ),
    cliLabel: s__('Orbit|CLI & API'),
    mcpLabel: s__('Orbit|MCP'),
    copyInstallCommand: s__('Orbit|Copy install command'),
    copyMcpEndpoint: s__('Orbit|Copy MCP endpoint'),
    quickStart: s__('Orbit|MCP quickstart'),
  },
});
</script>

<template>
  <div class="gl-flex gl-min-w-0 gl-flex-1 gl-flex-col" data-testid="connect-links">
    <div
      class="gl-border gl-flex gl-flex-1 gl-flex-col gl-gap-1 gl-rounded-lg gl-bg-default gl-p-5"
    >
      <h3 class="gl-heading-4 gl-mb-2 gl-flex gl-items-center gl-gap-3">
        <gl-icon name="connected" :size="16" />
        {{ $options.i18n.title }}
      </h3>
      <p class="gl-text-subtle">{{ $options.i18n.subhead }}</p>
      <div class="gl-flex gl-flex-col gl-gap-4">
        <div class="gl-flex gl-items-center gl-gap-3">
          <span class="gl-w-16 gl-shrink-0 gl-text-sm gl-font-semibold">
            {{ $options.i18n.cliLabel }}
          </span>
          <code class="gl-font-monospace gl-text-sm gl-text-default">
            {{ $options.glabInstallCommand }}
          </code>
          <clipboard-button
            :text="$options.glabInstallCommand"
            :title="$options.i18n.copyInstallCommand"
            size="small"
            category="tertiary"
          />
        </div>
        <div class="gl-flex gl-items-start gl-gap-3">
          <span class="gl-w-16 gl-shrink-0 gl-pt-1 gl-text-sm gl-font-semibold">
            {{ $options.i18n.mcpLabel }}
          </span>
          <span class="gl-min-w-0 gl-flex-1 gl-break-all">
            <code class="gl-text-sm gl-text-default">{{ $options.mcpEndpoint }}</code>
            <clipboard-button
              :text="$options.mcpEndpoint"
              :title="$options.i18n.copyMcpEndpoint"
              size="small"
              category="tertiary"
              class="gl-align-middle"
            />
          </span>
        </div>
        <div class="gl-mt-3 gl-flex gl-items-center gl-gap-2">
          <gl-button @click="$emit('quick-start')">
            {{ $options.i18n.quickStart }}
          </gl-button>
        </div>
      </div>
    </div>
  </div>
</template>
