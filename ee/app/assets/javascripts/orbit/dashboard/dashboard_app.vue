<script>
import { computed, defineComponent } from 'vue';
import { GlButton, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { ERROR_POLICY_ALL } from '~/lib/graphql';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import memberNamespacesQuery from 'ee/orbit/graphql/queries/member_namespaces.query.graphql';
import { ENABLED_MEMBER_NAMESPACES_LIMIT } from 'ee/orbit/utils/namespace_limits';
import { isIndexing, keepLastIndexingStatus } from 'ee/orbit/utils/orbit_group_state';
import OrbitExploreEmptyState from 'ee/orbit/components/orbit_explore_empty_state.vue';
import {
  FEEDBACK_URL,
  GROUPS_POLL_INTERVAL_MS,
  ORBIT_TABS,
  ORBIT_TRIAL_STATE_ENDED,
  ROUTE_OVERVIEW,
  ROUTE_SCHEMA,
} from './constants';
import dashboardGroupsQuery from './graphql/dashboard_groups.query.graphql';
import ownedTrialsQuery from './graphql/owned_trials.query.graphql';
import OrbitTopAlerts from './orbit_top_alerts.vue';
import OverviewQuickstart from './overview/overview_quickstart.vue';

export default defineComponent({
  name: 'OrbitDashboardApp',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlIcon,
    GlLoadingIcon,
    LocalStorageSync,
    OrbitExploreEmptyState,
    OrbitTopAlerts,
    OverviewQuickstart,
  },
  inject: ['trialAvailable', 'currentUserId'],
  provide() {
    return {
      enabledMemberGroups: computed(() => this.enabledGroups),
      enabledGroupsCount: computed(() => this.enabledGroupsCount),
    };
  },
  props: {
    adminConfigurationPath: {
      type: String,
      required: false,
      default: null,
    },
    duoAccessible: {
      type: Boolean,
      required: true,
    },
    orbitSettingsEnabled: {
      type: Boolean,
      required: true,
    },
  },
  apollo: {
    enabledGroups: {
      query: dashboardGroupsQuery,
      variables: { first: ENABLED_MEMBER_NAMESPACES_LIMIT },
      // Keep the group list when Orbit errors on `orbit.indexingStatus` (down or rate
      // limited): the nodes still arrive, only the status is null.
      errorPolicy: ERROR_POLICY_ALL,
      update(data) {
        return keepLastIndexingStatus(data?.groups?.nodes ?? [], this.enabledGroups);
      },
      result({ data, loading }) {
        if (loading) return;

        this.enabledGroupsCount = data?.groups?.count ?? 0;
        this.enabledGroupsFailed = !data?.groups;
        if (!data?.groups) this.alertGroupsFailure();
      },
      error(error) {
        // With errorPolicy 'all', result() also gets GraphQL errors and alerts for them.
        if (error.graphQLErrors.length || this.hasEnabledGroups) return;

        this.enabledGroupsFailed = true;
        this.alertGroupsFailure(error);
      },
    },
    memberGroups: {
      query: memberNamespacesQuery,
      skip() {
        return !this.showEmptyStateRoute;
      },
      update: (data) => data.groups?.nodes ?? [],
      error(error) {
        createAlert({ message: s__('Orbit|Failed to load groups.'), error, captureError: true });
      },
    },
    ownedTrials: {
      query: ownedTrialsQuery,
      skip() {
        return !this.trialAvailable;
      },
      update: (data) => data.groups?.nodes ?? [],
      error(error) {
        // The server already logs GraphQL errors.
        if (!error.graphQLErrors.length) Sentry.captureException(error);
      },
    },
  },
  data() {
    return {
      enabledGroups: [],
      enabledGroupsCount: 0,
      enabledGroupsFailed: false,
      enabledGroupsAlerted: false,
      memberGroups: [],
      ownedTrials: [],
      quickstartClosed: false,
      documentHidden: document.hidden,
    };
  },
  computed: {
    // vue-apollo does not set loading for polls, so a poll keeps the rendered page.
    initialLoading() {
      return (
        this.$apollo.queries.enabledGroups.loading ||
        (this.showEmptyStateRoute && this.$apollo.queries.memberGroups.loading)
      );
    },
    hasEnabledGroups() {
      return this.enabledGroups.length > 0;
    },
    anyIndexing() {
      return this.enabledGroups.some(isIndexing);
    },
    // Only the Overview reads the indexing status, and each poll counts toward the Orbit limit.
    shouldPoll() {
      return this.anyIndexing && this.isOverviewRoute && !this.documentHidden;
    },
    hasEndedTrial() {
      return this.ownedTrials.some((group) => group.orbitTrial?.state === ORBIT_TRIAL_STATE_ENDED);
    },
    isOverviewRoute() {
      return this.$route.name === ROUTE_OVERVIEW;
    },
    showEmptyStateRoute() {
      return (
        !this.$apollo.queries.enabledGroups.loading &&
        !this.enabledGroupsFailed &&
        this.isOverviewRoute &&
        !this.hasEnabledGroups
      );
    },
    showRoutedPage() {
      return !this.isOverviewRoute || this.hasEnabledGroups;
    },
    fillsViewport() {
      return this.showEmptyStateRoute || this.$route.name === ROUTE_SCHEMA;
    },
    showSettings() {
      return Boolean(this.adminConfigurationPath);
    },
    quickstartOpen() {
      return !this.quickstartClosed;
    },
    quickstartStorageKey() {
      return `orbit-quickstart-closed:${this.currentUserId}`;
    },
    tabs() {
      return ORBIT_TABS.map((tab) => {
        const isActive = this.$route.name === tab.route;

        return { ...tab, isActive, trackingEvent: isActive ? null : tab.eventName };
      });
    },
  },
  watch: {
    shouldPoll(poll) {
      if (poll) this.$apollo.queries.enabledGroups.startPolling(GROUPS_POLL_INTERVAL_MS);
      else this.$apollo.queries.enabledGroups.stopPolling();
    },
  },
  mounted() {
    document.addEventListener('visibilitychange', this.onVisibilityChange);
  },
  beforeUnmount() {
    document.removeEventListener('visibilitychange', this.onVisibilityChange);
  },
  // Vue 2 + compat MODE 3 fires beforeDestroy on $destroy, not beforeUnmount.
  beforeDestroy() {
    document.removeEventListener('visibilitychange', this.onVisibilityChange);
  },
  methods: {
    onVisibilityChange() {
      this.documentHidden = document.hidden;
    },

    setQuickstartOpen(open) {
      this.quickstartClosed = !open;
    },

    closeQuickstart() {
      this.setQuickstartOpen(false);
      // The close button unmounts with the panel, so focus would fall to the page body.
      this.$nextTick(() => this.$refs.quickstartToggle.$el.focus());
    },

    alertGroupsFailure(error) {
      if (this.enabledGroupsAlerted) return;

      this.enabledGroupsAlerted = true;
      createAlert({
        message: s__('Orbit|Failed to load groups.'),
        error,
        captureError: Boolean(error),
      });
    },
  },
  feedbackUrl: FEEDBACK_URL,
});
</script>

