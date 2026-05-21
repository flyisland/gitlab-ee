<script>
import { GlButton, GlTooltipDirective, GlSkeletonLoader } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { copyToClipboard } from '~/lib/utils/copy_to_clipboard';
import showGlobalToast from '~/vue_shared/plugins/global_toast';
import { AGENTIC_CHAT_SHOW_ROUTE } from 'ee/ai/duo_agents_platform/router/constants';
import panelTitleQuery from '../graphql/panel_title.query.graphql';

export default {
  name: 'AiContentContainer',
  components: {
    GlButton,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['chatConfiguration'],
  i18n: {
    collapseButtonLabel: __('Collapse panel'),
    moreOptionsLabel: __('More options'),
    copySessionIdTooltip: __('Copy Chat Session ID: %{id}'),
    sessionIdCopiedToast: __('Session ID copied to clipboard'),
    sessionIdCopyFailedToast: __('Could not copy session ID'),
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    showBackButton: {
      type: Boolean,
      required: false,
      default: false,
    },
    isMaximized: {
      type: Boolean,
      required: true,
    },
    showLoadingState: {
      type: Boolean,
      required: false,
      default: false,
    },
    showInformationButton: {
      type: Boolean,
      required: false,
      default: false,
    },
    informationButtonLabel: {
      type: String,
      required: false,
      default: __('Information'),
    },
    isSessionInformationVisible: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: [
    'closePanel',
    'go-back',
    'switch-to-active-tab',
    'toggleMaximize',
    'toggle-session-information',
  ],
  apollo: {
    panelTitleState: {
      query: panelTitleQuery,
      update(data) {
        return data;
      },
    },
  },
  data() {
    return {
      currentTitle: null,
      panelTitleState: null,
      sessionId: null,
      isSessionDropdownVisible: false,
    };
  },
  computed: {
    panelTitle() {
      return this.panelTitleState?.panelTitle || '';
    },
    panelSubtitle() {
      return this.panelTitleState?.panelSubtitle || '';
    },
    goBackTitle() {
      return __('Go back');
    },
    maximizeButtonLabel() {
      return this.isMaximized ? __('Minimize panel') : __('Maximize panel');
    },
    showSessionId() {
      return this.sessionId && this.$route?.name === AGENTIC_CHAT_SHOW_ROUTE;
    },
    sessionText() {
      return sprintf(this.$options.i18n.copySessionIdTooltip, { id: this.sessionId });
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
      return !this.isSessionDropdownVisible ? this.$options.i18n.moreOptionsLabel : '';
    },
    displayTitle() {
      return this.panelTitle || this.currentTitle || this.title;
    },
  },
  watch: {
    title: {
      handler() {
        this.currentTitle = null;
        this.resetPanelOverrides();
      },
    },
    '$route.path': {
      handler() {
        this.resetPanelOverrides();
      },
    },
  },
  methods: {
    resetPanelOverrides() {
      this.panelTitleState = null;
    },
    handleGoBack() {
      this.$emit('go-back');
    },
    handleTitleChange(title) {
      this.currentTitle = title || null;
    },
    handleSessionIdChanged(sessionId) {
      this.sessionId = sessionId;
    },
    showSessionDropdown() {
      this.isSessionDropdownVisible = true;
    },
    hideSessionDropdown() {
      this.isSessionDropdownVisible = false;
    },
    async copySessionIdToClipboard() {
      try {
        await copyToClipboard(this.sessionId);
        showGlobalToast(this.$options.i18n.sessionIdCopiedToast);
      } catch {
        showGlobalToast(this.$options.i18n.sessionIdCopyFailedToast);
      }
    },
  },
};
</script>

<template>
  <aside
    id="ai-panel-portal"
    :aria-label="title"
    class="ai-panel !gl-left-auto gl-flex gl-h-full gl-w-[var(--ai-panel-width)] gl-grow gl-flex-col gl-rounded-[1rem] gl-bg-default [contain:strict] lg:gl-mr-2"
  >
    <div class="ai-panel-header gl-flex gl-min-h-[3.0625rem] gl-items-center gl-justify-between">
      <div
        class="gl-flex gl-max-w-17/20 gl-flex-1 gl-shrink-0 gl-items-center gl-justify-start gl-gap-2 gl-overflow-hidden gl-truncate gl-text-ellipsis gl-whitespace-nowrap"
      >
        <gl-button
          v-gl-tooltip.bottom
          class="lg:gl-flex"
          :class="{ '!gl-hidden': !showBackButton }"
          icon="go-back"
          category="tertiary"
          :aria-label="goBackTitle"
          :title="goBackTitle"
          data-testid="content-container-back-button"
          @click="handleGoBack"
        />
        <div class="gl-flex gl-w-full gl-flex-col">
          <gl-skeleton-loader v-if="showLoadingState && !panelSubtitle" :lines="2" />
          <div v-else>
            <h3
              class="gl-m-0 gl-truncate gl-text-sm"
              :class="{ 'gl-ml-4': !showBackButton }"
              data-testid="content-container-title"
            >
              {{ displayTitle }}
            </h3>
            <h4
              v-if="panelSubtitle"
              class="gl-m-0 gl-mt-1 gl-truncate gl-text-sm gl-font-normal"
              data-testid="content-container-subtitle"
            >
              {{ panelSubtitle }}
            </h4>
          </div>
        </div>
      </div>

      <div class="ai-panel-header-actions gl-flex gl-gap-x-2 gl-pr-3">
        <gl-button
          v-if="showInformationButton"
          v-gl-tooltip.bottom
          icon="information-o"
          category="tertiary"
          size="small"
          :aria-label="informationButtonLabel"
          :title="informationButtonLabel"
          :aria-expanded="isSessionInformationVisible"
          data-testid="content-container-information-button"
          @click="$emit('toggle-session-information')"
        />
        <gl-button
          v-gl-tooltip.bottom
          icon="dash"
          category="tertiary"
          size="small"
          :aria-label="$options.i18n.collapseButtonLabel"
          :title="$options.i18n.collapseButtonLabel"
          aria-expanded
          data-testid="content-container-collapse-button"
          @click="$emit('closePanel', false)"
        />
        <gl-button
          v-gl-tooltip.bottom
          class="gl-hidden lg:gl-flex"
          :icon="isMaximized ? 'minimize' : 'maximize'"
          category="tertiary"
          size="small"
          :aria-label="maximizeButtonLabel"
          :title="maximizeButtonLabel"
          data-testid="content-container-maximize-button"
          @click="$emit('toggleMaximize')"
        />
      </div>
    </div>
    <div class="ai-panel-body gl-grow gl-flex-wrap gl-justify-center gl-overflow-auto">
      <slot
        name="active-tab"
        :show-session-id="showSessionId"
        :show-session-dropdown-tooltip="showSessionDropdownTooltip"
        :toggle-text="$options.i18n.moreOptionsLabel"
        :items="sessionIdItems"
        :show-session-dropdown="showSessionDropdown"
        :hide-session-dropdown="hideSessionDropdown"
        :handle-title-change="handleTitleChange"
        :handle-session-id-changed="handleSessionIdChanged"
      ></slot>
    </div>
  </aside>
</template>
