<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import enabledMemberNamespacesQuery from '../graphql/queries/enabled_member_namespaces.query.graphql';
import ConnectSection from './connect_section.vue';
import AdminConfigureButton from './admin_configure_button.vue';
import GroupsConfigureButton from './groups_configure_button.vue';

const CONNECT_VISIBLE_KEY = 'orbit-connect-visible';

const CONFIGURE_VISIBLE_ROUTES = ['explore', 'schema'];

export default defineComponent({
  name: 'OrbitApp',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    ConnectSection,
    AdminConfigureButton,
    GroupsConfigureButton,
  },
  tabs: [
    { route: 'explore', label: s__('Orbit|Explore') },
    { route: 'schema', label: s__('Orbit|Schema') },
  ],
  props: {
    configureMode: {
      type: String,
      required: false,
      default: null,
    },
    adminConfigurationPath: {
      type: String,
      required: false,
      default: null,
    },
    agenticChatAvailable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  apollo: {
    enabledMemberGroups: {
      query: enabledMemberNamespacesQuery,
      variables: { first: 100 },
      update(data) {
        return data?.groups?.nodes || [];
      },
    },
  },
  data() {
    return {
      enabledMemberGroups: [],
      connectVisible: localStorage.getItem(CONNECT_VISIBLE_KEY) !== 'false',
    };
  },
  computed: {
    enabledMemberGroupsLoading() {
      return this.$apollo.queries.enabledMemberGroups.loading;
    },
    hasEnabledGroups() {
      return this.enabledMemberGroups.length > 0;
    },
    isExploreEmptyState() {
      return (
        this.$route.name === 'explore' && !this.enabledMemberGroupsLoading && !this.hasEnabledGroups
      );
    },
    showChrome() {
      return !this.isExploreEmptyState;
    },
    isConfigureRoute() {
      return CONFIGURE_VISIBLE_ROUTES.includes(this.$route.name);
    },
    showAdminConfigure() {
      return this.isConfigureRoute && this.configureMode === 'admin' && this.adminConfigurationPath;
    },
    showGroupsConfigure() {
      return this.isConfigureRoute && this.configureMode === 'groups';
    },
  },
  watch: {
    connectVisible(visible) {
      localStorage.setItem(CONNECT_VISIBLE_KEY, String(visible));
    },
  },
  methods: {
    toggleConnect() {
      this.connectVisible = !this.connectVisible;
    },
  },
});
</script>

<template>
  <div class="orbit-app gl-flex gl-flex-col gl-gap-5 gl-py-7">
    <div v-if="showChrome" class="gl-flex gl-flex-col gl-gap-2">
      <div class="gl-flex gl-items-center gl-justify-between gl-gap-3">
        <h1 class="gl-heading-1 gl-m-0">
          {{ s__('Orbit|Orbit') }}
        </h1>
        <div class="gl-flex gl-items-center gl-gap-3">
          <gl-button
            v-if="!connectVisible"
            size="small"
            icon="connected"
            category="tertiary"
            data-testid="toggle-connect"
            @click="toggleConnect"
          >
            {{ s__('Orbit|Connect to Orbit') }}
          </gl-button>
          <admin-configure-button
            v-if="showAdminConfigure"
            :admin-configuration-path="adminConfigurationPath"
          />
          <groups-configure-button v-else-if="showGroupsConfigure" />
        </div>
      </div>

      <connect-section
        v-if="connectVisible"
        class="gl-mt-3 gl-w-full gl-shrink-0"
        :agentic-chat-available="agenticChatAvailable"
        @close="toggleConnect"
      />

      <div class="gl-tabs-wrapper">
        <ul class="nav gl-tabs-nav">
          <li v-for="tab in $options.tabs" :key="tab.route" class="nav-item">
            <router-link
              :to="{ name: tab.route }"
              class="nav-link gl-tab-nav-item"
              :class="{ 'gl-tab-nav-item-active active': $route.name === tab.route }"
            >
              {{ tab.label }}
            </router-link>
          </li>
        </ul>
      </div>
    </div>
    <router-view />
  </div>
</template>
