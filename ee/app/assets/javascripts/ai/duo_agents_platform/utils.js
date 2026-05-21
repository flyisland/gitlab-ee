import { s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { AGENT_PLATFORM_STATUS_ICON, AGENT_PLATFORM_STATUS_BADGE } from './constants';

export { getToolData, getMessageData } from './icon_utils';

export const formatAgentDefinition = (agentDefinition) => {
  return humanize(agentDefinition || s__('DuoAgentsPlatform|Agent session'));
};

export const formatAgentFlowName = (agentDefinition, id) => {
  return `${formatAgentDefinition(agentDefinition)} #${id}`;
};

export const formatAgentStatus = (status) => {
  return status ? humanize(status.toLowerCase()) : s__('DuoAgentsPlatform|Unknown');
};

export const getAgentStatusIcon = (status) => {
  return AGENT_PLATFORM_STATUS_ICON[status] || AGENT_PLATFORM_STATUS_ICON.CREATED;
};

export const getAgentStatusBadge = (status) => {
  return AGENT_PLATFORM_STATUS_BADGE[status] || AGENT_PLATFORM_STATUS_BADGE.FAILED;
};

export const getNamespaceDatasetProperties = (dataset, properties) =>
  properties.reduce((acc, prop) => {
    acc[prop] = dataset[prop];
    return acc;
  }, {});

export const formatDate = (isoString) => {
  if (!isoString) return '';

  try {
    return localeDateFormat.asDate.format(new Date(isoString));
  } catch {
    return '';
  }
};
