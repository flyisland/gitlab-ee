<script>
import { GlDisclosureDropdown, GlTooltipDirective } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/src/utils'; // eslint-disable-line no-restricted-syntax -- GlBreakpointInstance is used intentionally here. In this case we must obtain viewport breakpoints
import { __, s__ } from '~/locale';
import { CHAT_MODES } from 'ee/ai/tanuki_bot/constants';
import {
  AGENTS_PLATFORM_INDEX_ROUTE,
  AGENTS_PLATFORM_SHOW_ROUTE,
  AGENTIC_CHAT_SHOW_ROUTE,
  CLOSED_ROUTE,
  ROUTE_TO_TAB,
} from 'ee/ai/duo_agents_platform/router/constants';
import { getDefaultRouteForTab } from 'ee/ai/duo_agents_platform/router/utils';
import { safeRouterPush } from 'ee/ai/duo_agents_platform/utils/router_utils';
import { duoChatGlobalState } from '~/super_sidebar/state';
import dismissUserCalloutMutation from '~/graphql_shared/mutations/dismiss_user_callout.mutation.graphql';
import { setAiPanelTab, setMaximized, toggleMaximized, toggleInfoToggle } from '../graphql';
import activeTabQuery from '../graphql/active_tab.query.graphql';
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
  },
  apollo: {
    activeTab: {
      query: activeTabQuery,
      result({ data }) {
        if (data?.activeTab) {
          this.handleChangeTab(data.activeTab);
        }
      },
    },
    isMaximized: {
      query: isMaximizedQuery,
      result({ data }) {
        toggleAiPanelMaximizedClass(data?.isMaximized);
      },
    },
    infoToggleStates: {
      query: infoToggleStatesQuery,
      update({ data }) {
        return data?.infoToggleStates ?? {};
      },
    },
  },
  data() {
    return {
      activeTab: undefined,
      isDesktop: GlBreakpointInstance.isDesktop(),
      duoChatGlobalState,
      selectedAgentError: null,
      selectedAgent: {},
      isMaximized: false,
      infoToggleStates: {},
    };
  },
  computed: {
    isChatDisabled() {
      return Boolean(this.chatDisabledReason);
    },
    canConfigureDuoSettings() {
      return Boolean(this.chatConfiguration.defaultProps.canConfigureDuoSettings);
    },
    isDuoDisabledForAdmin() {
      return this.isChatDisabled && this.canConfigureDuoSettings;
    },
    isAgenticMode() {
      return (
        (this.chatConfiguration.defaultProps.isAgenticAvailable &&
          this.duoChatGlobalState.chatMode === CHAT_MODES.AGENTIC) ||
        this.isDuoDisabledForAdmin
      );
    },
    exploreAiCatalogPath() {
      return this.chatConfiguration.defaultProps?.exploreAiCatalogPath ?? null;
    },
    currentChatTitle() {
      if (this.isDuoDisabledForAdmin) {
        return __('GitLab Duo Agent Platform');
      }
      return this.isAgenticMode
        ? this.chatConfiguration.agenticTitle
        : this.chatConfiguration.classicTitle;
    },
    currentTabTitle() {
      if (this.isDuoDisabledForAdmin) {
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
      return this.activeTab !== undefined && (!this.isChatDisabled || this.isDuoDisabledForAdmin);
    },
    activeTabObject() {
      return { title: this.currentTabTitle };
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
    window.addEventListener('focus', this.handleWindowFocus);

    if (this.isDuoDisabledForAdmin) {
      // only open the empty state chat tab if duo is already open
      if (this.activeTab) {
        await safeRouterPush(
          this.$router,
          { name: AGENTIC_CHAT_SHOW_ROUTE },
          { component: 'AiPanel' },
        );
      }
    } else if (this.isChatDisabled) {
      await safeRouterPush(this.$router, { name: CLOSED_ROUTE }, { component: 'AiPanel' });
    } else if (this.activeTab === 'chat') {
      await this.navigateToChatRoute();
    }
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.handleWindowResize);
    window.removeEventListener('focus', this.handleWindowFocus);
  },
  methods: {
    async navigateToChatRoute() {
      const routeName = getDefaultRouteForTab('chat', this.isAgenticMode);
      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });
    },
    handleGoBack() {
      safeRouterPush(this.$router, { name: AGENTS_PLATFORM_INDEX_ROUTE }, { component: 'AiPanel' });
    },
    setActiveTab(value) {
      setAiPanelTab(value);
    },
    async handleTabToggle(tab) {
      const currentTab = ROUTE_TO_TAB[this.$route?.name];

      if (currentTab === tab) {
        await this.closePanel();
        return;
      }
      const routeName = getDefaultRouteForTab(tab, this.isAgenticMode);
      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });

      if (['chat', 'new'].includes(tab)) {
        // Wait for activeTab to propagate (panel opens), then nextTick
        // (child component renders), then focus. This mirrors the old
        // setActiveTab pattern that worked with <component :is>.
        const unwatchTab = this.$watch('activeTab', async () => {
          unwatchTab();
          await this.$nextTick();
          this.duoChatGlobalState.focusChatInput = true;
        });
      }
    },
    async handleChangeTab(tab) {
      const routeName = getDefaultRouteForTab(tab, this.isAgenticMode);
      await safeRouterPush(this.$router, { name: routeName }, { component: 'AiPanel' });
    },
    async closePanel() {
      this.setActiveTab(undefined);
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
    handleWindowFocus() {
      // persist panel's opened state to the currently opened browser tab context
      // this is important for:
      //   1. new tabs opened to have the same panel state as the origin tab
      //   2. current tab initial load/reload to have no layout shift
      this.setActiveTab(this.activeTab);
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
      :active-tab="activeTabObject"
      :show-back-button="isShowingAgentSession"
      :show-information-button="isShowingAgentSession"
      :information-button-label="sessionInformationButtonLabel"
      :is-maximized="isMaximized"
      :show-loading-state="isShowingAgentSession"
      :is-session-information-visible="isSessionInformationVisible"
      @closePanel="closePanel"
      @go-back="handleGoBack"
      @switch-to-active-tab="setActiveTab"
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
          :is-duo-disabled="isDuoDisabledForAdmin"
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
      :active-tab="activeTab"
      :show-suggestions-tab="false"
      :chat-disabled-reason="chatDisabledReason"
      :can-configure-duo-settings="canConfigureDuoSettings"
      :project-id="projectId"
      :namespace-id="namespaceId"
      :is-agentic-mode="isAgenticMode"
      :explore-ai-catalog-path="exploreAiCatalogPath"
      @handleTabToggle="handleTabToggle"
      @new-chat="() => handleTabToggle('new')"
      @newChatError="handleNewChatError"
    />
  </div>
</template>
