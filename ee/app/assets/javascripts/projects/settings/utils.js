import { getAccessLevelsRolesText } from '~/projects/settings/utils';
import { n__ } from '~/locale';

export const getAccessLevels = (accessLevels = {}) => {
  const total = accessLevels.edges?.length;
  const accessLevelTypes = { total, users: [], groups: [], roles: [], deployKeys: [] };

  (accessLevels.edges || []).forEach(({ node }) => {
    // Priority order: user > group > deployKey > role
    if (node.user) {
      const src = node.user.avatarUrl;
      accessLevelTypes.users.push({ src, ...node.user });
    } else if (node.group) {
      accessLevelTypes.groups.push(node.group);
    } else if (node.deployKey) {
      accessLevelTypes.deployKeys.push(node.deployKey);
    } else {
      accessLevelTypes.roles.push(node.accessLevel);
    }
  });

  return accessLevelTypes;
};

export const getAccessLevelInputFromEdges = (edges) => {
  return edges.flatMap(({ node }) => {
    const result = {};

    if (node.accessLevel !== undefined) {
      result.accessLevel = node.accessLevel;
    }

    if (node.group?.id !== undefined) {
      result.groupId = node.group.id;
      delete result.accessLevel; // backend only expects groupId
    }

    if (node.user?.id !== undefined) {
      result.userId = node.user.id;
      delete result.accessLevel; // backend only expects userId
    }

    if (node.deployKey?.id !== undefined) {
      result.deployKeyId = node.deployKey.id;
      delete result.accessLevel; // backend only expects deployKeyId
    }

    return Object.keys(result).length > 0 ? [result] : [];
  });
};

export const getAccessLevelsRolesAndEEText = (accessLevels) => {
  const textParts = getAccessLevelsRolesText(accessLevels);

  if (accessLevels.groups?.length) {
    textParts.push(n__('1 group', '%d groups', accessLevels.groups.length));
  }

  if (accessLevels.users?.length) {
    textParts.push(n__('1 user', '%d users', accessLevels.users.length));
  }

  return textParts;
};
