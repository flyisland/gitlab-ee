<script>
import { GlButton, GlForm } from '@gitlab/ui';
import { s__ } from '~/locale';
import { glSlotsMixin } from '~/lib/utils/vue3compat/gl_slots_mixin';
import { UserPromptBuilder } from '../../services/user_prompt';
import { slashCommands } from '../../services/plugin_capabilities';
import { DuoChatPluginRegistry } from '../../services/plugin_registry';
import SlashCommandsMenu from './slash_commands_menu/slash_commands_menu.vue';
import PromptTextarea from './prompt_textarea.vue';

// Leading boundary so a pasted URL does not trigger a fetch.
const MAYBE_TRIGGERED = /(?:^|\s)\//;

const i18n = {
  CHAT_PROMPT_PLACEHOLDER_DEFAULT: s__("DuoAgenticChat|Let's work through this together..."),
  CHAT_SUBMIT_LABEL: s__('DuoAgenticChat|Send chat message.'),
  CHAT_CANCEL_LABEL: s__('DuoAgenticChat|Cancel'),
};

export default {
  name: 'PromptComposer',
  components: {
    GlButton,
    GlForm,
    SlashCommandsMenu,
    PromptTextarea,
  },
  mixins: [glSlotsMixin],
  inject: {
    duoChatPluginRegistry: {
      default: () => new DuoChatPluginRegistry(),
    },
  },
  props: {
    isChatAvailable: {
      type: Boolean,
      required: false,
      default: true,
    },
    /**
     * Whether the chat can take a prompt right now. Owned by the state manager,
     * which is the only thing that knows about turns this composer did not start.
     */
    canSendPrompt: {
      type: Boolean,
      required: false,
      default: true,
    },
    chatState: {
      type: Object,
      required: false,
      default: () => ({ isEnabled: true, reason: null }),
    },
    shouldAutoFocusInput: {
      type: Boolean,
      required: false,
      default: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    lastMessage: {
      type: Object,
      required: false,
      default: null,
    },
    chatPromptPlaceholder: {
      type: String,
      required: false,
      default: '',
    },
    duoChatContext: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  emits: ['send-chat-prompt', 'queue-chat-prompt', 'chat-cancel'],
  data() {
    return {
      draft: UserPromptBuilder.empty(),
      commands: [],
      isLoadingCommands: false,
      hadFocusBeforeSend: false,
      inputHasFocus: false,
    };
  },
  computed: {
    isStreaming() {
      return Boolean(
        (this.lastMessage?.chunks?.length > 0 && !this.lastMessage?.content) ||
        typeof this.lastMessage?.chunkId === 'number',
      );
    },
    showSubmitButton() {
      // When idle the submit button always shows. During a turn it only comes
      // back once the user has typed something to queue; an empty input keeps
      // the stop button available to cancel the running turn.
      return !this.isLoading || !this.draft.isTextEmpty;
    },
    isDisabled() {
      return !this.isChatAvailable || !this.chatState.isEnabled;
    },
    /**
     * Whether the draft is worth sending. The single place that decides it, so the
     * submit button and the Enter key cannot drift apart -- they did, and Enter sent
     * whitespace-only and over-length prompts the button refused. Attachments will
     * widen this: a prompt with a file and no text is worth sending.
     */
    isDraftSubmittable() {
      return !this.draft.isTextEmpty && this.draft.isTextWithinLengthLimit;
    },
    inputPlaceholder() {
      return this.chatPromptPlaceholder || i18n.CHAT_PROMPT_PLACEHOLDER_DEFAULT;
    },
  },
  watch: {
    isLoading: 'onResponseComplete',
    isStreaming: 'onResponseComplete',
    duoChatContext() {
      // Commands can be scoped to the project or resource the chat is pointed at, so
      // what we are holding no longer applies.
      this.commands = [];
      this.commandsRequest = null;
      this.loadIfTriggered();
    },
    'draft.text': function onDraftText() {
      this.loadIfTriggered();
    },
    commands(commands) {
      this.draft = this.draft.withCatalogue(commands);
    },
  },
  created() {
    // Not in `data()`: a promise has nothing to render, and the same one is kept once
    // settled so a menu and a send in the same context join one resolution.
    this.commandsRequest = null;
  },
  methods: {
    // A method, not a computed: `glSlots()` is not a reactive dependency, so a cached
    // computed would go stale when the state manager starts or stops supplying a slot.
    hasHeaderRow() {
      return Boolean(this.glSlots()['agentic-model'] || this.glSlots()['agentic-switch']);
    },
    loadIfTriggered() {
      if (this.commandsRequest || !MAYBE_TRIGGERED.test(this.draft.text)) return;

      this.loadCommands();
    },
    async loadCommands() {
      const context = this.duoChatContext;
      const request = slashCommands.resolve(this.duoChatPluginRegistry.plugins, {
        apollo: this.$apollo,
        duoChatContext: context,
      });

      this.commandsRequest = request;
      this.isLoadingCommands = true;

      try {
        const commands = await request;

        // The context moved on while this was in flight, so these commands are for a
        // chat that is no longer on screen.
        if (context !== this.duoChatContext) return;

        this.commands = commands;
      } catch {
        // `resolve` contains provider failures itself, so this is the unexpected case.
        // Forgotten rather than kept, or the menu would stay empty for the session.
        if (this.commandsRequest === request) this.commandsRequest = null;
      } finally {
        if (context === this.duoChatContext) this.isLoadingCommands = false;
      }
    },
    // A prompt sent before the plugins answer would otherwise carry no command.
    pendingCommands() {
      this.loadIfTriggered();

      return this.isLoadingCommands ? this.commandsRequest.catch(() => {}) : undefined;
    },
    onInput(text) {
      this.draft = this.draft.withText(text);
    },
    async sendChatPrompt() {
      if (!this.isDraftSubmittable) return;

      // Store this before any async operation that might clear the draft.
      this.hadFocusBeforeSend = this.inputHasFocus;

      if (MAYBE_TRIGGERED.test(this.draft.text)) {
        await this.pendingCommands();

        this.draft = this.draft.withCatalogue(this.commands);
      }

      // The input stays enabled whenever the chat cannot take a prompt — a turn
      // is running, the flow is locked in another tab, a tool call is waiting on
      // the user — so queue the prompt instead of sending it. It fires once the
      // chat is ready again.
      this.$emit(this.canSendPrompt ? 'send-chat-prompt' : 'queue-chat-prompt', this.draft.build());

      await this.clearAndFocus();
    },
    cancelPrompt() {
      this.$emit('chat-cancel');
      this.clearAndFocus();
    },
    // `sendPredefinedPrompt` is called by the parent via $refs.
    // eslint-disable-next-line vue/no-unused-properties
    sendPredefinedPrompt(text) {
      this.draft = this.draft.withText(text);
      this.sendChatPrompt();
    },
    focusChatInput() {
      // Optional call: the child is stubbed without a `focus` method in some tests.
      this.$refs.textarea?.focus?.();
    },
    async clearAndFocus() {
      this.draft = this.draft.cleared();
      await this.$nextTick();
      this.focusChatInput();
    },
    async onResponseComplete() {
      if (this.isLoading || this.isStreaming) return;
      await this.$nextTick();
      this.restoreFocusAfterSend();
    },
    restoreFocusAfterSend() {
      if (!this.hadFocusBeforeSend) return;
      this.hadFocusBeforeSend = false;
      if (this.isDisabled) return;
      this.focusChatInput();
    },
    async onSlashCommandSelect(command, position) {
      // The menu swallows the keyup for the key that triggered this, so the
      // reset at the end of the textarea's keyup handler never runs for it.
      this.$refs.textarea?.resetComposition?.();

      this.draft = this.draft.withSlashCommand(command, position);

      if (command.shouldSubmit) {
        this.sendChatPrompt();
        return;
      }

      await this.$nextTick();
      this.focusChatInput();
    },
  },
  i18n,
};
</script>
<template>
  <gl-form class="gl-relative" data-testid="chat-prompt-form" @submit.stop.prevent="sendChatPrompt">
    <div
      class="agentic-chat-input gl-min-h-8 gl-max-w-full gl-grow gl-flex-col gl-overflow-auto gl-rounded-lg gl-align-top gl-transition-box-shadow forced-colors:gl-border"
    >
      <div
        v-if="hasHeaderRow()"
        class="gl-flex gl-items-center gl-justify-between gl-gap-5 gl-border-0 gl-border-b-1 gl-border-solid gl-border-strong gl-px-4 gl-py-4 forced-colors:gl-border-none"
      >
        <div class="duo-model-switcher gl-min-w-0 gl-max-w-full">
          <slot name="agentic-model"></slot>
        </div>
        <div class="duo-agent-mode-switcher gl-min-w-0 gl-max-w-full gl-shrink-0">
          <slot name="agentic-switch"></slot>
        </div>
      </div>
      <div>
        <slash-commands-menu
          :commands="commands"
          :value="draft.text"
          :is-loading="isLoadingCommands"
          @select="onSlashCommandSelect"
        >
          <prompt-textarea
            ref="textarea"
            :value="draft.text"
            :disabled="isDisabled"
            :placeholder="inputPlaceholder"
            :autofocus="shouldAutoFocusInput"
            :has-header-row="hasHeaderRow()"
            @input="onInput"
            @submit="sendChatPrompt"
            @focus-change="inputHasFocus = $event"
          />
        </slash-commands-menu>
      </div>
      <div class="gl-flex gl-items-center gl-justify-end gl-px-3 gl-pb-3">
        <slot name="textarea-toolbar"></slot>
        <gl-button
          v-if="showSubmitButton"
          icon="arrow-up"
          category="primary"
          variant="confirm"
          type="submit"
          :disabled="isDisabled || !isDraftSubmittable"
          data-testid="chat-prompt-submit-button"
          :aria-label="$options.i18n.CHAT_SUBMIT_LABEL"
        />
        <gl-button
          v-else
          icon="stop"
          category="primary"
          variant="default"
          data-testid="chat-prompt-cancel-button"
          :aria-label="$options.i18n.CHAT_CANCEL_LABEL"
          @click="cancelPrompt"
        />
      </div>
    </div>
  </gl-form>
</template>
