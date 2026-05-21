import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import createDefaultClient from '~/lib/graphql';
import { ACCESS_LEVEL_EVERYONE_INTEGER, AVAILABILITY_OPTIONS } from './constants';

Vue.use(VueApollo);

const apolloProvider = new VueApollo({
  defaultClient: createDefaultClient(),
});

const sanitizedInt = (value) => parseInt(value, 10) || ACCESS_LEVEL_EVERYONE_INTEGER;

const parseOptionalJson = (value) => {
  if (!value) return null;

  try {
    return convertObjectPropsToCamelCase(JSON.parse(value), { deep: true });
  } catch {
    return null;
  }
};

export const initAiSettings = (id, component, options = {}) => {
  const el = document.getElementById(id);

  if (!el) {
    return false;
  }

  const {
    exposeDuoAgentPlatformServiceUrl,
    canManageSelfHostedModels,
    canConfigureAiLogging,
    duoAvailabilityCascadingSettings,
    duoRemoteFlowsCascadingSettings,
    duoFoundationalFlowsCascadingSettings,
    duoCustomAgentsCascadingSettings,
    duoCustomFlowsCascadingSettings,
    duoExternalAgentsCascadingSettings,
    toolApprovalForSessionCascadingSettings,
    toolApprovalForSessionAvailability,
    duoAvailability,
    areDuoSettingsLocked,
    experimentFeaturesEnabled,
    duoCoreFeaturesEnabled,
    duoRemoteFlowsAvailability,
    duoFoundationalFlowsAvailability,
    duoCustomAgentsAvailability,
    duoCustomFlowsAvailability,
    duoExternalAgentsAvailability,
    duoWorkflowsDefaultImageRegistry,
    promptCacheEnabled,
    redirectPath,
    updateId,
    duoProVisible,
    disabledDirectConnectionMethod,
    showEarlyAccessBanner,
    earlyAccessPath,
    betaSelfHostedModelsEnabled,
    toggleBetaModelsPath,
    amazonQAvailable,
    amazonQAutoReviewEnabled,
    onGeneralSettingsPage,
    areExperimentSettingsAllowed,
    arePromptCacheSettingsAllowed,
    enabledExpandedLogging,
    duoChatExpirationDays,
    duoChatExpirationColumn,
    duoWorkflowMcpEnabled,
    duoWorkflowMcpAvailable,
    aiUsageDataCollectionAvailable,
    aiUsageDataCollectionEnabled,
    aiCatalogRestrictedToGroupHierarchy,
    duoWorkflowAvailable,
    promptInjectionProtectionLevel,
    promptInjectionProtectionAvailable,
    isSaas,
    foundationalAgentsDefaultEnabled,
    showFoundationalAgentsAvailability,
    showFoundationalAgentsPerAgentAvailability,
    showDuoAgentPlatformEnablementSetting,
    foundationalAgentsStatuses,
    availableFoundationalFlows,
    selectedFoundationalFlowReferences,
    duoAgentPlatformEnabled,
    duoCliEnabled,
    duoCliEnabledSettingFeatureFlag,
    namespaceAccessRules,
    parentPath,
    aiMinimumAccessLevelToExecute,
    aiMinimumAccessLevelToExecuteAsync,
    duoTemplateProject,
    rootNamespaceId,
    groupFullPath,
    includeRecommendedAllowed,
    allowAllUnixSockets,
    allowProjectExtension,
  } = el.dataset;

  const namespaceAccessRulesParsed = parseOptionalJson(namespaceAccessRules);
  const duoAvailabilityCascadingSettingsParsed = parseOptionalJson(
    duoAvailabilityCascadingSettings,
  );
  const duoRemoteFlowsCascadingSettingsParsed = parseOptionalJson(duoRemoteFlowsCascadingSettings);
  const duoFoundationalFlowsCascadingSettingsParsed = parseOptionalJson(
    duoFoundationalFlowsCascadingSettings,
  );
  const duoCustomAgentsCascadingSettingsParsed = parseOptionalJson(
    duoCustomAgentsCascadingSettings,
  );
  const duoCustomFlowsCascadingSettingsParsed = parseOptionalJson(duoCustomFlowsCascadingSettings);
  const duoExternalAgentsCascadingSettingsParsed = parseOptionalJson(
    duoExternalAgentsCascadingSettings,
  );
  const toolApprovalForSessionCascadingSettingsParsed = parseOptionalJson(
    toolApprovalForSessionCascadingSettings,
  );

  const parsedFoundationalAgentsStatuses = foundationalAgentsStatuses
    ? convertObjectPropsToCamelCase(JSON.parse(foundationalAgentsStatuses), {
        deep: true,
      }).map((agent) => ({
        ...agent,
        enabled: agent.enabled === null ? null : parseBoolean(agent.enabled),
      }))
    : [];

  return new Vue({
    el,
    apolloProvider,
    provide: {
      exposeDuoAgentPlatformServiceUrl: parseBoolean(exposeDuoAgentPlatformServiceUrl),
      canManageSelfHostedModels: parseBoolean(canManageSelfHostedModels),
      canConfigureAiLogging: parseBoolean(canConfigureAiLogging),
      duoAvailabilityCascadingSettings: duoAvailabilityCascadingSettingsParsed,
      duoRemoteFlowsCascadingSettings: duoRemoteFlowsCascadingSettingsParsed,
      duoFoundationalFlowsCascadingSettings: duoFoundationalFlowsCascadingSettingsParsed,
      duoCustomAgentsCascadingSettings: duoCustomAgentsCascadingSettingsParsed,
      duoCustomFlowsCascadingSettings: duoCustomFlowsCascadingSettingsParsed,
      duoExternalAgentsCascadingSettings: duoExternalAgentsCascadingSettingsParsed,
      toolApprovalForSessionCascadingSettings:
        toolApprovalForSessionCascadingSettingsParsed || null,
      areDuoSettingsLocked: parseBoolean(areDuoSettingsLocked),
      duoAvailability,
      experimentFeaturesEnabled: parseBoolean(experimentFeaturesEnabled),
      duoCoreFeaturesEnabled: parseBoolean(duoCoreFeaturesEnabled),
      promptCacheEnabled: parseBoolean(promptCacheEnabled),
      disabledDirectConnectionMethod: parseBoolean(disabledDirectConnectionMethod),
      showEarlyAccessBanner: parseBoolean(showEarlyAccessBanner),
      duoWorkflowMcpEnabled: parseBoolean(duoWorkflowMcpEnabled),
      duoWorkflowMcpAvailable: parseBoolean(duoWorkflowMcpAvailable),
      duoWorkflowAvailable: parseBoolean(duoWorkflowAvailable),
      promptInjectionProtectionLevel,
      promptInjectionProtectionAvailable: parseBoolean(promptInjectionProtectionAvailable),
      betaSelfHostedModelsEnabled: parseBoolean(betaSelfHostedModelsEnabled),
      foundationalAgentsDefaultEnabled: parseBoolean(foundationalAgentsDefaultEnabled),
      showFoundationalAgentsAvailability: parseBoolean(showFoundationalAgentsAvailability),
      showFoundationalAgentsPerAgentAvailability: parseBoolean(
        showFoundationalAgentsPerAgentAvailability,
      ),
      showDuoAgentPlatformEnablementSetting: parseBoolean(showDuoAgentPlatformEnablementSetting),
      initialFoundationalAgentsStatuses: parsedFoundationalAgentsStatuses,
      initialDuoAgentPlatformEnabled: parseBoolean(duoAgentPlatformEnabled),
      initialDuoCliEnabled: parseBoolean(duoCliEnabled),
      duoCliEnabledSettingFeatureFlag: parseBoolean(duoCliEnabledSettingFeatureFlag),
      toggleBetaModelsPath,
      enabledExpandedLogging: parseBoolean(enabledExpandedLogging),
      earlyAccessPath,
      amazonQAvailable: parseBoolean(amazonQAvailable),
      amazonQAutoReviewEnabled: parseBoolean(amazonQAutoReviewEnabled),
      onGeneralSettingsPage: parseBoolean(onGeneralSettingsPage),
      areExperimentSettingsAllowed: parseBoolean(areExperimentSettingsAllowed),
      arePromptCacheSettingsAllowed: parseBoolean(arePromptCacheSettingsAllowed),
      duoChatExpirationDays: parseInt(duoChatExpirationDays, 10),
      duoChatExpirationColumn,
      aiUsageDataCollectionAvailable: parseBoolean(aiUsageDataCollectionAvailable),
      aiUsageDataCollectionEnabled: parseBoolean(aiUsageDataCollectionEnabled),
      aiCatalogRestrictedToGroupHierarchy: parseBoolean(aiCatalogRestrictedToGroupHierarchy),
      initialDuoRemoteFlowsAvailability: parseBoolean(duoRemoteFlowsAvailability),
      initialDuoFoundationalFlowsAvailability: parseBoolean(duoFoundationalFlowsAvailability),
      initialDuoCustomAgentsAvailability: parseBoolean(duoCustomAgentsAvailability),
      initialDuoCustomFlowsAvailability: parseBoolean(duoCustomFlowsAvailability),
      initialDuoExternalAgentsAvailability: parseBoolean(duoExternalAgentsAvailability),
      initialToolApprovalForSessionAvailability:
        toolApprovalForSessionAvailability || AVAILABILITY_OPTIONS.DEFAULT_OFF,
      initialDuoWorkflowsDefaultImageRegistry: duoWorkflowsDefaultImageRegistry || '',
      isSaaS: parseBoolean(isSaas),
      isGroupSettings: options?.isGroupSettings || false,
      rootNamespaceId,
      availableFoundationalFlows: (() => {
        const flows = availableFoundationalFlows ? JSON.parse(availableFoundationalFlows) : [];
        return flows;
      })(),
      initialSelectedFoundationalFlowIds: (() => {
        const selected = selectedFoundationalFlowReferences
          ? JSON.parse(selectedFoundationalFlowReferences)
          : [];
        return selected;
      })(),
      initialNamespaceAccessRules: namespaceAccessRulesParsed,
      parentPath,
      // TODO: parentPath and groupFullPath both resolve to @group.full_path.
      // Consolidate into a single provide once `duo_access_through_namespaces`
      // and `dap_group_network_access_controls` feature flags are fully rolled out.
      groupFullPath: groupFullPath || null,
      initialMinimumAccessLevelExecuteSync: sanitizedInt(aiMinimumAccessLevelToExecute),
      initialMinimumAccessLevelExecuteAsync: sanitizedInt(aiMinimumAccessLevelToExecuteAsync),
      initialDuoTemplateProject: duoTemplateProject
        ? convertObjectPropsToCamelCase(JSON.parse(duoTemplateProject), { deep: true })
        : null,
      includeRecommendedAllowedDomains: parseBoolean(includeRecommendedAllowed),
      allowAllUnixSockets: parseBoolean(allowAllUnixSockets),
      allowProjectExtension: parseBoolean(allowProjectExtension),
    },
    render: (createElement) =>
      createElement(component, {
        props: {
          redirectPath,
          updateId,
          duoProVisible: parseBoolean(duoProVisible),
        },
      }),
  });
};
