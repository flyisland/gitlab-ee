<script>
import { GlAlert, GlAvatar, GlButton, GlTooltipDirective, GlDisclosureDropdown } from '@gitlab/ui';
import { copyToClipboard } from '~/lib/utils/copy_to_clipboard';
import { DUO_CHAT_VIEWS } from 'ee/ai/constants';
import { s__, sprintf } from '~/locale';
import SafeHtml from '~/vue_shared/directives/safe_html';

export const i18n = {
  CHAT_CLOSE_LABEL: s__('DuoChat|Close chat'),
  CHAT_BACK_TO_CHAT_TOOLTIP: s__('DuoChat|Back to chat'),
  CHAT_TITLE: s__('DuoChat|GitLab Duo Chat'),
  CHAT_DROPDOWN_MORE_OPTIONS: s__('DuoChat|More options'),
  CHAT_COPY_TOOLTIP: s__('DuoChat|Copy Chat Session ID (%{id})'),
  CHAT_COPY_SUCCESS_TOAST: s__('DuoChat|Session ID copied to clipboard'),
  CHAT_COPY_FAILED_TOAST: s__('DuoChat|Could not copy session ID'),
};

export default {
  name: 'DuoChatHeader',

  components: {
    GlAlert,
    GlAvatar,
    GlButton,
    GlDisclosureDropdown,
  },
  directives: {
    SafeHtml,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    title: {
      type: String,
      required: false,
      default: i18n.CHAT_TITLE,
    },
    agentHandler: {
      type: String,
      required: false,
      default: null,
    },
    subtitle: {
      type: String,
      required: false,
      default: '',
    },
    sessionId: {
      type: String,
      required: false,
      default: '',
    },
    error: {
      type: String,
      required: false,
      default: '',
    },
    info: {
      type: String,
      required: false,
      default: '',
    },
    isMultithreaded: {
      type: Boolean,
      required: false,
      default: false,
    },
    activeThreadId: {
      type: String,
      required: false,
      default: null,
    },
    currentView: {
      type: String,
      required: true,
    },
    showStudioHeader: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['close', 'go-back-to-chat'],
  data() {
    return {
      isSessionDropdownVisible: false,
    };
  },
  computed: {
    DUO_CHAT_VIEWS() {
      return DUO_CHAT_VIEWS;
    },
    sessionText() {
      return sprintf(this.$options.i18n.CHAT_COPY_TOOLTIP, { id: this.sessionId });
    },
    sessionIdItems() {
      return [
        {
          text: this.sessionText,
          action: () => {
            this.copySessionIdToClipboard();
          },
        },
      ];
    },
    showSessionDropdownTooltip() {
      return !this.isSessionDropdownVisible ? this.$options.i18n.CHAT_DROPDOWN_MORE_OPTIONS : '';
    },
    showSubheader() {
      return this.currentView !== DUO_CHAT_VIEWS.LIST;
    },
  },
  methods: {
    showSessionDropdown() {
      this.isSessionDropdownVisible = true;
    },
    hideSessionDropdown() {
      this.isSessionDropdownVisible = false;
    },
    async copySessionIdToClipboard() {
      try {
        await copyToClipboard(this.sessionId, this.$el);

        this.$toast.show(this.$options.i18n.CHAT_COPY_SUCCESS_TOAST);
      } catch {
        this.$toast.show(this.$options.i18n.CHAT_COPY_FAILED_TOAST);
      }
    },
  },
  i18n,
};
</script>

<template>
  <header data-testid="chat-header" class="gl-shrink-0 gl-p-0">
    <div
      v-if="!showStudioHeader"
      class="gl-flex gl-w-full gl-items-center gl-px-4 gl-py-3"
      data-testid="chat-top-header"
    >
      <h4
        v-if="subtitle"
        class="gl-mb-0 gl-max-w-17/20 gl-flex-1 gl-shrink-0 gl-overflow-hidden gl-truncate gl-text-ellipsis gl-whitespace-nowrap gl-pr-3 gl-text-sm gl-font-normal gl-text-subtle"
        data-testid="chat-subtitle"
      >
        {{ subtitle }}
      </h4>
      <div class="gl-ml-auto gl-flex gl-gap-3">
        <gl-disclosure-dropdown
          v-if="sessionId"
          v-gl-tooltip="showSessionDropdownTooltip"
          icon="ellipsis_v"
          category="tertiary"
          text-sr-only
          size="small"
          :toggle-text="$options.i18n.CHAT_DROPDOWN_MORE_OPTIONS"
          :items="sessionIdItems"
          no-caret
          @shown="showSessionDropdown"
          @hidden="hideSessionDropdown"
        />
        <gl-button
          category="tertiary"
          variant="default"
          icon="close"
          size="small"
          data-testid="chat-close-button"
          :aria-label="$options.i18n.CHAT_CLOSE_LABEL"
          @click="$emit('close')"
        />
      </div>
    </div>
    <div
      v-if="showSubheader"
      class="drawer-title gl-flex gl-items-center gl-justify-start gl-gap-4 gl-px-4 gl-py-3"
      :class="{ 'gl-border-t': !showStudioHeader, 'gl-border-b': showStudioHeader }"
      data-testid="chat-subheader"
    >
      <div class="gl-flex gl-grow gl-gap-3">
        <gl-avatar :size="32" :entity-name="title" shape="circle" class="gl-shrink-0" />
        <div class="gl-flex gl-flex-col gl-justify-center">
          <h3 class="gl-my-0 gl-line-clamp-1 gl-text-[0.875rem] gl-text-default gl-break-anywhere">
            {{ title }}
          </h3>
          <p v-if="agentHandler" class="gl-my-0 gl-text-[0.75rem] gl-text-subtle">
            {{ agentHandler }}
          </p>
        </div>
      </div>

      <div class="gl-flex gl-gap-3">
        <gl-button
          v-if="isMultithreaded && activeThreadId && currentView === DUO_CHAT_VIEWS.LIST"
          v-gl-tooltip
          :title="$options.i18n.CHAT_BACK_TO_CHAT_TOOLTIP"
          data-testid="go-back-to-chat-button"
          category="tertiary"
          size="small"
          icon="go-back"
          :aria-label="$options.i18n.CHAT_BACK_TO_CHAT_TOOLTIP"
          @click="$emit('go-back-to-chat')"
        />
      </div>
    </div>

    <slot name="subheader"></slot>

    <gl-alert
      v-if="info"
      key="info"
      :dismissible="false"
      variant="info"
      class="!gl-pl-9"
      role="alert"
      data-testid="chat-info"
    >
      <span v-safe-html="info"></span>
    </gl-alert>

    <gl-alert
      v-if="error"
      key="error"
      :dismissible="false"
      variant="danger"
      class="!gl-pl-9"
      role="alert"
      data-testid="chat-error"
    >
      <span v-safe-html="error"></span>
    </gl-alert>
  </header>
</template>
