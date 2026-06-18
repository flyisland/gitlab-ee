import { s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { isGid, getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  AGENT_PLATFORM_STATUS_ICON,
  AGENT_PLATFORM_STATUS_BADGE,
  FILTER_FIELD_MERGE_REQUEST_ACTION,
  FILTER_FIELD_PIPELINE_STATUS,
  FILTER_OPERATOR_IN,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  FLOW_TRIGGER_TYPE_PIPELINE_HOOKS,
  MERGE_REQUEST_ACTIONS,
  MESSAGE_SUB_TYPE_DELEGATION,
  MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
  PIPELINE_HOOK_STATUSES,
} from './constants';
import { parseToolInfo } from './icon_utils';

export const getNumericId = (id) => {
  if (!id) return null;
  return isGid(id) ? getIdFromGraphQLId(id) : id;
};

export { getToolData, getMessageData } from './icon_utils';

export const formatAgentDefinition = (agentDefinition) => {
  return humanize(agentDefinition || s__('DuoAgentsPlatform|Agent session'));
};

export const formatAgentFlowName = (agentDefinition, id) => {
  return `${formatAgentDefinition(agentDefinition)} #${id}`;
};

export const formatAgentFlowTitle = (title, agentDefinition) =>
  title?.trim() ? title : formatAgentDefinition(agentDefinition);

export const formatAgentFlowTitleWithId = (title, agentDefinition, id) =>
  title?.trim() ? title : formatAgentFlowName(agentDefinition, id);

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

/**
 * Extracts component identity from a message for display.
 * Returns null when component attribution is not available (backward compat).
 */
export const getComponentLabel = (message) => {
  if (!message?.componentName) return null;
  return {
    componentName: message.componentName,
    subsessionId: message.subsessionId ?? null,
    isSubagent: Boolean(message.subsessionId),
  };
};

export const getDelegationData = (message) => {
  const toolInfo = parseToolInfo(message?.toolInfo);

  if (!toolInfo || toolInfo.name !== 'delegate_task') {
    return null;
  }

  return {
    subagentName: toolInfo.args?.subagent_name ?? null,
    subsessionId: toolInfo.args?.subsession_id?.toString() ?? null,
    prompt: toolInfo.args?.prompt ?? null,
  };
};

/**
 * Maps each unique `componentName` in `items` to a stable colour index based
 * on first-seen order. The same component name always gets the same index,
 * and a new name gets the next available index.
 *
 * Pure function so the algorithm can be unit-tested without mounting the
 * activity log component.
 */
export const buildComponentColorIndexMap = (items) => {
  return items.reduce((acc, item) => {
    const name = item?.componentName;
    if (name && !(name in acc)) {
      acc[name] = Object.keys(acc).length;
    }
    return acc;
  }, {});
};

/**
 * Maps each item index to its nesting depth. Entries between a delegation
 * and its matching `delegation_returns` are indented one level to visually
 * group subagent work.
 *
 * Pure function so the algorithm can be unit-tested without mounting the
 * activity log component.
 */
export const computeItemDepths = (items) => {
  let depth = 0;
  return items.map((item) => {
    if (item?.messageSubType === MESSAGE_SUB_TYPE_DELEGATION) {
      const current = depth;
      depth += 1;
      return current;
    }

    if (item?.messageSubType === MESSAGE_SUB_TYPE_DELEGATION_RETURNS) {
      depth = Math.max(0, depth - 1);
      return depth;
    }

    return depth;
  });
};

export const formatDate = (isoString) => {
  if (!isoString) return '';

  try {
    return localeDateFormat.asDate.format(new Date(isoString));
  } catch {
    return '';
  }
};

/**
 * Extracts the selected pipeline statuses from a trigger's filter JSONB.
 *
 * The filter is shaped like `{ pipeline_hooks: { rules: [{ field, operator, value }] } }`.
 * Returns the validated status values (e.g. `['running', 'failed']`), or `[]` if the
 * filter is missing, malformed, or contains values outside the known status set.
 */
export const parsePipelineStatusFilter = (filter) => {
  const rules = filter?.[FLOW_TRIGGER_TYPE_PIPELINE_HOOKS.value]?.rules;
  if (!Array.isArray(rules) || rules.length !== 1) return [];

  const [rule] = rules;
  if (
    rule.field !== FILTER_FIELD_PIPELINE_STATUS ||
    rule.operator !== FILTER_OPERATOR_IN ||
    !Array.isArray(rule.value)
  ) {
    return [];
  }

  const allowedValues = PIPELINE_HOOK_STATUSES.map((status) => status.value);
  return rule.value.filter((value) => allowedValues.includes(value));
};

/**
 * Returns the human-readable labels for the pipeline statuses selected in a filter,
 * e.g. `['Runs', 'Fails']`. Used to render the trigger token summary on the catalog item page.
 */
export const pipelineStatusLabels = (filter) => {
  const values = parsePipelineStatusFilter(filter);
  if (!values.length) return [];

  return PIPELINE_HOOK_STATUSES.filter((status) => values.includes(status.value)).map(
    (status) => status.text,
  );
};

const KNOWN_MERGE_REQUEST_ACTIONS = MERGE_REQUEST_ACTIONS.map((action) => action.value);

/**
 * Extracts the selected merge_request action values from a trigger's filter JSONB.
 *
 * The filter is shaped like
 *   `{ merge_request: { rules: [{ field: 'action', operator: 'in', value: [...] }] } }`.
 * Returns the validated action values (e.g. `['approved']`), or `[]` if the filter is
 * missing, malformed, or contains values outside the known action set.
 */
export const parseMergeRequestActionFilter = (filter) => {
  const rules = filter?.[FLOW_TRIGGER_TYPE_MERGE_REQUEST.value]?.rules;
  if (!Array.isArray(rules) || rules.length !== 1) return [];

  const [rule] = rules;
  if (
    rule.field !== FILTER_FIELD_MERGE_REQUEST_ACTION ||
    rule.operator !== FILTER_OPERATOR_IN ||
    !Array.isArray(rule.value)
  ) {
    return [];
  }

  return rule.value.filter((value) => KNOWN_MERGE_REQUEST_ACTIONS.includes(value));
};

/**
 * Returns the human-readable labels for the merge_request actions selected in a filter,
 * e.g. `['Approved']`. Used to render the trigger token summary on the catalog item page.
 */
export const mergeRequestActionLabels = (filter) => {
  const values = parseMergeRequestActionFilter(filter);
  if (!values.length) return [];

  return MERGE_REQUEST_ACTIONS.filter((action) => values.includes(action.value)).map(
    (action) => action.text,
  );
};
