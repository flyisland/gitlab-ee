import { s__, sprintf } from '~/locale';

import {
  AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG,
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  AGENT_VISIBILITY_LEVEL_DESCRIPTIONS,
  FLOW_VISIBILITY_LEVEL_DESCRIPTIONS,
  TRACK_EVENT_TYPE_AGENT,
  TRACK_EVENT_TYPE_FLOW,
} from 'ee/ai/catalog/constants';
import AiCatalogAgentForm from './components/ai_catalog_agent_form.vue';
import AiCatalogFlowForm from './components/ai_catalog_flow_form.vue';
import {
  AI_CATALOG_AGENTS_SHOW_ROUTE,
  AI_CATALOG_AGENTS_ROUTE,
  AI_CATALOG_AGENTS_DUPLICATE_ROUTE,
  AI_CATALOG_AGENTS_EDIT_ROUTE,
  AI_CATALOG_FLOWS_SHOW_ROUTE,
  AI_CATALOG_FLOWS_ROUTE,
  AI_CATALOG_FLOWS_DUPLICATE_ROUTE,
  AI_CATALOG_FLOWS_EDIT_ROUTE,
} from './router/constants';

export const itemTypeValidator = (type) =>
  [AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_FLOW].includes(type);

const AGENT_CONFIG = {
  label: s__('AICatalog|agent'),
  pluralLabel: s__('AICatalog|agents'),
  pageTitle: s__('AICatalog|Agents'),
  formComponent: AiCatalogAgentForm,
  mutations: AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG[AI_CATALOG_TYPE_AGENT].mutations,
  queries: AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG[AI_CATALOG_TYPE_AGENT].queries,
  acceptedTypes: [AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_THIRD_PARTY_FLOW],
  errorMessage: s__('AICatalog|Agent does not exist'),
  notFoundTitle: s__('AICatalog|Agent not found.'),
  trackLabel: TRACK_EVENT_TYPE_AGENT,
  create: {
    heading: s__('AICatalog|New agent'),
    description: s__(
      'AICatalog|Use agents with GitLab Duo Chat to complete tasks and answer complex questions.',
    ),
    createdMessage: s__('AICatalog|Agent created.'),
    errorMessage: s__(
      'AICatalog|Could not create agent in the project. Check that the project meets the %{linkStart}prerequisites%{linkEnd} and try again.',
    ),
    showBadge: false,
  },
  edit: {
    heading: s__('AICatalog|Edit agent'),
    description: s__('AICatalog|Manage agent settings.'),
    showBadge: false,
    updatedMessage: s__('AICatalog|Agent updated.'),
    errorMessage: s__('AICatalog|Could not update agent. Try again.'),
    versionWarningMessage: s__(
      'AICatalog|To prevent versioning issues, you can edit only the latest version of this agent. To edit an earlier version, %{linkStart}duplicate the agent%{linkEnd}.',
    ),
    buildInitialValues: (item) => ({
      projectId: item.project?.id,
      name: item.name,
      description: item.description,
      systemPrompt: item.latestVersion.systemPrompt,
      tools: (item.latestVersion.tools?.nodes ?? []).map((t) => t.id),
      mcpTools: item.latestVersion.mcpTools ?? [],
      mcpServers: (item.latestVersion.mcpServers?.nodes ?? []).map((s) => s.id),
      definition: item.latestVersion.definition,
      public: item.public,
      itemType: item.itemType,
    }),
  },
  duplicate: {
    heading: s__('AICatalog|Duplicate agent'),
    description: s__('AICatalog|Create a copy of this agent with the same configuration.'),
    createdMessage: s__('AICatalog|Agent created.'),
    errorMessage: s__(
      'AICatalog|Could not create agent in the project. Check that the project meets the %{linkStart}prerequisites%{linkEnd} and try again.',
    ),
    showBadge: false,
    buildInitialValues: (item, { activeVersion }) => ({
      name: sprintf(s__('AICatalog|Copy of %{name}'), { name: item.name }),
      description: item.description,
      systemPrompt: activeVersion.systemPrompt,
      tools: (activeVersion.tools?.nodes ?? []).map((t) => t.id),
      mcpTools: activeVersion.mcpTools ?? [],
      mcpServers: (activeVersion.mcpServers?.nodes ?? []).map((s) => s.id),
      definition: activeVersion.definition,
      public: false,
      itemType: item.itemType,
    }),
  },
  show: {
    showBetaBadge: () => false,
    enableErrorTitle: s__('AICatalog|Could not enable agent'),
    enableToastTemplate: s__('AICatalog|Agent enabled in %{name}.'),
    enableErrorTemplate: s__(
      'AICatalog|Could not enable agent in the %{target}. Check that the %{target} meets the %{linkStart}prerequisites%{linkEnd} and try again.',
    ),
    disableToast: s__('AICatalog|Agent disabled in this project.'),
    disableErrorTemplate: s__('AICatalog|Failed to disable agent. %{error}'),
    disableConfirmMessage: s__(
      'AICatalog|Are you sure you want to disable agent %{name}? The agent will no longer work in this project.',
    ),
    hardDeletedToast: s__('AICatalog|Agent deleted.'),
    softDeletedToast: s__('AICatalog|Agent hidden.'),
    deleteErrorTemplate: s__('AICatalog|Failed to delete agent. %{error}'),
    reportErrorTemplate: s__('AICatalog|Failed to report agent. %{error}'),
  },
  routes: {
    show: AI_CATALOG_AGENTS_SHOW_ROUTE,
    list: AI_CATALOG_AGENTS_ROUTE,
    duplicate: AI_CATALOG_AGENTS_DUPLICATE_ROUTE,
    edit: AI_CATALOG_AGENTS_EDIT_ROUTE,
  },
  platformIndex: {
    heading: s__('AICatalog|Agents'),
    explorePathKey: 'exploreAiCatalogAgentsPath',
    errorMessage: s__('AICatalog|There was a problem fetching agents.'),
    managedItemsUpdate: (data) => {
      return (data?.project?.aiCatalogItems?.nodes || []).map((item) => {
        if (!item.configurationForProject) return item;
        const latest = item.latestVersion.versionName;
        const pinned = item.configurationForProject.pinnedItemVersion.versionName;
        return { ...item, isUpdateAvailable: latest !== pinned };
      });
    },
    disableConfirmTitleTemplate: s__('AICatalog|Disable agent from this %{namespaceType}'),
    disableConfirmMessageProject: s__(
      'AICatalog|Are you sure you want to disable agent %{name}? The agent will no longer work in this project.',
    ),
    disableConfirmMessageGroup: s__(
      'AICatalog|Are you sure you want to disable agent %{name}? The agent will also be disabled from any projects in this group.',
    ),
    emptyStateTitleTemplate: s__('AICatalog|Use agents in your %{namespaceType}.'),
    emptyStateDescription: s__('AICatalog|Use agents to automate tasks and answer questions.'),
    showActionItem: (item, canAdminConsumer) => canAdminConsumer && !item.foundational,
  },
  index: {
    errorMessage: s__('AICatalog|There was a problem fetching agents.'),
  },
  visibilityDescriptions: AGENT_VISIBILITY_LEVEL_DESCRIPTIONS,
};

