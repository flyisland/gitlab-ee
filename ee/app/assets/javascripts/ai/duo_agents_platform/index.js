import { initSinglePageApplication } from '~/vue_shared/spa';
import { parseBoolean } from '~/lib/utils/common_utils';
import { NAMESPACE_PROJECT, NAMESPACE_GROUP } from 'ee/ai/catalog/constants';
import { createRouter } from './router';
import { getNamespaceDatasetProperties } from './utils';
import { AGENT_PLATFORM_PROJECT_PAGE, AGENT_PLATFORM_GROUP_PAGE } from './constants';
import { initDuoAgentsPlatformVerificationAlert } from './init_verification_alert';

export const initDuoAgentsPlatformPage = ({ namespaceDatasetProperties = [], namespace }) => {
  if (!namespace) {
    throw new Error(`Namespace is required for the DuoAgentPlatform page to function`);
  }

  initDuoAgentsPlatformVerificationAlert();

  const selector = '#js-duo-agents-platform-page';

  const el = document.querySelector(selector);
  if (!el) {
    return null;
  }

  const { dataset } = el;

  const {
    agentsPlatformBaseRoute,
    exploreAiCatalogAgentsPath,
    exploreAiCatalogFlowsPath,
    aiImpactDashboardEnabled,
    aiImpactDashboardPath,
    creditsAvailable,
    instanceBetaFeaturesEnabled,
    duoCustomAgentsEnabled,
    duoCustomFlowsEnabled,
    duoExternalAgentsEnabled,
    duoSettingsPath,
  } = dataset;

  const namespaceProvideData = getNamespaceDatasetProperties(dataset, namespaceDatasetProperties);

  if (namespaceDatasetProperties.length !== Object.keys(namespaceProvideData).length) {
    throw new Error(
      `One or more required properties are missing in the dataset:
       Expected these properties: [${namespaceDatasetProperties.join(', ')}]
       but received these: [${Object.keys(namespaceProvideData).join(', ')}].
      `,
    );
  }

  const router = createRouter(agentsPlatformBaseRoute, namespace);

  const catalogNamespace =
    namespace === AGENT_PLATFORM_PROJECT_PAGE ? NAMESPACE_PROJECT : NAMESPACE_GROUP;

  return initSinglePageApplication({
    name: 'AiDuoAgentsPlatformRoot',
    router,
    el,
    provide: {
      namespace: catalogNamespace,
      isGlobalNamespace: false,
      isProjectNamespace: namespace === AGENT_PLATFORM_PROJECT_PAGE,
      isGroupNamespace: namespace === AGENT_PLATFORM_GROUP_PAGE,
      exploreAiCatalogAgentsPath,
      exploreAiCatalogFlowsPath,
      aiImpactDashboardPath,
      aiImpactDashboardEnabled: parseBoolean(aiImpactDashboardEnabled),
      creditsAvailable: parseBoolean(creditsAvailable),
      instanceBetaFeaturesEnabled: parseBoolean(instanceBetaFeaturesEnabled),
      duoSettings: {
        duoCustomAgentsEnabled: parseBoolean(duoCustomAgentsEnabled),
        duoCustomFlowsEnabled: parseBoolean(duoCustomFlowsEnabled),
        duoExternalAgentsEnabled: parseBoolean(duoExternalAgentsEnabled),
        duoSettingsPath,
      },
      ...namespaceProvideData,
    },
  });
};
