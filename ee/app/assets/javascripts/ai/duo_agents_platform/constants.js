import { __, s__ } from '~/locale';

export const DUO_AGENTS_PLATFORM_POLLING_INTERVAL = 10000;
export const AGENT_PLATFORM_INDEX_COMPONENT_NAME = 'DuoAgentPlatformIndex';

export const AGENT_PLATFORM_PROJECT_PAGE = 'project';
export const AGENT_PLATFORM_GROUP_PAGE = 'group';
export const AGENT_PLATFORM_USER_PAGE = 'user';

export const AGENT_PLATFORM_STATUS_ICON = {
  CREATED: {
    icon: 'dash-circle',
    color: 'neutral',
  },
  RUNNING: {
    icon: 'play',
    color: 'blue',
  },
  FINISHED: {
    icon: 'check',
    color: 'green',
  },
  PAUSED: {
    icon: 'pause',
    color: 'neutral',
  },
  STOPPED: {
    icon: 'cancel',
    color: 'red',
  },
  INPUT_REQUIRED: {
    icon: 'status',
    color: 'orange',
  },
  PLAN_APPROVAL_REQUIRED: {
    icon: 'status',
    color: 'orange',
  },
  TOOL_CALL_APPROVAL_REQUIRED: {
    icon: 'status',
    color: 'orange',
  },
  FAILED: {
    icon: 'error',
    color: 'red',
  },
};

export const AGENT_PLATFORM_STATUS_BADGE = {
  CREATED: {
    icon: 'dash-circle',
    variant: 'neutral',
  },
  RUNNING: {
    icon: 'play',
    variant: 'info',
  },
  FINISHED: {
    icon: 'status-success',
    variant: 'success',
  },
  PAUSED: {
    icon: 'status-paused',
    variant: 'neutral',
  },
  STOPPED: {
    icon: 'status-cancelled',
    variant: 'danger',
  },
  INPUT_REQUIRED: {
    icon: 'status',
    variant: 'warning',
  },
  PLAN_APPROVAL_REQUIRED: {
    icon: 'status',
    variant: 'warning',
  },
  TOOL_CALL_APPROVAL_REQUIRED: {
    icon: 'status',
    variant: 'warning',
  },
  FAILED: {
    icon: 'status-alert',
    variant: 'danger',
  },
};

export const FLOW_TRIGGER_TYPE_MENTION = {
  text: __('Mention'),
  description: s__(
    'AICatalog|Trigger %{itemType} when service account user is mentioned in an issue or merge request.',
  ),
  value: 'mention',
  valueInt: 0, // Matches EVENT_TYPES[:mention] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'MENTION',
};

export const FLOW_TRIGGER_TYPE_ASSIGN = {
  text: __('Assign'),
  description: s__(
    'AICatalog|Trigger %{itemType} when service account user is assigned to an issue or merge request.',
  ),
  value: 'assign',
  valueInt: 1, // Matches EVENT_TYPES[:assign] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'ASSIGN',
};

export const FLOW_TRIGGER_TYPE_ASSIGN_REVIEWER = {
  text: __('Assign reviewer'),
  description: s__(
    'AICatalog|Trigger %{itemType} when service account user is assigned as a reviewer to a merge request.',
  ),
  value: 'assign_reviewer',
  valueInt: 2, // Matches EVENT_TYPES[:assign_reviewer] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'ASSIGN_REVIEWER',
};

export const FLOW_TRIGGER_TYPE_PIPELINE_HOOKS = {
  text: __('Pipeline events'),
  description: s__('AICatalog|Trigger %{itemType} when a pipeline status changes.'),
  value: 'pipeline_hooks',
  valueInt: 3, // Matches EVENT_TYPES[:pipeline_hooks] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'PIPELINE_HOOKS',
};

// Dotted path into the pipeline webhook payload, evaluated by `Gitlab::FilterEvaluator`.
// The shape comes from `Gitlab::DataBuilder::Pipeline#hook_attrs`:
// https://gitlab.com/gitlab-org/gitlab/-/blob/87f27de87474583e1d3d02f04971646a3dba5fd7/lib/gitlab/data_builder/pipeline.rb#L17
export const FILTER_FIELD_PIPELINE_STATUS = 'object_attributes.status';
export const FILTER_OPERATOR_IN = 'in';

export const PIPELINE_HOOK_STATUSES = [
  { text: s__('Pipeline|Running'), value: 'running' },
  { text: s__('Pipeline|Passed'), value: 'success' },
  { text: s__('Pipeline|Failed'), value: 'failed' },
  { text: s__('Pipeline|Canceled'), value: 'canceled' },
];

