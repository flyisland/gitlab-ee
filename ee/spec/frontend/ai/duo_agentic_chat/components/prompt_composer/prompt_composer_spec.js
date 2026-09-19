import { nextTick } from 'vue';
import { GlForm, GlFormTextarea } from '@gitlab/ui';
import { shallowMountExtended, mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import PromptComposer from 'ee/ai/duo_agentic_chat/components/prompt_composer/prompt_composer.vue';
import PromptTextarea from 'ee/ai/duo_agentic_chat/components/prompt_composer/prompt_textarea.vue';
import SlashCommandsMenu from 'ee/ai/duo_agentic_chat/components/prompt_composer/slash_commands_menu/slash_commands_menu.vue';
import { createUserPrompt } from 'ee/ai/duo_agentic_chat/services/user_prompt';
import { DuoChatPluginRegistry } from 'ee/ai/duo_agentic_chat/services/plugin_registry';
import { slashCommands } from 'ee/ai/duo_agentic_chat/services/plugin_capabilities';
import { initializePlugins } from 'ee/ai/duo_agentic_chat/plugins';
import {
  MAX_PROMPT_LENGTH,
  CHAT_RESET_MESSAGE,
  CHAT_CLEAR_MESSAGE,
  CHAT_NEW_MESSAGE,
} from 'ee/ai/tanuki_bot/constants';
import { MOCK_RESPONSE_MESSAGE, MOCK_USER_PROMPT_MESSAGE } from '../../../tanuki_bot/mock_data';

// Helper function for waiting for async chat submission operations
const waitForChatSubmission = async () => {
  // Wait for all async operations in sendChatPrompt:
  // 1. Initial form submission
  // 2. setPromptAndFocus() await (includes its own nextTick)
  // 3. $nextTick() before setting canSubmit
  // 4. Additional nextTicks for reactive updates to propagate

  await nextTick();
  await nextTick();
  await nextTick();
};

describe('PromptComposer', () => {
  let wrapper;

  const createComponent = ({
    propsData = {},
    slots = {},
    scopedSlots = {},
    provide = {},
    mountFn = shallowMountExtended,
  } = {}) => {
    wrapper = mountFn(PromptComposer, {
      propsData,
      slots,
      scopedSlots,
      provide,
    });

    return wrapper;
  };

  const findChatInput = () => wrapper.findComponent(PromptTextarea);
  const findChatInputNative = () => wrapper.findComponent(GlFormTextarea).find('textarea');
  const findSubmitButton = () => wrapper.findComponent('[data-testid="chat-prompt-submit-button"]');
  const findCancelButton = () => wrapper.find('[data-testid="chat-prompt-cancel-button"]');
  const findPromptForm = () => wrapper.findComponent(GlForm);

  const setPromptInput = (val) => findChatInput().vm.$emit('input', val);

  const clickSubmit = () =>
    findPromptForm().vm.$emit('submit', {
      preventDefault: jest.fn(),
      stopPropagation: jest.fn(),
    });

  const setFocusAndSubmitMessage = async (message) => {
    await findChatInputNative().trigger('focusin');
    findChatInputNative().element.value = message;
    await findChatInputNative().trigger('input');
    clickSubmit();
    await waitForChatSubmission();
  };

  const promptStr = 'foo';
  const sent = (text) => createUserPrompt({ text });
  // `/compact` is a real registered command, so the payload carries it alongside
  // the text -- that is the whole point of the structured prompt.
  const sentWithCompact = createUserPrompt({
    text: '/compact',
    slashCommands: [expect.objectContaining({ value: '/compact' })],
  });

  describe('rendering', () => {
    describe('prompt placeholder', () => {
      it.each`
        chatPromptPlaceholder   | expectedPlaceholder
        ${undefined}            | ${"Let's work through this together..."}
        ${''}                   | ${"Let's work through this together..."}
        ${'custom placeholder'} | ${'custom placeholder'}
      `(
        'displays "$expectedPlaceholder" when chatPromptPlaceholder is "$chatPromptPlaceholder"',
        ({ chatPromptPlaceholder, expectedPlaceholder }) => {
          createComponent({ propsData: { chatPromptPlaceholder } });
          expect(findChatInput().props('placeholder')).toBe(expectedPlaceholder);
        },
      );
    });
  });

  describe('header row', () => {
    const findHeader = () => wrapper.find('.duo-model-switcher');

    it('renders no header row when the parent supplies neither slot', () => {
      createComponent();

      expect(findHeader().exists()).toBe(false);
    });

    // The state manager stops and starts supplying `agentic-switch` at runtime, e.g.
    // when a billing error clears. Reading the slot map from a cached computed would
    // pin the first answer and strand the toggle for the rest of the page's life.
    it('picks up a slot the parent starts supplying after mount', async () => {
      const Parent = {
        components: { PromptComposer },
        props: { withSwitch: { type: Boolean, required: true } },
        template: `
          <prompt-composer>
            <template v-if="withSwitch" #agentic-switch><button>Switch</button></template>
          </prompt-composer>
        `,
      };
      const parent = mountExtended(Parent, { propsData: { withSwitch: false } });
      expect(parent.find('.duo-model-switcher').exists()).toBe(false);

      await parent.setProps({ withSwitch: true });

      expect(parent.find('.duo-model-switcher').exists()).toBe(true);
    });
  });

  describe('chat', () => {
    it('does render the prompt input by default', () => {
      createComponent({});
      expect(findChatInput().exists()).toBe(true);
    });

    // Whether a disabled textarea actually renders as one is the textarea's own test;
    // what matters here is the composer deciding it from the two props that gate it.
    it.each`
      desc                            | propsData                                                    | disabled
      ${'chat is available'}          | ${{}}                                                        | ${false}
      ${'chat is unavailable'}        | ${{ isChatAvailable: false }}                                | ${true}
      ${'the chat state is disabled'} | ${{ chatState: { isEnabled: false, reason: 'No credits' } }} | ${true}
    `('disables the prompt input when $desc: $disabled', ({ propsData, disabled }) => {
      createComponent({ propsData });

      expect(findChatInput().props('disabled')).toBe(disabled);
    });

    describe('chatState', () => {
      it('disables the submit button when chatState.isEnabled is false', async () => {
        createComponent({
          propsData: { chatState: { isEnabled: false, reason: 'No credits' } },
        });
        setPromptInput('TEST!');
        await nextTick();

        expect(findSubmitButton().props('disabled')).toBe(true);
      });
    });

    describe('submit/cancel button', () => {
      beforeEach(() => {
        createComponent({ propsData: {}, mountFn: mountExtended });
      });

      it('renders the submitButton initially', () => {
        expect(findSubmitButton().exists()).toBe(true);
        expect(findCancelButton().exists()).toBe(false);
      });

      it('disables the submit button if the prompt is empty', async () => {
        setPromptInput('');
        expect(findSubmitButton().props('disabled')).toBe(true);

        findChatInputNative().element.value = 'TEST!';
        await findChatInputNative().trigger('input');
        await nextTick();

        expect(findSubmitButton().props('disabled')).toBe(false);
      });

      // The button and the Enter key read the same `isDraftSubmittable`, so this pins
      // the button's half of it -- the two used to disagree.
      it.each`
        desc                       | prompt                               | disabled
        ${'is only whitespace'}    | ${'   '}                             | ${true}
        ${'is over the limit'}     | ${'a'.repeat(MAX_PROMPT_LENGTH + 1)} | ${true}
        ${'sits on the limit'}     | ${'a'.repeat(MAX_PROMPT_LENGTH)}     | ${false}
        ${'has something to send'} | ${'hello'}                           | ${false}
      `(
        'disables the submit button when the prompt $desc: $disabled',
        async ({ prompt, disabled }) => {
          setPromptInput(prompt);
          await nextTick();

          expect(findSubmitButton().props('disabled')).toBe(disabled);
        },
      );

      it('renders the cancel button once the submitted prompt starts a turn', async () => {
        wrapper.vm.prompt = 'TEST!';
        clickSubmit();
        await waitForChatSubmission();
        // The state manager reports the turn it just started.
        await wrapper.setProps({ isLoading: true });

        expect(findSubmitButton().exists()).toBe(false);
        expect(findCancelButton().exists()).toBe(true);
      });

      it('renders submit button after request was canceled', async () => {
        setPromptInput('TEST!');
        clickSubmit();
        await waitForChatSubmission();
        await wrapper.setProps({ isLoading: true });

        const cancelButton = findCancelButton();
        await cancelButton.trigger('click');
        // Cancelling runs cleanupState in the state manager, which ends the turn.
        await wrapper.setProps({ isLoading: false });

        expect(findSubmitButton().exists()).toBe(true);
        expect(findCancelButton().exists()).toBe(false);
      });

      describe('Loading', () => {
        it('renders submit button when chat is not loading and cancel otherwise', async () => {
          wrapper = createComponent({
            propsData: {
              isLoading: false,
            },
            mountFn: mountExtended,
          });

          await nextTick();

          expect(findSubmitButton().exists()).toBe(true);
          expect(findCancelButton().exists()).toBe(false);

          findChatInputNative().element.value = 'TEST!';
          await findChatInputNative().trigger('input');

          clickSubmit();

          await nextTick();

          await waitForChatSubmission();

          wrapper.setProps({ isLoading: true });
          await nextTick();

          expect(findCancelButton().exists()).toBe(true);
          expect(findSubmitButton().exists()).toBe(false);

          wrapper.setProps({ isLoading: false });
          await nextTick();

          expect(findCancelButton().exists()).toBe(false);
          expect(findSubmitButton().exists()).toBe(true);
        });
      });
    });

    describe('submit', () => {
      // Enter used to bypass the two conditions that disable the submit button.
      it.each`
        desc                    | prompt
        ${'is only whitespace'} | ${'   '}
        ${'is over the limit'}  | ${'a'.repeat(MAX_PROMPT_LENGTH + 1)}
      `('sends nothing when the prompt $desc', ({ prompt }) => {
        createComponent({ propsData: { isChatAvailable: true } });

        setPromptInput(prompt);
        findChatInput().vm.$emit('submit');

        expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
        expect(wrapper.emitted('queue-chat-prompt')).toBeUndefined();
      });

      it('sends a prompt sitting exactly on the limit', () => {
        const prompt = 'a'.repeat(MAX_PROMPT_LENGTH);
        createComponent({ propsData: { isChatAvailable: true } });

        setPromptInput(prompt);
        findChatInput().vm.$emit('submit');

        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(prompt)]]);
      });

      it('trims the prompt', () => {
        const question = ' foo bar ';
        const expectedPrompt = 'foo bar';
        createComponent({
          propsData: { isChatAvailable: true },
        });
        setPromptInput(question);
        clickSubmit();
        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(expectedPrompt)]]);
      });

      // Which keystrokes count as a submit is the textarea's business; the composer
      // only sees the `submit` it decided to emit.
      it.each`
        trigger                                     | event
        ${() => clickSubmit()}                      | ${'Submit button click'}
        ${() => findChatInput().vm.$emit('submit')} | ${'the textarea asking to submit'}
      `('sends the prompt on $event', ({ trigger } = {}) => {
        createComponent({
          propsData: { isChatAvailable: true },
        });
        setPromptInput(promptStr);
        trigger();
        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(promptStr)]]);
      });

      it.each`
        desc                                              | msgs
        ${''}                                             | ${[]}
        ${'with just a user message'}                     | ${[MOCK_USER_PROMPT_MESSAGE]}
        ${'with a user message, and a complete response'} | ${[MOCK_USER_PROMPT_MESSAGE, MOCK_RESPONSE_MESSAGE]}
      `(
        'queues rather than sends a second submission when loading $desc',
        async ({ msgs } = {}) => {
          createComponent({
            propsData: { isChatAvailable: true, lastMessage: msgs[msgs.length - 1] ?? null },
          });

          setPromptInput(promptStr);
          clickSubmit();

          await waitForChatSubmission();

          expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(promptStr)]]);

          // The state manager marks the chat busy the moment the turn starts.
          await wrapper.setProps({ canSendPrompt: false });
          setPromptInput(promptStr);
          clickSubmit();

          await waitForChatSubmission();

          expect(wrapper.emitted('send-chat-prompt')).toHaveLength(1);
          expect(wrapper.emitted('queue-chat-prompt')).toEqual([[sent(promptStr)]]);
        },
      );

      it.each([
        [[{ ...MOCK_RESPONSE_MESSAGE, content: undefined, chunks: [''] }]],
        [
          [
            MOCK_USER_PROMPT_MESSAGE,
            { ...MOCK_RESPONSE_MESSAGE, content: undefined, chunks: [''] },
          ],
        ],
        [[{ ...MOCK_RESPONSE_MESSAGE, chunkId: 1 }]],
      ])(
        'queues rather than sends a second submission when streaming (messages = "%o")',
        async (msgs = []) => {
          const lastMsg = msgs[msgs.length - 1];
          createComponent({
            propsData: { isChatAvailable: true, lastMessage: lastMsg },
          });

          setPromptInput(promptStr);
          clickSubmit();

          await waitForChatSubmission();

          expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(promptStr)]]);

          // The state manager marks the chat busy the moment the turn starts.
          await wrapper.setProps({ canSendPrompt: false });
          setPromptInput(promptStr);
          clickSubmit();

          await waitForChatSubmission();

          expect(wrapper.emitted('send-chat-prompt')).toHaveLength(1);
          expect(wrapper.emitted('queue-chat-prompt')).toEqual([[sent(promptStr)]]);
        },
      );

      it('resets the prompt after form submission', async () => {
        createComponent();
        await setPromptInput(promptStr);
        expect(findChatInput().props('value')).toBe(promptStr);

        clickSubmit();
        await nextTick();

        expect(findChatInput().props('value')).toBe('');
      });

      it('focuses on prompt after form submission', async () => {
        const focusSpy = jest.fn();
        jest.spyOn(HTMLElement.prototype, 'focus').mockImplementation(function focusMockImpl() {
          focusSpy(this);
        });
        createComponent({
          mountFn: mountExtended,
        });
        findChatInputNative().element.value = 'TEST!';
        await findChatInputNative().trigger('input');

        clickSubmit();
        await nextTick();

        expect(focusSpy).toHaveBeenCalledWith(findChatInputNative().element);
      });

      it('restores focus to prompt when isLoading becomes false after sending with focus', async () => {
        createComponent({
          propsData: { isChatAvailable: true },
          mountFn: mountExtended,
        });

        await setFocusAndSubmitMessage('test message');

        const focusSpy = jest.fn();
        jest.spyOn(HTMLElement.prototype, 'focus').mockImplementation(function focusMockImpl() {
          focusSpy(this);
        });

        await wrapper.setProps({ isLoading: true });
        await wrapper.setProps({ isLoading: false });
        await nextTick();

        expect(focusSpy).toHaveBeenCalledWith(findChatInputNative().element);
      });

      it('does not restore focus when isLoading becomes false if input was not focused before send', async () => {
        createComponent({
          propsData: { isLoading: true, isChatAvailable: true },
          mountFn: mountExtended,
        });

        const focusSpy = jest.fn();
        jest.spyOn(HTMLElement.prototype, 'focus').mockImplementation(function focusMockImpl() {
          focusSpy(this);
        });

        await wrapper.setProps({ isLoading: false });
        await nextTick();

        expect(focusSpy).not.toHaveBeenCalled();
      });

      it('restores focus to prompt when isStreaming becomes false after sending with focus', async () => {
        const streamingMessage = { role: 'assistant', chunks: ['partial'], content: undefined };
        const completedMessage = { role: 'assistant', chunks: ['partial'], content: 'done' };
        createComponent({
          propsData: { isChatAvailable: true },
          mountFn: mountExtended,
        });

        await setFocusAndSubmitMessage('test message');

        const focusSpy = jest.fn();
        jest.spyOn(HTMLElement.prototype, 'focus').mockImplementation(function focusMockImpl() {
          focusSpy(this);
        });

        await wrapper.setProps({ lastMessage: streamingMessage });
        await wrapper.setProps({ lastMessage: completedMessage });
        await nextTick();

        expect(focusSpy).toHaveBeenCalledWith(findChatInputNative().element);
      });
    });

    describe('clear', () => {
      it('does not render cancel button on clear', async () => {
        createComponent({
          propsData: { isChatAvailable: true },
          mountFn: mountExtended,
        });
        setPromptInput(CHAT_CLEAR_MESSAGE);
        clickSubmit();

        await nextTick();
        expect(findSubmitButton().exists()).toBe(true);
        expect(findCancelButton().exists()).toBe(false);
      });
    });

    describe('new', () => {
      it('does not render cancel button on new', async () => {
        createComponent({
          propsData: { isChatAvailable: true },
          mountFn: mountExtended,
        });
        setPromptInput(CHAT_NEW_MESSAGE);
        clickSubmit();

        await nextTick();
        expect(findSubmitButton().exists()).toBe(true);
        expect(findCancelButton().exists()).toBe(false);
      });
    });

    describe('reset', () => {
      it('emits the event with the reset prompt', async () => {
        createComponent({
          propsData: { isChatAvailable: true },
          mountFn: mountExtended,
        });

        findChatInputNative().element.value = CHAT_RESET_MESSAGE;
        await findChatInputNative().trigger('input');
        clickSubmit();
        await waitForPromises();

        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent(CHAT_RESET_MESSAGE)]]);
        await nextTick();
        expect(findSubmitButton().exists()).toBe(true);
        expect(findCancelButton().exists()).toBe(false);
      });
    });

    describe('cancel', () => {
      it('emits cancel event on cancel button click', async () => {
        createComponent({ propsData: { isLoading: true }, mountFn: mountExtended });
        findChatInputNative().element.value = 'TEST!';
        await findChatInputNative().trigger('input');
        clickSubmit();
        await waitForChatSubmission();

        const cancelButton = findCancelButton();
        expect(cancelButton.exists()).toBe(true);
        await cancelButton.trigger('click');
        expect(wrapper.emitted('chat-cancel')).toHaveLength(1);
      });
    });
  });

  describe('textarea-toolbar slot', () => {
    it('renders the toolbar content next to the submit button', () => {
      createComponent({
        slots: { 'textarea-toolbar': '<div data-testid="toolbar-content">Actions</div>' },
      });

      expect(wrapper.findByTestId('toolbar-content').exists()).toBe(true);
    });

    it('renders nothing in the toolbar by default', () => {
      createComponent();

      expect(wrapper.findByTestId('toolbar-content').exists()).toBe(false);
    });
  });

  describe('input availability during an active turn', () => {
    it('keeps the input enabled after submitting so further prompts can be queued', async () => {
      createComponent({ mountFn: mountExtended });

      const testPrompt = 'Hello world!';
      findChatInputNative().element.value = testPrompt;
      await findChatInputNative().trigger('input');

      expect(findChatInputNative().attributes('disabled')).toBeUndefined();

      clickSubmit();

      // Prompt is cleared but the input stays enabled during the turn.
      await nextTick();
      expect(findChatInputNative().element.value).toBe('');
      expect(findChatInputNative().attributes('disabled')).toBeUndefined();

      await waitForChatSubmission();
      expect(findChatInputNative().element.value).toBe('');
      expect(findChatInputNative().attributes('disabled')).toBeUndefined();
    });
  });

  describe('queueing during an active turn', () => {
    // Sending an initial prompt starts a turn, which the state manager reports
    // back as isLoading=true and canSendPrompt=false.
    const startTurn = async () => {
      findChatInputNative().element.value = 'first prompt';
      await findChatInputNative().trigger('input');
      clickSubmit();
      await waitForChatSubmission();
      await wrapper.setProps({ isLoading: true, canSendPrompt: false });
    };

    beforeEach(() => {
      createComponent({ propsData: { isChatAvailable: true }, mountFn: mountExtended });
    });

    it('keeps the input enabled', async () => {
      await startTurn();

      expect(findChatInputNative().attributes('disabled')).toBeUndefined();
    });

    it('shows the stop button when empty and the submit button once text is entered', async () => {
      await startTurn();

      expect(findCancelButton().exists()).toBe(true);
      expect(findSubmitButton().exists()).toBe(false);

      findChatInputNative().element.value = 'queued prompt';
      await findChatInputNative().trigger('input');

      expect(findSubmitButton().exists()).toBe(true);
      expect(findCancelButton().exists()).toBe(false);

      findChatInputNative().element.value = '';
      await findChatInputNative().trigger('input');

      expect(findCancelButton().exists()).toBe(true);
      expect(findSubmitButton().exists()).toBe(false);
    });

    it('emits queue-chat-prompt instead of send-chat-prompt', async () => {
      await startTurn();

      findChatInputNative().element.value = 'queued prompt';
      await findChatInputNative().trigger('input');
      clickSubmit();
      await waitForChatSubmission();

      expect(wrapper.emitted('queue-chat-prompt')).toEqual([[sent('queued prompt')]]);
      expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent('first prompt')]]);
    });
  });

  describe('when the chat cannot take a prompt', () => {
    // canSendPrompt is false for a turn running anywhere, a flow locked in
    // another tab, or a tool call waiting on the user. The composer does not
    // work out which: it queues whenever the state manager says it cannot send.
    beforeEach(() => {
      createComponent({
        propsData: { isChatAvailable: true, canSendPrompt: false },
        mountFn: mountExtended,
      });
    });

    it('keeps the input enabled', () => {
      expect(findChatInputNative().attributes('disabled')).toBeUndefined();
    });

    it('queues the prompt instead of sending it', async () => {
      findChatInputNative().element.value = 'queued prompt';
      await findChatInputNative().trigger('input');
      clickSubmit();
      await waitForChatSubmission();

      expect(wrapper.emitted('queue-chat-prompt')).toEqual([[sent('queued prompt')]]);
      expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
    });

    it('queues a turn it did not start itself, such as one streaming from a queued prompt', async () => {
      // The regression: canSubmit stays true when the composer did not submit
      // the running turn, so it used to send straight into the stream.
      await wrapper.setProps({
        isLoading: true,
        lastMessage: { chunks: ['partial'], chunkId: 0 },
      });

      findChatInputNative().element.value = 'typed while streaming';
      await findChatInputNative().trigger('input');
      clickSubmit();
      await waitForChatSubmission();

      expect(wrapper.emitted('queue-chat-prompt')).toEqual([[sent('typed while streaming')]]);
      expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
    });
  });

  describe('slash commands', () => {
    const findSlashCommandsMenu = () => wrapper.findComponent(SlashCommandsMenu);

    // The bundled plugins are what production registers, and the composer's own tests
    // are about what it does with a command rather than where the list came from.
    const registryWithBundledPlugins = () => {
      const registry = new DuoChatPluginRegistry();
      initializePlugins(registry);
      return registry;
    };

    beforeEach(() => {
      createComponent({
        mountFn: mountExtended,
        provide: {
          duoChatPluginRegistry: registryWithBundledPlugins(),
          duoChatContext: { projectId: 'gid://gitlab/Project/1' },
        },
      });
    });

    it('wraps the textarea in the menu and feeds it the current prompt', async () => {
      await findChatInputNative().setValue('hello');

      expect(findSlashCommandsMenu().exists()).toBe(true);
      expect(findSlashCommandsMenu().props('value')).toBe('hello');
    });

    it('sends immediately for a command marked shouldSubmit', async () => {
      await findChatInputNative().setValue('/co');
      findSlashCommandsMenu().vm.$emit(
        'select',
        { value: '/compact', shouldSubmit: true },
        { triggerIndex: 0, token: '/co' },
      );
      await waitForChatSubmission();

      expect(wrapper.emitted('send-chat-prompt')).toEqual([[sentWithCompact]]);
    });

    // No shipped command sets shouldSubmit: false, so the branch is driven with
    // a synthetic one rather than left uncovered.
    it('inserts a trailing space and waits for a command that does not submit', async () => {
      await findChatInputNative().setValue('/dr');
      findSlashCommandsMenu().vm.$emit(
        'select',
        { value: '/draft', shouldSubmit: false },
        { triggerIndex: 0, token: '/dr' },
      );
      await waitForChatSubmission();

      expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
      expect(findChatInputNative().element.value).toBe('/draft ');
    });

    // The end-to-end path -- menu opens, Enter selects, the command reaches the
    // websocket -- lives in the MSW integration spec, which can see that /new is
    // handled locally while /compact starts a workflow. What is left here is the
    // composer's own contract with the menu.
    describe('Enter while the menu is open', () => {
      const openMenuOn = async (text, caret = text.length) => {
        const textarea = findChatInputNative().element;
        textarea.value = text;
        textarea.setSelectionRange(caret, caret);
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        await nextTick();
        // The commands are resolved from the plugin registry, so the options are one
        // microtask behind the keystroke that asked for them.
        await waitForPromises();
      };

      const pressEnter = async () => {
        const textarea = findChatInputNative().element;
        const options = { key: 'Enter', bubbles: true, cancelable: true };

        textarea.dispatchEvent(new KeyboardEvent('keydown', options));
        await nextTick();
        textarea.dispatchEvent(new KeyboardEvent('keyup', options));
        await waitForChatSubmission();
      };

      // Choosing a command fills the composer rather than sending, so this also
      // covers that the Enter which took the command did not send anything.
      it('inserts the command and sends nothing', async () => {
        await openMenuOn('/co');

        await pressEnter();

        expect(findChatInputNative().element.value).toBe('/compact ');
        expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
      });

      // Replacing the whole prompt used to discard whatever the user had
      // already written after the command.
      it('keeps text that follows the command', async () => {
        await openMenuOn('/co hello world', 3);

        await pressEnter();

        expect(findChatInputNative().element.value).toBe('/compact hello world');
        expect(wrapper.emitted('send-chat-prompt')).toBeUndefined();
      });

      // The menu swallows the keyup, so the reset at the end of onInputKeyup is
      // skipped and onSlashCommandSelect has to clear the flag instead. Asserted
      // through a later Enter rather than the flag itself: a stuck flag is only a
      // bug because it silently discards the next send.
      it('leaves a later Enter able to send after composing', async () => {
        await openMenuOn('/co');
        await findChatInputNative().trigger('compositionend');

        await pressEnter();

        await findChatInputNative().trigger('keyup', { key: 'Enter' });
        await waitForChatSubmission();

        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sentWithCompact]]);
      });
    });

    // The menu is the only thing that knows a command's metadata, but the user can
    // always type the token themselves. Both routes have to produce the same payload,
    // or a consumer cannot trust `slashCommands` to describe the prompt.
    it('carries a command the user typed without ever opening the menu', async () => {
      const textarea = findChatInputNative().element;
      // Trailing space closes the menu, so this is a plain Enter, not a selection.
      textarea.value = '/compact ';
      textarea.setSelectionRange(9, 9);
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      await nextTick();

      textarea.dispatchEvent(
        new KeyboardEvent('keyup', { key: 'Enter', bubbles: true, cancelable: true }),
      );
      await waitForChatSubmission();

      expect(wrapper.emitted('send-chat-prompt')).toEqual([[sentWithCompact]]);
    });

    describe('resolving the commands', () => {
      let getCommands;

      const COMMANDS = [{ value: '/compact', description: 'Compact this conversation' }];
      const A_PROJECT = { projectId: 'gid://gitlab/Project/1' };
      const ANOTHER_PROJECT = { projectId: 'gid://gitlab/Project/2' };

      // `answer` takes over from `commands` to control *when* a provider replies.
      const createWithPlugin = ({ commands = COMMANDS, answer = null, withPlugin = true } = {}) => {
        getCommands = jest.fn(answer ?? (() => Promise.resolve(commands)));

        const registry = new DuoChatPluginRegistry();
        if (withPlugin) {
          registry.registerPlugin({ name: 'a_plugin', slashCommands: [{ getCommands }] });
        }

        createComponent({
          propsData: { duoChatContext: A_PROJECT },
          provide: { duoChatPluginRegistry: registry },
        });
      };

      const type = async (text) => {
        setPromptInput(text);
        await waitForPromises();
      };

      const moveContext = async () => {
        await wrapper.setProps({ duoChatContext: ANOTHER_PROJECT });
        await waitForPromises();
      };

      it('asks the plugins for the commands of the current chat context', async () => {
        createWithPlugin();

        await type('/');

        expect(getCommands).toHaveBeenCalledWith(
          expect.objectContaining({ duoChatContext: A_PROJECT }),
        );
      });

      it('hands the commands to the menu once they arrive', async () => {
        createWithPlugin();

        await type('/');

        expect(findSlashCommandsMenu().props('commands')).toEqual(COMMANDS);
      });

      it('gives the menu an empty list when the plugins offer nothing', async () => {
        createWithPlugin({ withPlugin: false });

        await type('/');

        expect(findSlashCommandsMenu().props('commands')).toEqual([]);
      });

      // A provider may go to the network to answer, and most messages hold no command.
      describe('waiting until a command could be wanted', () => {
        it('asks for nothing while the prompt holds no command', async () => {
          createWithPlugin();

          await waitForPromises();

          expect(getCommands).not.toHaveBeenCalled();
        });

        it.each(['hello', 'https://example.com', 'and/or'])(
          'stays quiet for %p, which holds no command',
          async (text) => {
            createWithPlugin();

            await type(text);

            expect(getCommands).not.toHaveBeenCalled();
          },
        );

        it('asks once for a command typed one character at a time', async () => {
          createWithPlugin();

          await type('/');
          await type('/co');
          await type('/compact');

          expect(getCommands).toHaveBeenCalledTimes(1);
        });

        it('tells the menu it is waiting, so a trigger does not look ignored', async () => {
          let answer;
          createWithPlugin({
            answer: () =>
              new Promise((resolve) => {
                answer = resolve;
              }),
          });

          await type('/');
          expect(findSlashCommandsMenu().props('isLoading')).toBe(true);

          answer(COMMANDS);
          await waitForPromises();
          expect(findSlashCommandsMenu().props('isLoading')).toBe(false);
        });
      });

      it('carries the command when the prompt is sent before the plugins answer', async () => {
        let answer;
        createWithPlugin({
          answer: () =>
            new Promise((resolve) => {
              answer = resolve;
            }),
        });

        setPromptInput('/compact');
        await nextTick();

        clickSubmit();
        answer(COMMANDS);
        await waitForPromises();

        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sentWithCompact]]);
      });

      it('asks once for a send in the same context as the menu', async () => {
        createWithPlugin();
        await type('/compact');

        clickSubmit();
        await waitForPromises();

        expect(getCommands).toHaveBeenCalledTimes(1);
        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sentWithCompact]]);
      });

      // `resolve` contains provider failures itself, so this is the unexpected case.
      describe('when resolving fails', () => {
        const failOnce = () =>
          jest.spyOn(slashCommands, 'resolve').mockRejectedValueOnce(new Error('exploded'));

        it('asks again on the next trigger rather than staying empty', async () => {
          createWithPlugin();
          failOnce();
          await type('/');

          await type('/co');
          await waitForPromises();

          expect(findSlashCommandsMenu().props('commands')).toEqual(COMMANDS);
        });

        it('still sends, with whatever it holds', async () => {
          createWithPlugin();
          jest.spyOn(slashCommands, 'resolve').mockRejectedValue(new Error('exploded'));
          await type('/compact');

          clickSubmit();
          await waitForPromises();

          expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent('/compact')]]);
        });
      });

      it('sends a prompt with no command without asking the plugins', async () => {
        createWithPlugin();
        await type('hello');

        clickSubmit();
        await waitForPromises();

        expect(getCommands).not.toHaveBeenCalled();
        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent('hello')]]);
      });

      describe('when the chat moves to another context', () => {
        it('asks the plugins again, for the context the chat is now on', async () => {
          createWithPlugin();
          await type('/');

          await moveContext();

          expect(getCommands).toHaveBeenLastCalledWith(
            expect.objectContaining({ duoChatContext: ANOTHER_PROJECT }),
          );
        });

        it('drops the commands of the context the chat has left', async () => {
          createWithPlugin();
          await type('/');

          wrapper.setProps({ duoChatContext: ANOTHER_PROJECT });
          await nextTick();

          expect(findSlashCommandsMenu().props('commands')).toEqual([]);
        });
      });
    });

    describe('Enter with no menu open', () => {
      it('still sends the prompt', async () => {
        const textarea = findChatInputNative().element;
        textarea.value = 'hello there';
        textarea.setSelectionRange(11, 11);
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        await nextTick();

        textarea.dispatchEvent(
          new KeyboardEvent('keyup', { key: 'Enter', bubbles: true, cancelable: true }),
        );
        await waitForChatSubmission();

        expect(wrapper.emitted('send-chat-prompt')).toEqual([[sent('hello there')]]);
      });
    });
  });
});
