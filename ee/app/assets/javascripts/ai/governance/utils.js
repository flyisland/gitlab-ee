import { humanize } from '~/lib/utils/text_utility';
import { s__, sprintf } from '~/locale';
import { AGENT_TYPE_LABELS, SESSION_SOURCE_LABELS } from './constants';

/**
 * Returns the product name of an external agent type, such as `claude-code`.
 *
 * @param {string} agentType - The `agent_type` the backend stores.
 * @returns {string}
 */
export function formatAgentType(agentType) {
  return AGENT_TYPE_LABELS[agentType] || humanize(agentType, '-');
}

/**
 * Returns the label of a session's source, or undefined for an unknown source.
 *
 * glab records every session with the `CLAUDE_CODE_GLAB` source, whichever agent
 * ran it, so a glab session is named after its agent type instead.
 *
 * @param {Object} session - A session with `source` and `agentType`.
 * @returns {string|undefined}
 */
export function formatSessionSource(session) {
  const { source, agentType } = session || {};

  if (source === 'CLAUDE_CODE_GLAB' && agentType) {
    return sprintf(s__('AiGovernance|%{agent} (glab)'), {
      agent: formatAgentType(agentType),
    });
  }

  return SESSION_SOURCE_LABELS[source];
}