const ITEM_TYPE_REGISTRY = {
  [AI_CATALOG_TYPE_AGENT]: AGENT_CONFIG,
  [AI_CATALOG_TYPE_FLOW]: {
    label: s__('AICatalog|flow'),
    pluralLabel: s__('AICatalog|flows'),
    pageTitle: s__('AICatalog|Flows'),
    formComponent: AiCatalogFlowForm,
    mutations: AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG[AI_CATALOG_TYPE_FLOW].mutations,
    queries: AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG[AI_CATALOG_TYPE_FLOW].queries,
    acceptedTypes: [AI_CATALOG_TYPE_FLOW],
    errorMessage: s__('AICatalog|Flow does not exist'),
    notFoundTitle: s__('AICatalog|Flow not found.'),
    trackLabel: TRACK_EVENT_TYPE_FLOW,
    create: {
      heading: s__('AICatalog|New flow'),
      description: s__('AICatalog|Use flows to automate complex, multi-step tasks.'),
      createdMessage: s__('AICatalog|Flow created.'),
      errorMessage: s__(
        'AICatalog|Could not create flow in the project. Check that the project meets the %{linkStart}prerequisites%{linkEnd} and try again.',
      ),
      showBadge: true,
    },
    edit: {
      heading: s__('AICatalog|Edit flow'),
      description: s__('AICatalog|Manage flow settings.'),
      showBadge: true,
      updatedMessage: s__('AICatalog|Flow updated.'),
      errorMessage: s__('AICatalog|Could not update flow. Try again.'),
      versionWarningMessage: s__(
        'AICatalog|To prevent versioning issues, you can edit only the latest version of this flow. To edit an earlier version, %{linkStart}duplicate the flow%{linkEnd}.',
      ),
      buildInitialValues: (item) => ({
        projectId: item.project?.id,
        name: item.name,
        description: item.description,
        public: item.public,
        definition: item.latestVersion.definition,
      }),
    },
    duplicate: {
      heading: s__('AICatalog|Duplicate flow'),
      description: s__('AICatalog|Duplicate this flow with all its settings and configuration.'),
      createdMessage: s__('AICatalog|Flow created.'),
      errorMessage: s__(
        'AICatalog|Could not create flow in the project. Check that the project meets the %{linkStart}prerequisites%{linkEnd} and try again.',
      ),
      showBadge: true,
      buildInitialValues: (item, { activeVersion }) => ({
        name: sprintf(s__('AICatalog|Copy of %{name}'), { name: item.name }),
        public: false,
        description: item.description,
        definition: activeVersion.definition,
      }),
    },
    show: {
      showBetaBadge: (item) => !item.foundational,
      enableErrorTitle: s__('AICatalog|Could not enable flow'),
      enableToastTemplate: s__('AICatalog|Flow enabled in %{name}.'),
      enableErrorTemplate: s__(
        'AICatalog|Could not enable flow in the %{target}. Check that the %{target} meets the %{linkStart}prerequisites%{linkEnd} and try again.',
      ),
      disableToast: s__('AICatalog|Flow disabled in this project.'),
      disableErrorTemplate: s__('AICatalog|Failed to disable flow. %{error}'),
      disableConfirmMessage: s__(
        'AICatalog|Are you sure you want to disable flow %{name}? The flow, its service account, and any associated triggers will no longer work in this project.',
      ),
      hardDeletedToast: s__('AICatalog|Flow deleted.'),
      softDeletedToast: s__('AICatalog|Flow hidden.'),
      deleteErrorTemplate: s__('AICatalog|Failed to delete flow. %{error}'),
      reportErrorTemplate: s__('AICatalog|Failed to report flow. %{error}'),
    },
    routes: {
      show: AI_CATALOG_FLOWS_SHOW_ROUTE,
      list: AI_CATALOG_FLOWS_ROUTE,
      duplicate: AI_CATALOG_FLOWS_DUPLICATE_ROUTE,
      edit: AI_CATALOG_FLOWS_EDIT_ROUTE,
    },
    platformIndex: {
      heading: s__('AICatalog|Flows'),
      explorePathKey: 'exploreAiCatalogFlowsPath',
      errorMessage: s__('AICatalog|There was a problem fetching flows.'),
      managedItemsUpdate: (data) => data?.project?.aiCatalogItems?.nodes || [],
      disableConfirmTitleTemplate: s__('AICatalog|Disable flow from this %{namespaceType}'),
      disableConfirmMessageProject: s__(
        'AICatalog|Are you sure you want to disable flow %{name}? The flow, its service account, and any associated triggers will no longer work in this project.',
      ),
      disableConfirmMessageGroup: s__(
        'AICatalog|Are you sure you want to disable flow %{name}? The flow will also be disabled from any projects in this group.',
      ),
      emptyStateTitleTemplate: s__('AICatalog|Use flows in your %{namespaceType}.'),
      emptyStateDescription: s__(
        'AICatalog|Flows use multiple agents to complete tasks automatically.',
      ),
      showActionItem: (_item, canAdminConsumer) => canAdminConsumer,
    },
    index: {
      errorMessage: s__('AICatalog|There was a problem fetching flows.'),
    },
    visibilityDescriptions: FLOW_VISIBILITY_LEVEL_DESCRIPTIONS,
  },
  [AI_CATALOG_TYPE_THIRD_PARTY_FLOW]: {
    ...AGENT_CONFIG,
    mutations: AI_CATALOG_ITEM_TYPE_APOLLO_CONFIG[AI_CATALOG_TYPE_THIRD_PARTY_FLOW].mutations,
  },
};

export const getRegistryItem = (type) => {
  const config = ITEM_TYPE_REGISTRY[type];
  if (!config) {
    throw new Error(`Unknown AI catalog item type: ${type}`);
  }
  return config;
};