export const FLOW_TRIGGER_TYPE_MERGE_REQUEST_READY = {
  text: s__('MergeRequest|Merge request ready'),
  description: s__(
    "AICatalog|Trigger %{itemType} when a merge request's draft status is removed, and it is ready for review.",
  ),
  value: 'merge_request_ready',
  valueInt: 4, // Matches EVENT_TYPES[:merge_request_ready] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'MERGE_REQUEST_READY',
};

export const FLOW_TRIGGER_TYPE_MERGE_REQUEST_CODE_CONFLICT = {
  text: s__('MergeRequest|Merge request code conflict'),
  description: s__(
    'AICatalog|Trigger %{itemType} when a merge request cannot be merged anymore due to a code conflict.',
  ),
  value: 'merge_request_code_conflict',
  valueInt: 5, // Matches EVENT_TYPES[:merge_request_code_conflict] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'MERGE_REQUEST_CODE_CONFLICT',
};

export const FILTER_FIELD_MERGE_REQUEST_ACTION = 'action';

export const MERGE_REQUEST_ACTION_APPROVED = {
  text: s__('MergeRequest|Approved'),
  value: 'approved',
};

export const MERGE_REQUEST_ACTIONS = [MERGE_REQUEST_ACTION_APPROVED];

export const FLOW_TRIGGER_TYPE_MERGE_REQUEST = {
  text: __('Merge request'),
  description: s__('AICatalog|Trigger %{itemType} when a merge request is approved.'),
  value: 'merge_request',
  valueInt: 6, // Matches EVENT_TYPES[:merge_request] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'MERGE_REQUEST',
};

export const FLOW_TRIGGER_TYPE_WORK_ITEM = {
  text: s__('WorkItem|Work item created'),
  description: s__(
    'AICatalog|Trigger %{itemType} when a work item is created (issues, tasks, incidents, and other project-level work item types).',
  ),
  value: 'work_item',
  valueInt: 7, // Matches EVENT_TYPES[:work_item] in ee/app/models/ai/flow_trigger.rb
  graphQL: 'WORK_ITEM',
};

export const FLOW_TRIGGER_TYPES = [
  FLOW_TRIGGER_TYPE_MENTION,
  FLOW_TRIGGER_TYPE_ASSIGN,
  FLOW_TRIGGER_TYPE_ASSIGN_REVIEWER,
  FLOW_TRIGGER_TYPE_PIPELINE_HOOKS,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_READY,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST_CODE_CONFLICT,
  FLOW_TRIGGER_TYPE_MERGE_REQUEST,
  FLOW_TRIGGER_TYPE_WORK_ITEM,
];

export const DEFAULT_AGENT_PLATFORM_PAGINATION_VARIABLES = {
  first: 20,
  before: null,
  after: null,
  last: null,
};

// Can cancel only if session is in an active state (not already finished, failed, or stopped)
export const AGENT_PLATFORM_CANCELABLE_STATUSES = [
  'CREATED',
  'RUNNING',
  'PAUSED',
  'INPUT_REQUIRED',
  'PLAN_APPROVAL_REQUIRED',
  'TOOL_CALL_APPROVAL_REQUIRED',
];

export const STALE_ROUTE_ERROR_CODES = [
  'INSUFFICIENT_NAMESPACE_PERMISSIONS',
  'NO_DEFAULT_NAMESPACE',
  'WORKFLOW_NOT_FOUND',
  'NO_RESOURCE_PERMISSIONS',
];

export const SIDE_PANEL_ROUTE_CONTEXT = 'side_panel';

export const AGENT_PLATFORM_SESSION_RETENTION_LENGTH = 30;

export const AGENT_PLATFORM_STATUS_FAILED = 'FAILED';

export const MESSAGE_SUB_TYPE_DELEGATION = 'delegation';
export const MESSAGE_SUB_TYPE_DELEGATION_RETURNS = 'delegation_returns';
export const MESSAGE_SUB_TYPE_START_FLOW = 'start_flow';

export const WORKFLOW_TERMINAL_STATUSES = ['FINISHED', 'FAILED', 'STOPPED'];
export const WORKFLOW_AWAITING_INPUT_STATUSES = [
  'INPUT_REQUIRED',
  'PLAN_APPROVAL_REQUIRED',
  'TOOL_CALL_APPROVAL_REQUIRED',
];

export const TODO_STATUS_ICON = {
  completed: { name: 'check', class: 'gl-text-success' },
  pending: { name: 'dash-circle', class: 'gl-text-subtle' },
  cancelled: { name: 'close', class: 'gl-text-subtle' },
};
