import { s__, sprintf } from '~/locale';
import { DUO_CHAT_AGENT_GITLAB_DUO } from 'ee/ai/constants';

export const buildWorkPlanPrompt = (workItemUrl) =>
  sprintf(
    s__(
      `AgentPlan|You are here to help refine a plan for the user from the Work Item context to a Markdown output with key information required for Agent to pick off the work. This plan is for the work item %{workItemUrl}. Use this exact work item as your context, regardless of any other panels or items visible in the UI. The template should have a Why, How, What format with key insights and list of steps. If the issue is lacking details, start by reading the comments. Then, ask clarifying questions to the users in Chat until you are confident. If there are pending questions, please preserve them inside the plan. Then, please proceed with updating the work item 'Workplan' widget with your output. You can erase everything was there before and add your new plan entirely. Don't preserve existing notes if they dont align with what you wrote. If there is enough information but the title or description is lacking, please propose to update it minimally with key insights. Try to preserve anything that is already present, just add on top and dont repeat the full plan. What is important is syncing up enough to preserve the intent and adding data where we had none before.`,
    ),
    { workItemUrl },
  );

export const buildWorkPlanChatCommand = (workItemUrl) => ({
  agent: { name: DUO_CHAT_AGENT_GITLAB_DUO },
  agenticPrompt: buildWorkPlanPrompt(workItemUrl),
});

// Extra goal context passed to the "Generate MR with Duo" action so the
// agent treats the saved workplan as the primary spec instead of starting
// from the work-item description.
export const WORKPLAN_GOAL_PREFIX =
  'The work item has an agent_plan widget containing a workplan authored for you. Treat that plan as the primary specification: define your tasks and approach from it, and only fall back to the description or comments for additional context when the plan is unclear.';

export const GENERATE_MR_BUTTON_OPTIONS = {
  size: 'medium',
  variant: 'confirm',
  category: 'primary',
};

export const WORKPLAN_PANEL_URL_VALUE = 'workplan';

export const WORKPLAN_STATE_PARAM = 'workplan_state';

export const WORKPLAN_STATE_EDIT = 'edit';

export const PLAN_CONFIDENCE_LEVELS = {
  LOW: {
    value: 'LOW',
    barsToFill: 1,
    variant: 'error',
  },
  MEDIUM: {
    value: 'MEDIUM',
    barsToFill: 2,
    variant: 'warning',
  },
  HIGH: {
    value: 'HIGH',
    barsToFill: 3,
    variant: 'success',
  },
};

export const AGENT_STEP_PILL_VARIANTS = {
  error: 'var(--gl-status-danger-icon-color)',
  warning: 'var(--gl-status-warning-icon-color)',
  info: 'var(--gl-status-info-icon-color)',
  success: 'var(--gl-status-success-icon-color)',
  neutral: 'var(--gl-status-neutral-background-color)',
};

// `generationStatus` values for the work item's latest `workplan/v1` flow.
export const GENERATION_STATUS_NOT_STARTED = 'NOT_STARTED';
export const GENERATION_STATUS_GENERATING = 'GENERATING';
export const GENERATION_STATUS_NEEDS_INPUT = 'NEEDS_INPUT';
export const GENERATION_STATUS_COMPLETED = 'COMPLETED';
export const GENERATION_STATUS_FAILED = 'FAILED';

export const GENERATION_STATUSES = [
  GENERATION_STATUS_NOT_STARTED,
  GENERATION_STATUS_GENERATING,
  GENERATION_STATUS_NEEDS_INPUT,
  GENERATION_STATUS_COMPLETED,
  GENERATION_STATUS_FAILED,
];

// The row offers exactly one of these at a time.
export const WORKPLAN_ACTION = {
  VIEW: 'view',
  RETRY: 'retry',
  CREATE: 'create',
  NONE: 'none',
};

// Statuses where a run owns the workplan, so the UI must not offer to start another.
export const GENERATION_STATUSES_ACTIVE = [
  GENERATION_STATUS_GENERATING,
  GENERATION_STATUS_NEEDS_INPUT,
];

export const CONFIDENCE_SCORE_BAR_COUNT = 3;

// Thresholds are on the same 0-100 scale as the `readinessScore` GraphQL field.
export const CONFIDENCE_SCORE_MEDIUM_THRESHOLD = 40;

export const CONFIDENCE_SCORE_HIGH_THRESHOLD = 80;