<template>
  <div class="gl-flex gl-flex-col gl-pt-5" :class="{ 'orbit-app-fill-viewport': fillsViewport }">
    <local-storage-sync
      :storage-key="quickstartStorageKey"
      :value="quickstartClosed"
      @input="quickstartClosed = $event"
    />

    <gl-loading-icon
      v-if="initialLoading"
      size="lg"
      class="gl-mt-11"
      :label="s__('Orbit|Loading groups')"
    />

    <template v-else-if="showEmptyStateRoute">
      <orbit-top-alerts :enabled-groups="enabledGroups" :has-ended-trial="hasEndedTrial" />
      <orbit-explore-empty-state :available-groups="memberGroups" />
    </template>

    <!-- The Overview-only parts sit in wrappers that always render. Otherwise Vue 2 moves the
         tabs when they come and go, and the moved tab link loses keyboard focus. -->
    <template v-else>
      <div>
        <orbit-top-alerts
          v-if="isOverviewRoute"
          :enabled-groups="enabledGroups"
          :has-ended-trial="hasEndedTrial"
        />
      </div>

      <div class="gl-flex gl-flex-wrap gl-items-start gl-justify-between gl-gap-3">
        <h1 class="gl-heading-1 gl-mb-0 gl-mt-0">{{ s__('Orbit|Orbit') }}</h1>
        <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-4">
          <gl-button
            variant="link"
            :href="$options.feedbackUrl"
            target="_blank"
            rel="noopener noreferrer"
          >
            {{ s__('Orbit|Leave feedback') }} <gl-icon name="external-link" :size="12" />
          </gl-button>
          <gl-button
            v-if="showSettings"
            icon="settings"
            :href="adminConfigurationPath"
            data-testid="orbit-settings-btn"
          >
            {{ s__('Orbit|Settings') }}
          </gl-button>
          <gl-button
            v-if="isOverviewRoute"
            ref="quickstartToggle"
            category="secondary"
            icon="rocket-launch"
            :aria-controls="quickstartOpen ? 'orbit-quickstart' : null"
            :aria-expanded="String(quickstartOpen)"
            data-testid="orbit-quickstart-toggle"
            @click="setQuickstartOpen(!quickstartOpen)"
          >
            {{ s__('Orbit|Quickstart') }}
          </gl-button>
        </div>
      </div>

      <div>
        <overview-quickstart
          v-if="isOverviewRoute && quickstartOpen"
          class="gl-mt-4"
          :duo-accessible="duoAccessible"
          :orbit-settings-enabled="orbitSettingsEnabled"
          :indexing="anyIndexing"
          @close="closeQuickstart"
        />
      </div>

      <div class="gl-border-b gl-mt-3 gl-border-default">
        <ul class="nav gl-tabs-nav">
          <li v-for="tab in tabs" :key="tab.route" class="nav-item">
            <router-link
              :to="{ name: tab.route }"
              exact-path
              class="nav-link gl-tab-nav-item"
              :class="{ 'gl-tab-nav-item-active active': tab.isActive }"
              :data-event-tracking="tab.trackingEvent"
            >
              {{ tab.label }}
            </router-link>
          </li>
        </ul>
      </div>

      <router-view v-if="showRoutedPage" />
    </template>
  </div>
</template>
