<script>
import EMPTY_SVG_URL from '@gitlab/svgs/dist/illustrations/empty-state/empty-ai-catalog-md.svg?url';
import { GlTabs, GlTab } from '@gitlab/ui';
import { fetchPolicies } from '~/lib/graphql';
import { InternalEvents } from '~/tracking';
import { __, s__, sprintf } from '~/locale';
import { convertToGraphQLId } from '~/graphql_shared/utils';
import ErrorsAlert from '~/vue_shared/components/errors_alert.vue';
import { TYPENAME_PROJECT, TYPENAME_GROUP } from '~/graphql_shared/constants';
import {
  VISIBILITY_LEVEL_PUBLIC_STRING,
  VISIBILITY_LEVEL_PRIVATE_STRING,
} from '~/visibility_level/constants';
import AiCatalogListHeader from 'ee/ai/catalog/components/ai_catalog_list_header.vue';
import AiCatalogListWrapper from 'ee/ai/catalog/components/ai_catalog_list_wrapper.vue';
import aiCatalogGroupUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_group_user_permissions.query.graphql';
import aiCatalogProjectUserPermissionsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_project_user_permissions.query.graphql';
import {
  AI_CATALOG_CONSUMER_TYPE_GROUP,
  AI_CATALOG_CONSUMER_TYPE_PROJECT,
  AI_CATALOG_CONSUMER_LABELS,
  AI_CATALOG_TYPE_FLOW,
  FLOW_VISIBILITY_LEVEL_DESCRIPTIONS,
  PAGE_SIZE,
  TRACK_EVENT_TYPE_FLOW,
  TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED,
  TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_CATALOG,
} from 'ee/ai/catalog/constants';
import { AI_CATALOG_FLOWS_SHOW_ROUTE } from 'ee/ai/catalog/router/constants';
import projectAiCatalogFlowsQuery from 'ee/ai/duo_agents_platform/graphql/queries/get_project_flows.query.graphql';
import aiCatalogFlowsQuery from 'ee/ai/catalog/graphql/queries/ai_catalog_flows.query.graphql';
import AiCatalogConfiguredItemsWrapper from 'ee/ai/duo_agents_platform/components/catalog/ai_catalog_configured_items_wrapper.vue';

