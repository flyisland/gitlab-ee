import { s__ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';
import { localeDateFormat } from '~/lib/utils/datetime/locale_dateformat';
import { isGid, getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  AGENT_PLATFORM_STATUS_ICON,
  AGENT_PLATFORM_STATUS_BADGE,
  FILTER_FIELD_ACTION,
  FILTER_FIELD_PIPELINE_STATUS,
  FILTER_OPERATOR_IN,
  FLOW_TRIGGER_TYPES,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_READY,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_CODE_CONFLICT,
  FLOW_TRIGGER_TYPE_PIPELINE_HOOKS,
  FLOW_TRIGGER_TYPE_WORK_ITEM,
  MERGE_REQUEST_ACTIONS,
  MESSAGE_SUB_TYPE_DELEGATION,
  MESSAGE_SUB_TYPE_DELEGATION_RETURNS,
  PIPELINE_HOOK_STATUSES,
  WORK_ITEM_ACTIONS,
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
 * Extracts the values of a single `{ field, operator: 'in', value: [...] }` rule from a
 * trigger filter scope, keeping only values that belong to the known option set.
 *
 * The filter is shaped like `{ <scope>: { rules: [{ field, operator, value }] } }`
 * (validated by app/validators/json_schemas/filter.json).
 * Returns `[]` when the filter is missing, malformed, or has values outside `options`.
 */
export const parseFilterRuleValues = ({ filter, scope, field, options }) => {
  const rules = filter?.[scope]?.rules;
  if (!Array.isArray(rules) || rules.length !== 1) return [];

  const [rule] = rules;
  if (rule.field !== field || rule.operator !== FILTER_OPERATOR_IN || !Array.isArray(rule.value)) {
    return [];
  }

  const allowedValues = options.map((option) => option.value);
  return rule.value.filter((value) => allowedValues.includes(value));
};

/**
 * Maps selected option values to their human-readable labels, preserving option order.
 * Used to render the trigger token summary on the catalog item page.
 */
const selectedOptionLabels = (options, values) =>
  options.filter((option) => values.includes(option.value)).map((option) => option.text);

export const parsePipelineStatusFilter = (filter) =>
  parseFilterRuleValues({
    filter,
    scope: FLOW_TRIGGER_TYPE_PIPELINE_HOOKS.value,
    field: FILTER_FIELD_PIPELINE_STATUS,
    options: PIPELINE_HOOK_STATUSES,
  });

export const pipelineStatusLabels = (filter) =>
  selectedOptionLabels(PIPELINE_HOOK_STATUSES, parsePipelineStatusFilter(filter));

const FOLDABLE_MERGE_REQUEST_ACTIONS = MERGE_REQUEST_ACTIONS.filter(
  (action) => action.eventTypeValueInt != null,
);

const buildMergeRequestActionFilter = (filter, actions) => ({
  ...(filter || {}),
  [FLOW_TRIGGER_TYPE_MERGE_REQUEST.value]: {
    rules: [{ field: FILTER_FIELD_ACTION, operator: FILTER_OPERATOR_IN, value: actions }],
  },
});

const filterWithoutMergeRequest = (filter) =>
  Object.fromEntries(
    Object.entries(filter || {}).filter(([key]) => key !== FLOW_TRIGGER_TYPE_MERGE_REQUEST.value),
  );

/**
 * Extracts the selected merge_request action values from a trigger's filter JSONB.
 *
 * The filter is shaped like
 *   `{ merge_request: { rules: [{ field: 'action', operator: 'in', value: [...] }] } }`.
 * Returns the validated action values (e.g. `['ready', 'approved']`), or `[]` if the
 * filter is missing, malformed, or contains values outside the known action set.
 */
export const parseMergeRequestActionFilter = (filter) => {
  const rules = filter?.[FLOW_TRIGGER_TYPE_MERGE_REQUEST.value]?.rules;
  if (!Array.isArray(rules) || rules.length !== 1) return [];

  const [rule] = rules;
  if (
    rule.field !== FILTER_FIELD_ACTION ||
    rule.operator !== FILTER_OPERATOR_IN ||
    !Array.isArray(rule.value)
  ) {
    return [];
  }

  const allowedValues = MERGE_REQUEST_ACTIONS.map((action) => action.value);
  return rule.value.filter((value) => allowedValues.includes(value));
};

export const parseWorkItemActionFilter = (filter) =>
  parseFilterRuleValues({
    filter,
    scope: FLOW_TRIGGER_TYPE_WORK_ITEM.value,
    field: FILTER_FIELD_ACTION,
    options: WORK_ITEM_ACTIONS,
  });

/**
 * Returns the human-readable labels for the merge_request actions selected in a filter,
 * e.g. `['Ready', 'Approved']`. Used to render the trigger token summary on the catalog item page.
 */
export const mergeRequestActionLabels = (filter) => {
  const values = parseMergeRequestActionFilter(filter);
  if (!values.length) return [];

  return MERGE_REQUEST_ACTIONS.filter((action) => values.includes(action.value)).map(
    (action) => action.text,
  );
};

export const workItemActionLabels = (filter) =>
  selectedOptionLabels(WORK_ITEM_ACTIONS, parseWorkItemActionFilter(filter));

// Every event type that can appear in a trigger's event_types, including the foldable
// merge_request actions (4/5) that are not offered as standalone listbox options.
const ALL_FLOW_TRIGGER_TYPES = [
  ...FLOW_TRIGGER_TYPES,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_READY,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_CODE_CONFLICT,
];

/**
 * Maps string event-type values (e.g. `'merge_request'`) to their numeric ids, dropping
 * any unknown values. Lets string-keyed callers reuse the int-keyed fold helpers below.
 */
export const eventTypeValuesToInts = (values = []) =>
  values
    .map((value) => ALL_FLOW_TRIGGER_TYPES.find((type) => type.value === value)?.valueInt)
    .filter((valueInt) => valueInt != null);

/**
 * Inverse of `eventTypeValuesToInts`: maps numeric event-type ids back to their string
 * values, dropping any unknown ids.
 */
export const eventTypeIntsToValues = (ints = []) =>
  ints
    .map((valueInt) => ALL_FLOW_TRIGGER_TYPES.find((type) => type.valueInt === valueInt)?.value)
    .filter(Boolean);

/**
 * Inverse of `normalizeMergeRequestEventTypes`: restores each foldable action to its own
 * event type (`ready` -> 4, `code_conflict` -> 5) on save, so only `approved` is ever
 * stored under `merge_request` (6). Idempotent and pure.
 */
export const denormalizeMergeRequestEventTypes = ({ eventTypes, filter }) => {
  const mrId = FLOW_TRIGGER_TYPE_MERGE_REQUEST.valueInt;
  const actions = parseMergeRequestActionFilter(filter);

  const toRestore = FOLDABLE_MERGE_REQUEST_ACTIONS.filter((action) =>
    actions.includes(action.value),
  );

  if (!toRestore.length) {
    return { eventTypes, filter: filter || {} };
  }

  const restoredValues = toRestore.map((action) => action.value);
  const remainingActions = actions.filter((action) => !restoredValues.includes(action));
  const nextFilter = remainingActions.length
    ? buildMergeRequestActionFilter(filterWithoutMergeRequest(filter), remainingActions)
    : filterWithoutMergeRequest(filter);

  let nextEventTypes = [...(eventTypes || [])];
  toRestore.forEach(({ eventTypeValueInt }) => {
    if (!nextEventTypes.includes(eventTypeValueInt)) nextEventTypes.push(eventTypeValueInt);
  });
  if (!remainingActions.length) {
    nextEventTypes = nextEventTypes.filter((id) => id !== mrId);
  }

  return { eventTypes: nextEventTypes, filter: nextFilter };
};

/**
 * Folds `merge_request_ready` (4) and `merge_request_code_conflict` (5) into `merge_request`
 * (6) with the matching action filter, so the field only deals with the consolidated shape.
 * Idempotent and pure.
 */
export const normalizeMergeRequestEventTypes = ({ eventTypes, filter }) => {
  const types = Array.isArray(eventTypes) ? [...eventTypes] : eventTypes;
  if (!Array.isArray(types)) return { eventTypes, filter: filter || {} };

  const mrId = FLOW_TRIGGER_TYPE_MERGE_REQUEST.valueInt;
  const toFold = FOLDABLE_MERGE_REQUEST_ACTIONS.filter((action) =>
    types.includes(action.eventTypeValueInt),
  );

  if (!toFold.length) {
    return { eventTypes: types, filter: filter || {} };
  }

  const eventTypeValueInts = toFold.map((action) => action.eventTypeValueInt);
  const filteredTypes = types.filter((id) => !eventTypeValueInts.includes(id));
  if (!filteredTypes.includes(mrId)) {
    filteredTypes.push(mrId);
  }

  const existingActions = parseMergeRequestActionFilter(filter);
  const foldedActions = toFold
    .map((action) => action.value)
    .filter((value) => !existingActions.includes(value));

  return {
    eventTypes: filteredTypes,
    filter: buildMergeRequestActionFilter(filter, [...existingActions, ...foldedActions]),
  };
};
