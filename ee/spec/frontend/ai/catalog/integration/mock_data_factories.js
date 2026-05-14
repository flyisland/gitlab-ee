import {
  mockAgent,
  mockAgentConfigurationForProject,
  mockItemConfigurationForGroup,
  mockFlow,
  mockFlowConfigurationForProject,
  mockFlowConfigurationForGroup,
  mockProjectsMaintainerResponse,
  mockProjectUserPermissionsResponse,
  mockProjectUserPermissionsNotAdminResponse,
  mockGroupUserPermissionsResponse,
  mockGroupUserPermissionsNotAdminResponse,
} from '../mock_data';

export const createAgentWithPermissions = ({
  adminAiCatalogItem = true,
  reportAiCatalogItem = true,
  forceHardDeleteAiCatalogItem = false,
  foundational = false,
  isPublic = true,
  withProjectConfig = true,
  withGroupConfig = true,
  projectConfigEnabled = true,
  groupConfigEnabled = true,
  pinnedVersion = null,
  groupPinnedVersion = null,
} = {}) => ({
  ...mockAgent,
  foundational,
  public: isPublic,
  userPermissions: {
    adminAiCatalogItem,
    reportAiCatalogItem,
    forceHardDeleteAiCatalogItem,
  },
  configurationForProject: withProjectConfig
    ? {
        ...mockAgentConfigurationForProject,
        enabled: projectConfigEnabled,
        pinnedItemVersion: pinnedVersion ?? mockAgentConfigurationForProject.pinnedItemVersion,
      }
    : null,
  configurationForGroup: withGroupConfig
    ? {
        ...mockItemConfigurationForGroup,
        enabled: groupConfigEnabled,
        pinnedItemVersion: groupPinnedVersion ?? mockItemConfigurationForGroup.pinnedItemVersion,
      }
    : null,
});

export const createProjectsMaintainerHandler = () => {
  return jest.fn().mockResolvedValue(mockProjectsMaintainerResponse);
};

export const createFlowWithPermissions = ({
  adminAiCatalogItem = true,
  reportAiCatalogItem = true,
  forceHardDeleteAiCatalogItem = false,
  foundational = false,
  isPublic = true,
  withProjectConfig = true,
  withGroupConfig = true,
  projectConfigEnabled = true,
  groupConfigEnabled = true,
  pinnedVersion = null,
  groupPinnedVersion = null,
} = {}) => ({
  ...mockFlow,
  foundational,
  public: isPublic,
  userPermissions: {
    adminAiCatalogItem,
    reportAiCatalogItem,
    forceHardDeleteAiCatalogItem,
  },
  configurationForProject: withProjectConfig
    ? {
        ...mockFlowConfigurationForProject,
        enabled: projectConfigEnabled,
        pinnedItemVersion: pinnedVersion ?? mockFlowConfigurationForProject.pinnedItemVersion,
      }
    : null,
  configurationForGroup: withGroupConfig
    ? {
        ...mockFlowConfigurationForGroup,
        enabled: groupConfigEnabled,
        pinnedItemVersion: groupPinnedVersion ?? mockFlowConfigurationForGroup.pinnedItemVersion,
      }
    : null,
});

export const createProjectPermissionsHandler = ({ adminAiCatalogItemConsumer = true } = {}) => {
  const response = adminAiCatalogItemConsumer
    ? mockProjectUserPermissionsResponse
    : mockProjectUserPermissionsNotAdminResponse;
  return jest.fn().mockResolvedValue(response);
};

export const createGroupPermissionsHandler = ({ adminAiCatalogItemConsumer = true } = {}) => {
  const response = adminAiCatalogItemConsumer
    ? mockGroupUserPermissionsResponse
    : mockGroupUserPermissionsNotAdminResponse;
  return jest.fn().mockResolvedValue(response);
};
