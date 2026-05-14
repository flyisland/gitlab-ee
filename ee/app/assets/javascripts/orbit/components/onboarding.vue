<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import gitlabLogoSvg from '@gitlab/svgs/dist/illustrations/gitlab_logo.svg?url';
import { DOCS_URL } from '~/constants';

export default defineComponent({
  name: 'OrbitOnboarding',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
  },
  emits: ['enable'],
  computed: {
    learnMorePath() {
      return `${DOCS_URL}/orbit/`;
    },
    logoSrc() {
      return gitlabLogoSvg;
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-gap-5" data-testid="orbit-onboarding">
    <div class="orbit-onboarding-panel gl-flex-1 gl-rounded-lg gl-border-1 gl-border-solid gl-p-6">
      <div class="gl-flex gl-flex-col gl-gap-5">
        <img :src="logoSrc" :alt="''" class="gl-h-8 gl-w-auto gl-self-start" />
        <div>
          <h2 class="orbit-hero-heading gl-mb-0 gl-mt-0 gl-font-semibold">
            {{ s__('Orbit|Get started with Orbit') }}
          </h2>
          <p class="gl-text-2xl gl-mb-0 gl-font-normal">
            {{ s__('Orbit|Ask your GitLab anything') }}
          </p>
        </div>
        <p class="gl-text-2xl gl-mb-0 gl-font-normal">
          {{
            s__(
              'Orbit|Orbit is an SDLC analysis engine that transforms your GitLab into a structured knowledge graph.',
            )
          }}
        </p>
        <div class="gl-flex gl-gap-3">
          <gl-button variant="confirm" data-testid="enable-orbit-btn" @click="$emit('enable')">
            {{ s__('Orbit|Enable Orbit') }}
          </gl-button>
          <gl-button :href="learnMorePath" data-testid="learn-more-btn">
            {{ s__('Orbit|Learn more') }}
          </gl-button>
        </div>
      </div>
    </div>
    <div
      class="orbit-visual-placeholder gl-flex gl-flex-1 gl-items-center gl-justify-center gl-rounded-lg gl-bg-subtle"
    >
      <p class="orbit-hero-heading gl-mb-0 gl-font-semibold gl-text-default">
        {{ s__('Orbit|Marketing visual') }}
      </p>
    </div>
  </div>
</template>
