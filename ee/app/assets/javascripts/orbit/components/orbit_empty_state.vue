<script>
import { defineComponent } from 'vue';
import { GlLink } from '@gitlab/ui';
import gitlabLogoSvg from '@gitlab/svgs/dist/illustrations/gitlab_logo.svg?url';
import { s__ } from '~/locale';
import { DOCS_URL } from '~/constants';

const i18n = {
  title: s__('Orbit|Get started with Orbit'),
  subhead: s__('Orbit|Your SDLC Context Graph'),
  description: s__(
    'Orbit|Orbit transforms your GitLab data into a structured knowledge graph you can query, explore, and integrate with AI tools.',
  ),
  learnMore: s__('Orbit|Learn more'),
};

export default defineComponent({
  name: 'OrbitEmptyState',
  compatConfig: { MODE: 3 },
  components: {
    GlLink,
  },
  i18n,
  learnMorePath: `${DOCS_URL}/orbit/`,
  logoSrc: gitlabLogoSvg,
});
</script>

<template>
  <div
    class="gl-flex gl-min-h-full gl-flex-1 gl-flex-col gl-justify-center gl-gap-5 gl-p-8"
    data-testid="orbit-empty-state"
  >
    <div class="gl-flex gl-items-center gl-gap-5">
      <img :src="$options.logoSrc" :alt="''" class="gl-h-8" />
      <h1 class="gl-text-4xl gl-mb-0 gl-mt-0 gl-font-semibold">
        {{ $options.i18n.title }}
      </h1>
    </div>
    <p class="gl-mb-0 gl-text-lg">
      {{ $options.i18n.subhead }}
    </p>
    <p class="gl-mb-0 gl-max-w-lg">
      {{ $options.i18n.description }}
      <gl-link :href="$options.learnMorePath">
        {{ $options.i18n.learnMore }}
      </gl-link>
    </p>
    <slot></slot>
  </div>
</template>