export default {
  name: 'AiFlowsIndex',
  components: {
    GlTabs,
    GlTab,
    ErrorsAlert,
    AiCatalogListHeader,
    AiCatalogListWrapper,
    AiCatalogConfiguredItemsWrapper,
  },
  mixins: [InternalEvents.mixin()],
  inject: {
    isProjectNamespace: {},
    groupPath: {
      default: null,
    },
    projectId: {
      default: null,
    },
    projectPath: {
      default: null,
    },
    exploreAiCatalogFlowsPath: {
      default: '',
    },
    rootGroupId: {
      default: null,
    },
    groupId: {
      default: null,
    },
  },
  apollo: {
    aiFlows: {
      query: projectAiCatalogFlowsQuery,
      skip() {
        return (
          !this.projectPath || this.selectedTabIndex !== this.$options.PROJECT_TAB_INDICES.MANAGED
        );
      },
      variables() {
        const effectiveGroupId = this.projectId ? this.rootGroupId : this.groupId;

        return {
          projectPath: this.projectPath,
          search: this.searchTerm,
          projectId: convertToGraphQLId(TYPENAME_PROJECT, this.projectId),
          groupId: convertToGraphQLId(TYPENAME_GROUP, effectiveGroupId),
          ...this.paginationVariables,
        };
      },
      // fetchPolicy needed to refresh items after creating an item
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      update: (data) => data?.project?.aiCatalogItems?.nodes || [],
      result({ data }) {
        this.pageInfo = data?.project?.aiCatalogItems?.pageInfo || {};
      },
      error() {
        this.errors = [s__('AICatalog|There was a problem fetching flows.')];
      },
    },
    aiCatalogFlows: {
      query: aiCatalogFlowsQuery,
      skip() {
        return this.selectedTabIndex !== this.$options.PROJECT_TAB_INDICES.CATALOG;
      },
      variables() {
        return {
          ...this.paginationVariables,
          search: this.searchTerm,
        };
      },
      fetchPolicy: fetchPolicies.CACHE_AND_NETWORK,
      update: (data) => data?.aiCatalogItems?.nodes || [],
      result({ data }) {
        this.pageInfo = data?.aiCatalogItems?.pageInfo || {};
      },
      error() {
        this.errors = [s__('AICatalog|There was a problem fetching flows.')];
      },
    },
    groupUserPermissions: {
      query: aiCatalogGroupUserPermissionsQuery,
      skip() {
        return !this.groupPath;
      },
      variables() {
        return {
          fullPath: this.groupPath,
        };
      },
      update: (data) => data.group?.userPermissions || {},
    },
    projectUserPermissions: {
      query: aiCatalogProjectUserPermissionsQuery,
      skip() {
        return !this.projectPath;
      },
      variables() {
        return {
          fullPath: this.projectPath,
        };
      },
      update: (data) => data.project?.userPermissions || {},
    },
  },
  data() {
    return {
      aiFlows: [],
      aiCatalogFlows: [],
      groupUserPermissions: {},
      projectUserPermissions: {},
      errors: [],
      errorTitle: null,
      pageInfo: {},
      paginationVariables: {
        before: null,
        after: null,
        first: PAGE_SIZE,
        last: null,
      },
      selectedTabIndex: this.$options.PROJECT_TAB_INDICES.ENABLED,
      searchTerm: '',
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.aiFlows.loading;
    },
    isCatalogLoading() {
      return this.$apollo.queries.aiCatalogFlows.loading;
    },
    namespaceTypeLabel() {
      return this.isProjectNamespace
        ? AI_CATALOG_CONSUMER_LABELS[AI_CATALOG_CONSUMER_TYPE_PROJECT]
        : AI_CATALOG_CONSUMER_LABELS[AI_CATALOG_CONSUMER_TYPE_GROUP];
    },
    userPermissions() {
      return this.isProjectNamespace ? this.projectUserPermissions : this.groupUserPermissions;
    },
    itemTypeConfig() {
      return {
        showRoute: AI_CATALOG_FLOWS_SHOW_ROUTE,
        visibilityTooltip: {
          [VISIBILITY_LEVEL_PUBLIC_STRING]:
            FLOW_VISIBILITY_LEVEL_DESCRIPTIONS[VISIBILITY_LEVEL_PUBLIC_STRING],
          [VISIBILITY_LEVEL_PRIVATE_STRING]:
            FLOW_VISIBILITY_LEVEL_DESCRIPTIONS[VISIBILITY_LEVEL_PRIVATE_STRING],
        },
      };
    },
    itemTypeConfigEnabled() {
      return {
        disableActionItem: {
          showActionItem: () => this.userPermissions?.adminAiCatalogItemConsumer || false,
          text: __('Disable'),
        },
        ...this.itemTypeConfig,
      };
    },
    itemTypeConfigManaged() {
      return {
        showStatusBadge: true,
        ...this.itemTypeConfig,
      };
    },
    disableConfirmTitle() {
      return sprintf(s__('AICatalog|Disable flow from this %{namespaceType}'), {
        namespaceType: this.namespaceTypeLabel,
      });
    },
    disableConfirmMessage() {
      if (this.isProjectNamespace) {
        return s__(
          'AICatalog|Are you sure you want to disable flow %{name}? The flow, its service account, and any associated triggers will no longer work in this project.',
        );
      }

      return s__(
        'AICatalog|Are you sure you want to disable flow %{name}? The flow will also be disabled from any projects in this group.',
      );
    },
    emptyStateTitle() {
      return sprintf(s__('AICatalog|Use flows in your %{namespaceType}.'), {
        namespaceType: this.namespaceTypeLabel,
      });
    },
    emptyStateDescription() {
      return s__('AICatalog|Flows use multiple agents to complete tasks automatically.');
    },
    emptyStateButtonText() {
      return s__('AICatalog|Explore the AI Catalog');
    },
  },
  methods: {
    resetPagination() {
      this.paginationVariables = {
        before: null,
        after: null,
        first: PAGE_SIZE,
        last: null,
      };
    },
    handleNextPage() {
      this.paginationVariables = {
        before: null,
        after: this.pageInfo.endCursor,
        first: PAGE_SIZE,
        last: null,
      };
    },
    handlePrevPage() {
      this.paginationVariables = {
        after: null,
        before: this.pageInfo.startCursor,
        first: null,
        last: PAGE_SIZE,
      };
    },
    handleSearch(filters) {
      [this.searchTerm] = filters;
    },
    handleClearSearch() {
      this.searchTerm = '';
    },
    handleError({ title, errors }) {
      this.errorTitle = title;
      this.errors = errors;
    },
    dismissErrors() {
      this.errors = [];
      this.errorTitle = null;
    },
    onClickManagedTab() {
      this.resetPagination();
      if (this.selectedTabIndex !== this.$options.PROJECT_TAB_INDICES.MANAGED) {
        this.trackEvent(TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_MANAGED, {
          label: TRACK_EVENT_TYPE_FLOW,
        });
      }
    },
    onClickCatalogTab() {
      this.resetPagination();
      if (this.selectedTabIndex !== this.$options.PROJECT_TAB_INDICES.CATALOG) {
        this.trackEvent(TRACK_EVENT_VIEW_AI_CATALOG_PROJECT_CATALOG, {
          label: TRACK_EVENT_TYPE_FLOW,
        });
      }
    },
  },
  itemTypes: [AI_CATALOG_TYPE_FLOW],
  PROJECT_TAB_INDICES: {
    ENABLED: 0,
    MANAGED: 1,
    CATALOG: 2,
  },
  EMPTY_SVG_URL,
};
</script>

