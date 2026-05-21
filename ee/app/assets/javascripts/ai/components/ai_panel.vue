<script>
import { GlDisclosureDropdown, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/src/utils'; // eslint-disable-line no-restricted-syntax -- GlBreakpointInstance is used intentionally here. In this case we must obtain viewport breakpoints
import { __, s__ } from '~/locale';
import { CHAT_MODES } from 'ee/ai/tanuki_bot/constants';
import {
  AGENTS_PLATFORM_INDEX_ROUTE,
  AGENTS_PLATFORM_SHOW_ROUTE,
  AGENTIC_CHAT_BLOCKED_ROUTE,
  CLOSED_ROUTE,
  ROUTE_TO_TAB,
} from 'ee/ai/duo_agents_platform/router/constants';
import { getDefaultRouteForTab } from 'ee/ai/duo_agents_platform/router/utils';
import { safeRouterPush } from 'ee/ai/duo_agents_platform/utils/router_utils';
import { duoChatGlobalState } from '~/super_sidebar/state';
import dismissUserCalloutMutation from '~/graphql_shared/mutations/dismiss_user_callout.mutation.graphql';
import { setMaximized, toggleMaximized, toggleInfoToggle } from '../graphql';
import isMaximizedQuery from '../graphql/get_ai_panel_is_maximized.query.graphql';
import infoToggleStatesQuery from '../graphql/get_ai_panel_info_toggle_states.query.graphql';
import { toggleAiPanelMaximizedClass } from '../utils/dom_utils';
import AiContentContainer from './content_container.vue';
import NavigationRail from './navigation_rail.vue';

const DUO_PANEL_AUTO_EXPANDED_CALLOUT = 'duo_panel_auto_expanded';

export default {
  name: 'AiPanel',
  components: {
    AiContentContainer,
    NavigationRail,
    GlDisclosureDropdown,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['chatConfiguration'],
  props: {
    userId: {
      type: String,
      required: false,
      default: null,
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
    rootNamespaceId: {
      type: String,
      required: false,
      default: null,
    },
    resourceId: {
      type: String,
      required: false,
      default: null,
    },
    metadata: {
      type: String,
      required: false,
      default: null,
    },
    userModelSelectionEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    chatDisabledReason: {
      type: String,
      required: false,
      default: '',
    },
    shouldShowBlockedState: {
      type: Boolean,
      required: true,
    },
  },
  apollo: {
    isMaximized: {
      query: isMaximizedQuery,
      result({ data }) {
        toggleAiPanelMaximizedClass(data?.isMaximized);
      },
    },
    infoToggleStates: {
      query: infoToggleStatesQuery,
      update(data) {
        return data?.infoToggleStates ?? {};
      },
    },
  },
  data() {
    return {
      isDesktop: GlBreakpointInstance.isDesktop(),
      duoChatGlobalState,
      selectedAgentError: null,
      selectedAgent: {},
      isMaximized: false,
      infoToggleStates: {},
    };
  },
  computed: {
    activeTab() {
      return ROUTE_TO_TAB[this.$route?.name];
    },
    isChatDisabled() {
      return Boolean(this.chatDisabledReason);
    },
    isExpandable() {
      return !this.isChatDisabled || this.shouldShowBlockedState;
    },
    isAgenticMode() {
      return (
        (this.chatConfiguration.defaultProps.isAgenticAvailable &&
          this.duoChatGlobalState.chatMode === CHAT_MODES.AGENTIC) ||
        this.shouldShowBlockedState
      );
    },
    exploreAiCatalogPath() {
      return this.chatConfiguration.defaultProps?.exploreAiCatalogPath ?? null;
    },
    currentChatTitle() {
      if (this.shouldShowBlockedState) {
        return __('GitLab Duo Agent Platform');
      }
      return this.isAgenticMode
        ? this.chatConfiguration.agenticTitle
        : this.chatConfiguration.classicTitle;
    },
    currentTabTitle() {
      if (this.shouldShowBlockedState) {
        return this.currentChatTitle;
      }
      if (this.$route?.meta?.title) {
        return this.$route.meta.title;
      }
      switch (this.activeTab) {
        case 'chat':
          return this.currentChatTitle;
        case 'sessions':
          return __('Sessions');
        case 'suggestions':
          return __('Suggestions');
        default:
          return '';
      }
    },
    isPanelOpen() {
      return this.activeTab !== undefined && this.isExpandable;
    },
    isShowingAgentSession() {
      return this.$route?.name === AGENTS_PLATFORM_SHOW_ROUTE;
    },
    sessionInformationButtonLabel() {
      return s__('DuoAgentPlatform|Session information');
    },
    isSessionInformationVisible() {
      const key = `ai_panel:${this.$route.params.id}`;
      return this.infoToggleStates[key] ?? false;
    },
  },
  watch: {
    'duoChatGlobalState.chatMode': {
      async handler(newMode, oldMode) {
        if (newMode !== oldMode && this.activeTab === 'chat') {
          await this.navigateToChatRoute();
        }
      },
    },
  },
  async mounted() {
    window.addEventListener('resize', this.handleWindowResize);
    if (!this.isExpandable) {
      await safeRouterPush(this.$router, { name: CLOSED_ROUTE }, { component: 'AiPanel' });
    } else if (this.activeTab === 'chat') {
      await this.navigateToChatRoute();
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleWindowResize);
    // Tear down the router's event-hub listeners (SHOW_SESSION /
    // SHOW_NEW_CHAT) so they don't leak across panel re-mounts.
    this.$router?.cleanupEventListeners?.();
  },
  methods: {
    async navigateToChatRoute() {
      const routeName = this.shouldShowBlockedState
        ? AGENTIC_CHAT_BLOCKED_ROUTE
        : getDefaultRouteForTab('chat', this.isAgenticMode);
      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });
    },
    handleGoBack() {
      safeRouterPush(this.$router, { name: AGENTS_PLATFORM_INDEX_ROUTE }, { component: 'AiPanel' });
    },
    async handleTabToggle(tab) {
      const currentTab = ROUTE_TO_TAB[this.$route?.name];

      if (currentTab === tab) {
        await this.closePanel();
        return;
      }

      const routeName =
        this.shouldShowBlockedState && tab === 'chat'
          ? AGENTIC_CHAT_BLOCKED_ROUTE
          : getDefaultRouteForTab(tab, this.isAgenticMode);

      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });

      if (['chat', 'new'].includes(tab)) {
        // The preceding `await safeRouterPush` has already advanced
        // `$route.name`, so the route-derived `activeTab` is already 'chat'.
        // Wait one nextTick for the chat state manager's children to
        // render, then signal the focus.
        await this.$nextTick();
        this.duoChatGlobalState.focusChatInput = true;
      }
    },
    async handleChangeTab(tab) {
      if (this.shouldShowBlockedState && tab === 'chat') return;
      const routeName = getDefaultRouteForTab(tab, this.isAgenticMode);
      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });
    },
    async closePanel() {
      await setMaximized(false);
      await safeRouterPush(this.$router, { name: CLOSED_ROUTE }, { component: 'AiPanel' });
      this.dismissAutoExpandCallout();
    },
    async dismissAutoExpandCallout() {
      try {
        await this.$apollo.mutate({
          mutation: dismissUserCalloutMutation,
          variables: {
            input: {
              featureName: DUO_PANEL_AUTO_EXPANDED_CALLOUT,
            },
          },
          context: {
            featureCategory: 'duo_agent_platform',
          },
        });
      } catch {
        // Silently ignore errors - callout dismissal is non-critical
      }
    },
    handleWindowResize() {
      const currentIsDesktop = GlBreakpointInstance.isDesktop();

      // This check ensures that the panel is collapsed only when resizing
      // from desktop to mobile/tablet, not the other way around
      if (this.isDesktop && !currentIsDesktop) {
        this.closePanel();
      }

      this.isDesktop = currentIsDesktop;
    },
    handleNewChatError(error) {
      this.selectedAgentError = error;
    },
    toggleMaximize() {
      toggleMaximized();
    },
    handleToggleSessionInformation() {
      toggleInfoToggle(String(this.$route.params.id), 'ai_panel');
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-h-full gl-gap-[var(--ai-panels-gap)]">
    <ai-content-container
      v-if="isPanelOpen"
      :title="currentTabTitle"
      :show-back-button="isShowingAgentSession"
      :show-information-button="isShowingAgentSession"
      :information-button-label="sessionInformationButtonLabel"
      :is-maximized="isMaximized"
      :show-loading-state="isShowingAgentSession"
      :is-session-information-visible="isSessionInformationVisible"
      @closePanel="closePanel"
      @go-back="handleGoBack"
      @switch-to-active-tab="handleChangeTab"
      @toggleMaximize="toggleMaximize"
      @toggle-session-information="handleToggleSessionInformation"
    >
      <template
        #active-tab="{
          showSessionId,
          showSessionDropdownTooltip,
          toggleText,
          items,
          showSessionDropdown,
          hideSessionDropdown,
          handleTitleChange,
          handleSessionIdChanged,
        }"
      >
        <router-view
          ref="content-component"
          :user-id="userId"
          :project-id="projectId"
          :namespace-id="namespaceId"
          :root-namespace-id="rootNamespaceId"
          :resource-id="resourceId"
          :metadata="metadata"
          :selected-agent="selectedAgent"
          :user-model-selection-enabled="userModelSelectionEnabled"
          class="gl-h-full"
          @change-title="handleTitleChange"
          @session-id-changed="handleSessionIdChanged"
        >
          <template #header>
            <gl-disclosure-dropdown
              v-if="showSessionId"
              v-gl-tooltip="showSessionDropdownTooltip"
              icon="ellipsis_v"
              category="tertiary"
              text-sr-only
              size="small"
              :toggle-text="toggleText"
              :items="items"
              no-caret
              @shown="showSessionDropdown"
              @hidden="hideSessionDropdown"
            />
          </template>
        </router-view>
      </template>
    </ai-content-container>
    <navigation-rail
      :is-expanded="isPanelOpen"
      :show-suggestions-tab="false"
      :chat-disabled-reason="chatDisabledReason"
      :project-id="projectId"
      :namespace-id="namespaceId"
      :is-agentic-mode="isAgenticMode"
      :explore-ai-catalog-path="exploreAiCatalogPath"
      :show-chat-disabled-nav="shouldShowBlockedState"
      @handleTabToggle="handleTabToggle"
      @new-chat="() => handleTabToggle('new')"
      @newChatError="handleNewChatError"
    />
  </div>
</template>
