<script>
import { defineComponent } from 'vue';
import { GlAvatar, GlButton, GlLink, GlModal } from '@gitlab/ui';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { s__, sprintf } from '~/locale';
import { groupSettingsOrbitPath } from 'ee/lib/utils/path_helpers/group';
import { groupGroupMembersPath } from '~/lib/utils/path_helpers/group';
import { copyToClipboard } from '~/lib/utils/copy_to_clipboard';
import OrbitEmptyState from './orbit_empty_state.vue';
import TurnOnIndexingModal from './turn_on_indexing_modal.vue';

const OWNER_ACCESS_LEVEL = 50;
const COPY_RESET_MS = 1500;

const i18n = {
  noGroups: s__('Orbit|Orbit requires a top-level group with at least a Premium license.'),
  getStarted: s__('Orbit|Get started'),
  availableGroups: s__('Orbit|Available groups'),
  nonOwnerDescription: s__(
    'Orbit|You must have the Owner role in a top-level group to turn on Orbit. Ask an owner to turn on Orbit.',
  ),
  viewOwners: s__('Orbit|View Owners'),
  setupGuide: s__('Orbit|Setup guide'),
  setupModalTitle: s__('Orbit|Setup Orbit'),
  setupRequirement: s__(
    'Orbit|Setting up Orbit requires an Owner role in a group with at least a Premium license.',
  ),
  ownerInstructions: s__('Orbit|Owner instructions'),
  copyToClipboard: s__('Orbit|Copy to clipboard'),
  setupPitch: s__(
    'Orbit|Turn on Orbit for %{groupName} to supercharge agents with deep contextual intelligence — they understand how code, pipelines, work items, and merge requests connect across GitLab. This means better recommendations, less manual context-gathering, and agents that get smarter as your graph grows.',
  ),
  setupHeading: s__('Orbit|Turn on Orbit for %{groupName}'),
  setupStep1Prefix: s__('Orbit|Navigate to'),
  setupStep1Link: s__('Orbit|Settings, then Orbit'),
  setupStep1Plain: s__('Orbit|1. Navigate to %{link} (%{url})'),
  setupStep2: s__('Orbit|2. Click "Get started"'),
  setupStep3: s__('Orbit|3. Review and confirm'),
  setupOutro: s__(
    'Orbit|Once indexed, team members can use Orbit data through GitLab Duo Agent Platform or via MCP and CLI connections.',
  ),
};

