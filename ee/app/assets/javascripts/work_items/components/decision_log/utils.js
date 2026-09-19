import {
  DECISION_SOURCE_DUO_FLOW,
  DECISION_SOURCE_MANUAL,
  DECISION_SOURCE_THREAD_RESOLUTION,
} from './constants';

/**
 * Works out where a decision came from.
 *
 * The API has no source field, so the card reads the mark each path leaves on the record. A source
 * link is only ever set by an author filling in the form, and a discussion id is only ever set by
 * marking a thread. Duo is the remaining case, because nothing else writes a decision.
 *
 * @param {Object} decision A decision from the decision log query.
 * @returns {string} One of the DECISION_SOURCE_* values.
 */
export const decisionSource = ({ sourceLink, discussionId }) => {
  if (sourceLink) return DECISION_SOURCE_MANUAL;
  if (discussionId) return DECISION_SOURCE_THREAD_RESOLUTION;

  return DECISION_SOURCE_DUO_FLOW;
};
