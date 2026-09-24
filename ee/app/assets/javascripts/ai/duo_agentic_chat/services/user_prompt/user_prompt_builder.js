import escapeRegExp from 'lodash-es/escapeRegExp';
import { MAX_PROMPT_LENGTH } from 'ee/ai/tanuki_bot/constants';
import { flattenSlashCommands } from '../plugin_capabilities/slash_commands';
import { createUserPrompt } from './user_prompt';

/**
 * @typedef {import('../plugin_capabilities/slash_commands').SlashCommand} SlashCommand
 * @typedef {import('../plugin_capabilities/slash_commands').SlashCommandEntry} SlashCommandEntry
 * @typedef {import('./user_prompt').UserPrompt} UserPrompt
 */

// Anchored and cased the same way slash_commands_menu.vue treats a typed token, so the
// UI and the payload never disagree about whether a command was used: `/compacting`
// doesn't match `/compact`, a URL like `https://example.com/new` doesn't either, and
// `/Compact` does.
const tokenIndex = (text, value) =>
  text.search(new RegExp(`(?:^|\\s)${escapeRegExp(value)}(?=\\s|$)`, 'i'));

// `slashCommands` = every command whose token appears in `text`, in the order the
// tokens appear. Recording menu selections directly would go stale on backspace and
// miss hand-typed commands, so identical text could yield different commands
// depending on how it was entered.
//
// Already-recorded commands are candidates alongside the catalogue, and take
// precedence over it, for two reasons: an entry stays put when the catalogue has not
// resolved yet or no longer offers that command, and it keeps whatever the catalogue
// cannot supply -- a future param whose value never appears in the text, such as a
// label gid behind `~bug`.
function commandsIn(text, catalogue, recordedCommands) {
  const byValue = new Map();

  [...recordedCommands, ...flattenSlashCommands(catalogue)].forEach((command) => {
    if (command?.value && !byValue.has(command.value)) {
      byValue.set(command.value, command);
    }
  });

  return [...byValue.values()]
    .map((command) => ({ command, at: tokenIndex(text, command.value) }))
    .filter(({ at }) => at !== -1)
    .sort((a, b) => a.at - b.at)
    .map(({ command }) => command);
}

/**
 * Persistent: every mutator returns a new builder rather than changing this one.
 * Reassignment (`this.draft = this.draft.withText(x)`) is what makes Vue reactivity
 * reliable here, and it keeps the builder testable with no Vue.
 */
export class UserPromptBuilder {
  constructor({ text = '', slashCommands = [], attachments = [], catalogue = [] } = {}) {
    this.text = text;
    this.catalogue = catalogue;
    this.attachments = attachments;
    // Re-applied here, not only in `withText`, so every instance is consistent by
    // construction -- including one built via `withCatalogue` after the user has
    // already typed a command the catalogue didn't know about yet.
    this.slashCommands = commandsIn(text, catalogue, slashCommands);
  }

  // Static, and reads the fields one by one rather than spreading: Vue 3 hands
  // components a reactive Proxy of anything in `data()`, and a private element cannot
  // be reached through one. Looked up on the class, which is never proxied.
  static #derive(builder, changes) {
    return new UserPromptBuilder({
      text: builder.text,
      slashCommands: builder.slashCommands,
      attachments: builder.attachments,
      catalogue: builder.catalogue,
      ...changes,
    });
  }

  static empty() {
    return new UserPromptBuilder();
  }

  /**
   * The catalogue resolves asynchronously, so a command typed before it arrives
   * would otherwise go unrecorded. Safe to re-reconcile like this because the rule
   * in `commandsIn` is idempotent and derives from `text` alone.
   *
   * @param {SlashCommandEntry[]} catalogue
   */
  withCatalogue(catalogue) {
    return UserPromptBuilder.#derive(this, { catalogue });
  }

  /**
   * @param {string} text
   */
  withText(text) {
    return UserPromptBuilder.#derive(this, { text });
  }

  /**
   * @param {SlashCommand} command
   * @param {{ triggerIndex: number, token: string }} position
   */
  withSlashCommand(command, { triggerIndex, token }) {
    const before = this.text.slice(0, triggerIndex);
    const after = this.text.slice(triggerIndex + token.length);
    const separator = /^\s/.test(after) ? '' : ' ';

    return this.withText(`${before}${command.value}${separator}${after}`);
  }

  withAttachment(attachment) {
    return UserPromptBuilder.#derive(this, { attachments: [...this.attachments, attachment] });
  }

  withoutAttachment(id) {
    return UserPromptBuilder.#derive(this, {
      attachments: this.attachments.filter((a) => a.id !== id),
    });
  }

  cleared() {
    return UserPromptBuilder.#derive(this, { text: '', attachments: [] });
  }

  // Both getters are named for the text because that is all they measure. A prompt
  // carries slash commands too, and attachments later, so "is this prompt worth
  // sending" is a question for the caller to compose rather than one to read off here.
  get isTextEmpty() {
    return this.text.trim().length === 0;
  }

  get isTextWithinLengthLimit() {
    return this.text.length <= MAX_PROMPT_LENGTH;
  }

  /**
   * @returns {UserPrompt}
   */
  build() {
    return createUserPrompt({
      text: this.text.trim(),
      slashCommands: this.slashCommands,
      attachments: this.attachments,
    });
  }
}
