<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import { DOCS_URL } from '~/constants';
import { s__ } from '~/locale';

const docsPath = `${DOCS_URL}/orbit/`;

export default defineComponent({
  name: 'ExplorerHeroBanner',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
  },
  resourceLinks: [
    { text: s__('Orbit|CLI'), href: `${DOCS_URL}/orbit/cli/` },
    { text: s__('Orbit|REST API'), href: `${DOCS_URL}/api/orbit/` },
    { text: s__('Orbit|MCP'), href: `${DOCS_URL}/orbit/mcp/` },
    { text: s__('Orbit|Docs'), href: docsPath },
  ],
  props: {
    logoSrc: {
      type: String,
      required: true,
    },
  },
  emits: ['dismiss'],
});
</script>

<template>
  <div
    class="explorer-hero-banner gl-mb-5 gl-rounded-lg gl-border-1 gl-border-solid gl-p-6"
    data-testid="explorer-hero-banner"
  >
    <div class="gl-flex gl-items-start gl-gap-5">
      <img :src="logoSrc" :alt="''" class="gl-h-8 gl-w-auto" />
      <div class="gl-flex-1">
        <h2 class="gl-text-2xl gl-mb-1 gl-mt-0 gl-font-semibold" data-testid="banner-title">
          {{ s__('Orbit|Get started with Orbit') }}
        </h2>
        <p class="gl-mb-3 gl-mt-0 gl-text-subtle" data-testid="banner-subtitle">
          {{ s__('Orbit|Ask your GitLab anything') }}
        </p>
        <div class="gl-flex gl-items-center gl-gap-3">
          <span class="gl-text-sm gl-text-subtle">{{ s__('Orbit|Resources') }}</span>
          <gl-button
            v-for="link in $options.resourceLinks"
            :key="link.text"
            size="small"
            variant="link"
            :href="link.href"
          >
            {{ link.text }}
          </gl-button>
        </div>
      </div>
      <gl-button
        icon="close"
        :aria-label="s__('Orbit|Dismiss')"
        size="small"
        category="tertiary"
        data-testid="dismiss-banner-btn"
        @click="$emit('dismiss')"
      />
    </div>
  </div>
</template>
