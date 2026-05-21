/**
 * Statuses that are considered "active" and shown expanded in the widget.
 */
export const SESSION_STATUSES_ACTIVE = [
  'RUNNING',
  'PAUSED',
  'INPUT_REQUIRED',
  'PLAN_APPROVAL_REQUIRED',
  'TOOL_CALL_APPROVAL_REQUIRED',
  'FAILED',
];

/**
 * Statuses that require user action — shown with a "Review" CTA.
 */
export const SESSION_STATUSES_AWAITING_INPUT = [
  'INPUT_REQUIRED',
  'PLAN_APPROVAL_REQUIRED',
  'TOOL_CALL_APPROVAL_REQUIRED',
];

/**
 * Statuses that are created, completed, or cancelled and shown collapsed.
 */
export const SESSION_STATUSES_COLLAPSED = ['CREATED', 'FINISHED', 'STOPPED'];
