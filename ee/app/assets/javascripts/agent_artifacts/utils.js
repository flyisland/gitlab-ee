/**
 * Converts a snake_case audit event name into a human-readable title.
 *
 * Examples:
 *   'ai_agent_session_ended'   => 'Agent session ended'
 *   'ai_llm_input_sent'        => 'Llm input sent'
 *   'ai_tool_invoked'          => 'Tool invoked'
 *
 * @param {string} name - The raw event name from the API.
 * @returns {string}
 */
export function formatEventName(name) {
  if (!name) return '';
  return name
    .replace(/^ai_/, '')
    .replace(/_/g, ' ')
    .replace(/^./, (c) => c.toUpperCase());
}
