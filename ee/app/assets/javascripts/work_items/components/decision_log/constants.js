import { s__ } from '~/locale';

// Mirrors the limits the storage model enforces, so the form fails before the request does.
// https://gitlab.com/gitlab-org/gitlab/-/work_items/603064#note_3698679976
export const DECISION_TITLE_LENGTH_MAX = 255;
export const DECISION_DESCRIPTION_LENGTH_MAX = 1000;
export const DECISION_RATIONALE_LENGTH_MAX = 800;

// How close to a limit a field has to be before the count is worth showing. Below this the
// count is noise on a form where most entries are nowhere near the limit.
export const DECISION_REMAINING_COUNT_THRESHOLD = 50;

// The card owns the anchor and the panel clears it on close, so both sides read the prefix
// from here.
export const DECISION_ANCHOR_PREFIX = 'decision_';

// Mirrors the `source` enum in the proposed storage model.
// https://gitlab.com/gitlab-org/gitlab/-/work_items/603064#note_3681023203
export const DECISION_SOURCE_MANUAL = 'MANUAL';
export const DECISION_SOURCE_DUO_FLOW = 'DUO_FLOW';
export const DECISION_SOURCE_THREAD_RESOLUTION = 'THREAD_RESOLUTION';

// Where the decision came from. Each one is a complete sentence, because the card renders it on a
// line of its own. The author named here is whoever raised the question, not whoever settled it.
export const DECISION_SOURCE_TEXTS = {
  [DECISION_SOURCE_DUO_FLOW]: s__(
    'WorkItemDecisionLog|Suggested answer to an open question raised by %{author}',
  ),
  [DECISION_SOURCE_MANUAL]: s__('WorkItemDecisionLog|Recorded manually on this work item'),
  [DECISION_SOURCE_THREAD_RESOLUTION]: s__(
    'WorkItemDecisionLog|Recorded from a thread on this work item',
  ),
};