<template>
  <div>
    <ai-catalog-list-header
      :heading="s__('AICatalog|Flows')"
      :can-admin="userPermissions.adminAiCatalogItem"
      new-button-variant="default"
    />
    <errors-alert class="gl-mt-5" :title="errorTitle" :errors="errors" @dismiss="dismissErrors" />

    <gl-tabs v-if="isProjectNamespace" v-model="selectedTabIndex" content-class="gl-py-0">
      <gl-tab :title="__('Enabled')">
        <ai-catalog-configured-items-wrapper
          :disable-confirm-title="disableConfirmTitle"
          :disable-confirm-message="disableConfirmMessage"
          :empty-state-title="emptyStateTitle"
          :empty-state-description="emptyStateDescription"
          :empty-state-button-text="emptyStateButtonText"
          :item-types="$options.itemTypes"
          :item-type-config="itemTypeConfigEnabled"
          @empty-state-click="selectedTabIndex = $options.PROJECT_TAB_INDICES.CATALOG"
          @error="handleError"
        />
      </gl-tab>
      <gl-tab :title="s__('AICatalog|Managed')" lazy @click="onClickManagedTab">
        <ai-catalog-list-wrapper
          :is-loading="isLoading"
          :items="aiFlows"
          :item-type-config="itemTypeConfigManaged"
          :page-info="pageInfo"
          :empty-state-title="emptyStateTitle"
          :empty-state-description="emptyStateDescription"
          :empty-state-button-text="emptyStateButtonText"
          :disable-confirm-title="disableConfirmTitle"
          :disable-confirm-message="disableConfirmMessage"
          :search-term="searchTerm"
          data-testid="managed-flows-list"
          @empty-state-click="selectedTabIndex = $options.PROJECT_TAB_INDICES.CATALOG"
          @next-page="handleNextPage"
          @prev-page="handlePrevPage"
          @search="handleSearch"
          @clear-search="handleClearSearch"
        />
      </gl-tab>
      <gl-tab :title="s__('AICatalog|AI Catalog')" lazy @click="onClickCatalogTab">
        <ai-catalog-list-wrapper
          :is-loading="isCatalogLoading"
          :items="aiCatalogFlows"
          :item-type-config="itemTypeConfig"
          :page-info="pageInfo"
          :search-term="searchTerm"
          data-testid="catalog-flows-list"
          @next-page="handleNextPage"
          @prev-page="handlePrevPage"
          @search="handleSearch"
          @clear-search="handleClearSearch"
        />
      </gl-tab>
    </gl-tabs>
    <ai-catalog-configured-items-wrapper
      v-else
      :disable-confirm-title="disableConfirmTitle"
      :disable-confirm-message="disableConfirmMessage"
      :empty-state-title="emptyStateTitle"
      :empty-state-description="emptyStateDescription"
      :empty-state-button-href="exploreAiCatalogFlowsPath"
      :empty-state-button-text="emptyStateButtonText"
      :item-types="$options.itemTypes"
      :item-type-config="itemTypeConfigEnabled"
      @error="handleError"
    />
  </div>
</template>