export default defineComponent({
  name: 'OrbitExploreEmptyState',
  compatConfig: { MODE: 3 },
  components: {
    GlAvatar,
    GlButton,
    GlLink,
    GlModal,
    OrbitEmptyState,
    TurnOnIndexingModal,
  },
  props: {
    availableGroups: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  i18n: {
    ...i18n,
    copied: s__('Orbit|Copied'),
  },
  data() {
    return {
      setupGroup: null,
      copyState: 'idle',
      enableGroup: null,
    };
  },
  computed: {
    setupModalVisible() {
      return Boolean(this.setupGroup);
    },
    configurableGroups() {
      return this.availableGroups.filter(
        (g) => g.knowledgeGraphAvailable || g.knowledgeGraphEnabled,
      );
    },
    ownerGroups() {
      return this.configurableGroups.filter(
        (g) => (g.maxAccessLevel?.integerValue ?? 0) >= OWNER_ACCESS_LEVEL,
      );
    },
    nonOwnerGroups() {
      return this.configurableGroups.filter(
        (g) => (g.maxAccessLevel?.integerValue ?? 0) < OWNER_ACCESS_LEVEL,
      );
    },
    hasAnyConfigurable() {
      return this.configurableGroups.length > 0;
    },
    setupGroupName() {
      return this.setupGroup?.name || '';
    },
    setupPitchText() {
      return sprintf(this.$options.i18n.setupPitch, { groupName: this.setupGroupName });
    },
    setupHeadingText() {
      return sprintf(this.$options.i18n.setupHeading, { groupName: this.setupGroupName });
    },
    setupSettingsUrl() {
      if (!this.setupGroup) return '';
      return `${window.location.origin}${groupSettingsOrbitPath(this.setupGroup.fullPath)}`;
    },
    setupClipboardText() {
      const { i18n: strings } = this.$options;
      const step1 = sprintf(strings.setupStep1Plain, {
        link: strings.setupStep1Link,
        url: this.setupSettingsUrl,
      });
      return [
        this.setupPitchText,
        '',
        this.setupHeadingText,
        step1,
        strings.setupStep2,
        strings.setupStep3,
        '',
        strings.setupOutro,
      ].join('\n');
    },
  },
  methods: {
    ownersPath(fullPath) {
      return `${groupGroupMembersPath(fullPath)}?max_role=static-${OWNER_ACCESS_LEVEL}`;
    },
    openSetupGuide(group) {
      this.setupGroup = group;
    },
    onSetupModalHidden() {
      this.setupGroup = null;
    },
    openEnableModal(group) {
      this.enableGroup = group;
    },
    onEnabled(group) {
      window.location.assign(groupSettingsOrbitPath(group.fullPath));
    },
    onEnableModalHidden() {
      this.enableGroup = null;
    },
    async copySetupInstructions() {
      try {
        await copyToClipboard(this.setupClipboardText, this.$refs.copyButton?.$el);
        this.copyState = 'copied';
      } catch (error) {
        Sentry.captureException(error);
        this.copyState = 'error';
      }
      setTimeout(() => {
        this.copyState = 'idle';
      }, COPY_RESET_MS);
    },
  },
});
</script>

<template>
  <orbit-empty-state data-testid="orbit-explore-empty-state">
    <p
      v-if="!hasAnyConfigurable"
      class="gl-border gl-mb-0 gl-mt-3 gl-rounded-lg gl-border-default gl-p-5 gl-font-bold"
      data-testid="orbit-no-available-groups"
    >
      {{ $options.i18n.noGroups }}
    </p>

    <template v-else>
      <div
        v-if="ownerGroups.length"
        class="gl-mt-3 gl-flex gl-w-full gl-max-w-3xl gl-flex-col gl-gap-3"
        data-testid="orbit-owner-groups"
      >
        <div
          v-for="group in ownerGroups"
          :key="group.fullPath"
          class="gl-border gl-flex gl-items-center gl-gap-3 gl-rounded-lg gl-border-default gl-p-5"
        >
          <gl-avatar
            :src="group.avatarUrl"
            :entity-name="group.name"
            :size="32"
            shape="rect"
            class="gl-flex-shrink-0"
          />
          <span class="gl-mr-auto gl-font-bold">{{ group.name }}</span>
          <gl-button
            variant="confirm"
            size="small"
            data-testid="orbit-get-started-btn"
            @click="openEnableModal(group)"
          >
            {{ $options.i18n.getStarted }}
          </gl-button>
        </div>
      </div>

      <div
        v-if="nonOwnerGroups.length"
        class="gl-mt-3 gl-flex gl-w-full gl-max-w-3xl gl-flex-col gl-gap-3"
        data-testid="orbit-non-owner-groups"
      >
        <h3 class="gl-heading-4 gl-mb-0">{{ $options.i18n.availableGroups }}</h3>
        <p class="gl-mb-0 gl-text-subtle">
          {{ $options.i18n.nonOwnerDescription }}
        </p>
        <div
          v-for="group in nonOwnerGroups"
          :key="group.fullPath"
          class="gl-border gl-flex gl-items-center gl-gap-3 gl-rounded-lg gl-border-default gl-p-5"
        >
          <gl-avatar
            :src="group.avatarUrl"
            :entity-name="group.name"
            :size="32"
            shape="rect"
            class="gl-flex-shrink-0"
          />
          <span class="gl-mr-auto gl-font-bold">{{ group.name }}</span>
          <gl-link :href="ownersPath(group.fullPath)">
            {{ $options.i18n.viewOwners }}
          </gl-link>
          <gl-button
            size="small"
            class="gl-ml-5"
            data-testid="orbit-setup-guide-btn"
            @click="openSetupGuide(group)"
          >
            {{ $options.i18n.setupGuide }}
          </gl-button>
        </div>
      </div>
    </template>

    <gl-modal
      :visible="setupModalVisible"
      modal-id="orbit-setup-guide-modal"
      :title="$options.i18n.setupModalTitle"
      :hide-footer="true"
      data-testid="orbit-setup-guide-modal"
      @hidden="onSetupModalHidden"
    >
      <template v-if="setupGroup">
        <p>{{ $options.i18n.setupRequirement }}</p>
        <div class="gl-flex gl-items-center gl-gap-3">
          <h3 class="gl-heading-4 gl-mb-0 gl-mr-auto">
            {{ $options.i18n.ownerInstructions }}
          </h3>
          <gl-button
            ref="copyButton"
            size="small"
            icon="copy-to-clipboard"
            :aria-label="$options.i18n.copyToClipboard"
            data-testid="orbit-copy-instructions-btn"
            @click="copySetupInstructions"
          >
            {{ copyState === 'copied' ? $options.i18n.copied : $options.i18n.copyToClipboard }}
          </gl-button>
        </div>
        <div class="gl-border gl-mt-3 gl-rounded-lg gl-border-default gl-p-5">
          <p class="gl-mb-0">{{ setupPitchText }}</p>
          <p class="gl-mb-0 gl-mt-5 gl-font-bold">{{ setupHeadingText }}</p>
          <ol class="gl-mb-0 gl-mt-2 gl-pl-5">
            <li>
              {{ $options.i18n.setupStep1Prefix }}
              <gl-link :href="setupSettingsUrl">{{ $options.i18n.setupStep1Link }}</gl-link>
            </li>
            <li>{{ $options.i18n.setupStep2 }}</li>
            <li>{{ $options.i18n.setupStep3 }}</li>
          </ol>
          <p class="gl-mb-0 gl-mt-5">{{ $options.i18n.setupOutro }}</p>
        </div>
      </template>
    </gl-modal>

    <turn-on-indexing-modal
      modal-id="orbit-empty-state-enable-modal"
      :group="enableGroup"
      @enabled="onEnabled"
      @hidden="onEnableModalHidden"
    />
  </orbit-empty-state>
</template>
