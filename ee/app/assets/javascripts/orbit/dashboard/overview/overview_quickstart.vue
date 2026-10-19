<script>
import { defineComponent } from 'vue';
import { GlBadge, GlButton, GlIcon, GlLink } from '@gitlab/ui';
import { DUO_CHAT_AGENT_GITLAB_DUO } from 'ee/ai/constants';
import { openDuoChatWithAgent } from 'ee/ai/utils';
import { DOCS_URL } from '~/constants';
import { s__ } from '~/locale';
import { InternalEvents } from '~/tracking';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { ORBIT_CLI_SETUP_COMMAND } from './constants';
import QuickstartStep from './quickstart_step.vue';

export default defineComponent({
  name: 'OverviewQuickstart',
  compatConfig: { MODE: 3 },
  components: { GlBadge, GlButton, GlIcon, GlLink, ClipboardButton, QuickstartStep },
  mixins: [InternalEvents.mixin()],
  inject: ['preferencesPath'],
  props: {
    duoAccessible: {
      type: Boolean,
      required: true,
    },
    orbitSettingsEnabled: {
      type: Boolean,
      required: true,
    },
    indexing: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['close'],
  computed: {
    tryDuoText() {
      if (!this.duoAccessible) {
        return this.indexing
          ? s__(
              'Orbit|When indexing finishes, ask GitLab Duo a question that spans projects. GitLab Duo is not available for your groups.',
            )
          : s__(
              'Orbit|Ask GitLab Duo a question that spans projects. GitLab Duo is not available for your groups.',
            );
      }

      return this.indexing
        ? s__('Orbit|When indexing finishes, ask GitLab Duo a question that spans projects.')
        : s__('Orbit|Ask GitLab Duo a question that spans projects.');
    },
  },
  methods: {
    trackCliCopy() {
      this.trackEvent('click_orbit_copy_to_clipboard', { label: 'CLI' });
    },
    openDuoChat() {
      this.trackEvent('click_orbit_open_duo_chat');
      openDuoChatWithAgent({
        agent: { name: DUO_CHAT_AGENT_GITLAB_DUO },
        resourceId: 'orbit-quickstart',
      });
    },
  },
  cliCommand: ORBIT_CLI_SETUP_COMMAND,
  docsHref: `${DOCS_URL}/orbit/`,
});
</script>

<template>
  <section
    id="orbit-quickstart"
    class="gl-border gl-rounded-lg gl-border-default gl-bg-default gl-p-5"
    aria-labelledby="orbit-quickstart-title"
    data-testid="orbit-quickstart"
  >
    <div class="gl-flex gl-items-center gl-justify-between gl-gap-3">
      <h2 id="orbit-quickstart-title" class="gl-heading-3 gl-m-0">{{ s__('Orbit|Quickstart') }}</h2>
      <gl-button
        category="tertiary"
        size="small"
        icon="close"
        :aria-label="s__('Orbit|Close Quickstart')"
        data-testid="orbit-quickstart-close"
        @click="$emit('close')"
      />
    </div>

    <hr class="gl-my-4" />

    <ol
      class="orbit-quickstart-steps gl-m-0 gl-grid gl-list-none gl-grid-cols-1 gl-gap-5 gl-p-0 md:gl-grid-cols-3"
    >
      <quickstart-step
        :title="s__('Orbit|Turn on Orbit for GitLab Duo')"
        :description="
          s__('Orbit|GitLab Duo Chat and agents use Orbit to answer questions across projects.')
        "
      >
        <div v-if="duoAccessible" class="gl-flex gl-items-center gl-gap-3">
          <gl-badge v-if="orbitSettingsEnabled" variant="success" icon="status-success">
            {{ s__('Orbit|On') }}
          </gl-badge>
          <gl-link :href="preferencesPath" data-testid="orbit-quickstart-preferences">
            {{ s__('Orbit|Preferences') }}
          </gl-link>
        </div>
        <p v-else class="gl-m-0 gl-text-subtle" data-testid="orbit-quickstart-no-duo">
          {{ s__('Orbit|GitLab Duo is not available for your groups.') }}
        </p>
      </quickstart-step>

      <quickstart-step
        :title="s__('Orbit|Set up the Orbit CLI')"
        :description="
          s__(
            'Orbit|Connect your AI coding agents to Orbit and query Orbit from your terminal, with one command.',
          )
        "
      >
        <div
          class="gl-flex gl-items-center gl-justify-between gl-gap-2 gl-self-start gl-rounded-base gl-bg-strong gl-px-3 gl-py-2"
        >
          <code class="gl-bg-transparent gl-text-sm gl-text-default">{{
            $options.cliCommand
          }}</code>
          <clipboard-button
            :text="$options.cliCommand"
            :title="s__('Orbit|Copy command')"
            category="tertiary"
            size="small"
            @click="trackCliCopy"
          />
        </div>
        <gl-link :href="$options.docsHref" target="_blank" data-testid="orbit-quickstart-docs">
          {{ s__('Orbit|Documentation') }} <gl-icon name="external-link" :size="12" />
        </gl-link>
      </quickstart-step>

      <quickstart-step
        :title="s__('Orbit|Try Orbit in GitLab Duo')"
        :description="tryDuoText"
        data-testid="orbit-quickstart-try-duo"
      >
        <gl-button
          v-if="duoAccessible"
          class="gl-self-start"
          category="secondary"
          size="small"
          icon="tanuki-ai"
          data-testid="orbit-quickstart-ask-duo"
          @click="openDuoChat"
        >
          {{ s__('Orbit|Ask GitLab Duo') }}
        </gl-button>
      </quickstart-step>
    </ol>
  </section>
</template>
