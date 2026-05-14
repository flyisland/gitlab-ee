<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { InternalEvents } from '~/tracking';
import { BV_HIDE_TOOLTIP } from '~/lib/utils/constants';
import { keysFor, DUO_CHAT } from '~/behaviors/shortcuts/keybindings';
import { shouldDisableShortcuts } from '~/behaviors/shortcuts/shortcuts_toggle';
import { __, sprintf } from '~/locale';
import { sanitize } from '~/lib/dompurify';
import NewChatButton from './new_chat_button.vue';

export default {
  name: 'NavigationRail',
  components: {
    GlButton,
    NewChatButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [InternalEvents.mixin()],
  i18n: {
    aiCatalogLabel: __('GitLab Duo AI Catalog'),
    chatOffLabel: __('GitLab Duo Agent Platform'),
    currentChatLabel: __('Current GitLab Duo Chat'),
    duoChatLabel: __('Active GitLab Duo Chat'),
    historyLabel: __('GitLab Duo Chat history'),
    sessionsLabel: __('GitLab Duo sessions'),
    suggestionsLabel: __('GitLab Duo suggestions'),
  },
  props: {
    activeTab: {
      type: String,
      required: false,
      default: null,
    },
    isExpanded: {
      type: Boolean,
      required: false,
      default: true,
    },
    showSuggestionsTab: {
      type: Boolean,
      required: false,
      default: true,
    },
    chatDisabledReason: {
      type: String,
      required: false,
      default: '',
    },
    canConfigureDuoSettings: {
      type: Boolean,
      required: false,
      default: false,
    },
    projectId: {
      type: String,
      required: false,
      default: null,
    },
    namespaceId: {
      type: String,
      required: false,
      default: null,
    },
    isAgenticMode: {
      type: Boolean,
      required: true,
    },
    exploreAiCatalogPath: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    duoShortcutKey() {
      return shouldDisableShortcuts() || this.isChatDisabled ? null : keysFor(DUO_CHAT);
    },
    isChatDisabled() {
      return Boolean(this.chatDisabledReason);
    },
    chatDisabledTooltip() {
      if (!this.isChatDisabled) return '';

      return sprintf(__('An administrator has turned off GitLab Duo for this %{reason}.'), {
        reason: this.chatDisabledReason,
      });
    },
    formattedDuoShortcutTooltip() {
      if (this.isChatDisabled) return this.chatDisabledTooltip;

      const description = this.isAgenticMode
        ? this.$options.i18n.currentChatLabel
        : this.$options.i18n.duoChatLabel;
      const key = keysFor(DUO_CHAT);
      return shouldDisableShortcuts()
        ? description
        : sanitize(`${description} <kbd class="flat gl-ml-1" aria-hidden=true>${key}</kbd>`);
    },
  },
  methods: {
    toggleTab(tab) {
      if (!this.isChatDisabled || this.canConfigureDuoSettings) {
        this.$emit('handleTabToggle', tab);
      }
    },
    handleNewChat(agent) {
      this.$emit('new-chat', agent);
    },
    hideTooltips() {
      this.$root.$emit(BV_HIDE_TOOLTIP);
    },
    handleNewChatError(error) {
      this.$emit('newChatError', error);
    },
    handleAiCatalogClick() {
      this.trackEvent('click_ai_catalog_button_duo_rail');
    },
  },
};
</script>

<!-- eslint-disable @gitlab/vue-tailwind-no-max-width-media-queries -->
<template>
  <nav class="max-lg:gl-flex max-lg:gl-flex-1" :aria-label="__('Duo controls')">
    <div
      class="gl-ml-3 gl-flex gl-items-center gl-gap-5 gl-bg-transparent max-lg:gl-h-[var(--ai-navigation-rail-size)] max-lg:gl-flex-1 max-lg:gl-px-3 max-sm:gl-mr-3 max-sm:gl-px-0 sm:gl-ml-0 lg:gl-mt-2 lg:gl-h-full lg:gl-w-[var(--ai-navigation-rail-size)] lg:gl-flex-col lg:gl-gap-4 lg:gl-py-3"
      role="tablist"
      aria-orientation="vertical"
    >
      <template v-if="isChatDisabled && canConfigureDuoSettings">
        <gl-button
          v-gl-tooltip.left
          icon="duo-chat-off"
          size="small"
          :aria-label="$options.i18n.chatOffLabel"
          :aria-expanded="isExpanded"
          role="tab"
          :title="$options.i18n.chatOffLabel"
          :class="['ai-nav-icon !gl-rounded-lg', { 'ai-nav-icon-active': isExpanded }]"
          data-testid="duo-disabled-toggle"
          @click="toggleTab('chat')"
          @mouseout="hideTooltips"
        />
      </template>
      <template v-else>
        <new-chat-button
          :project-id="projectId"
          :namespace-id="namespaceId"
          :active-tab="activeTab"
          :is-expanded="isExpanded"
          :is-chat-disabled="isChatDisabled"
          :is-agent-select-enabled="isAgenticMode"
          :chat-disabled-tooltip="chatDisabledTooltip"
          @new-chat="handleNewChat"
          @toggleTab="toggleTab"
          @hideTooltips="hideTooltips"
          @newChatError="handleNewChatError"
        />
        <div
          class="gl-h-5 gl-w-1 gl-border-0 gl-border-r-1 gl-border-solid gl-border-strong lg:gl-mx-auto lg:gl-h-1 lg:gl-w-5 lg:gl-border-r-0 lg:gl-border-t-1"
        ></div>
        <gl-button
          v-gl-tooltip.left="{
            title: formattedDuoShortcutTooltip,
            html: true,
          }"
          icon="duo-chat"
          size="small"
          class="js-tanuki-bot-chat-toggle !gl-rounded-lg"
          :class="[
            'ai-nav-icon',
            { 'ai-nav-icon-active': activeTab === 'chat', 'gl-opacity-5': isChatDisabled },
          ]"
          category="tertiary"
          :aria-selected="activeTab === 'chat'"
          :aria-expanded="isExpanded"
          :aria-keyshortcuts="duoShortcutKey"
          :aria-label="$options.i18n.duoChatLabel"
          role="tab"
          :aria-disabled="isChatDisabled"
          data-testid="ai-chat-toggle"
          @mouseout="hideTooltips"
          @click="toggleTab('chat')"
        />
        <gl-button
          v-gl-tooltip.left
          icon="history"
          size="small"
          class="!gl-rounded-lg"
          :class="[
            'ai-nav-icon',
            { 'ai-nav-icon-active': activeTab === 'history', 'gl-opacity-5': isChatDisabled },
          ]"
          category="tertiary"
          :aria-selected="activeTab === 'history'"
          :aria-expanded="isExpanded"
          :aria-label="$options.i18n.historyLabel"
          :title="isChatDisabled ? chatDisabledTooltip : $options.i18n.historyLabel"
          role="tab"
          :aria-disabled="isChatDisabled"
          data-testid="ai-history-toggle"
          @mouseout="hideTooltips"
          @click="toggleTab('history')"
        />
        <gl-button
          v-gl-tooltip.left
          icon="session-ai"
          size="small"
          class="!gl-rounded-lg"
          :class="[
            'ai-nav-icon',
            { 'ai-nav-icon-active': activeTab === 'sessions', 'gl-opacity-5': isChatDisabled },
          ]"
          category="tertiary"
          :aria-selected="activeTab === 'sessions'"
          :aria-expanded="isExpanded"
          :aria-label="$options.i18n.sessionsLabel"
          :title="isChatDisabled ? chatDisabledTooltip : $options.i18n.sessionsLabel"
          role="tab"
          :aria-disabled="isChatDisabled"
          data-testid="ai-sessions-toggle"
          @mouseout="hideTooltips"
          @click="toggleTab('sessions')"
        />
        <gl-button
          v-if="showSuggestionsTab"
          v-gl-tooltip.left
          icon="suggestion-ai"
          size="small"
          class="!gl-rounded-lg max-lg:gl-ml-auto lg:gl-mt-auto"
          :class="[
            'ai-nav-icon',
            { 'ai-nav-icon-active': activeTab === 'suggestions', 'gl-opacity-5': isChatDisabled },
          ]"
          category="tertiary"
          :aria-selected="activeTab === 'suggestions'"
          :aria-expanded="isExpanded"
          :aria-label="$options.i18n.suggestionsLabel"
          :title="isChatDisabled ? chatDisabledTooltip : $options.i18n.suggestionsLabel"
          role="tab"
          :aria-disabled="isChatDisabled"
          data-testid="ai-suggestions-toggle"
          @mouseout="hideTooltips"
          @click="toggleTab('suggestions')"
        />
        <gl-button
          v-if="exploreAiCatalogPath"
          v-gl-tooltip.left
          icon="tanuki-ai"
          size="small"
          class="ai-nav-icon !gl-rounded-lg"
          :class="{ 'max-lg:gl-ml-auto lg:gl-mt-auto': !showSuggestionsTab }"
          category="tertiary"
          :aria-label="$options.i18n.aiCatalogLabel"
          :title="$options.i18n.aiCatalogLabel"
          :href="exploreAiCatalogPath"
          target="_blank"
          data-testid="ai-catalog-button"
          @mouseout="hideTooltips"
          @click="handleAiCatalogClick"
        />
      </template>
    </div>
  </nav>
</template>
