/**
 * @typedef {import('../plugin_capabilities/slash_commands').SlashCommand} SlashCommand
 */

/**
 * @typedef {Object} PromptAttachment
 * @property {string} id
 * @property {string} name
 * @property {string} content
 */

/**
 * A plain, JSON-serializable object rather than a class instance: prompt_queue.vue
 * persists queued prompts to sessionStorage, and a class instance would not survive
 * that round trip.
 *
 * @typedef {Object} UserPrompt
 * @property {string} text
 * @property {SlashCommand[]} slashCommands
 * @property {PromptAttachment[]} attachments - Always `[]` today; a seam for the
 *   File Upload epic, which will map each attachment to an `additional_context` item.
 */

/**
 * @param {Partial<UserPrompt>} [parts]
 * @returns {UserPrompt}
 */
export function createUserPrompt({ text = '', slashCommands = [], attachments = [] } = {}) {
  return Object.freeze({
    text,
    // Copied, so a caller mutating its own array afterwards cannot reach into this prompt.
    slashCommands: Object.freeze([...slashCommands]),
    attachments: Object.freeze([...attachments]),
  });
}

export const EMPTY_USER_PROMPT = createUserPrompt();
