import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import PromptQueue from 'ee/ai/duo_agentic_chat/components/prompt_queue.vue';
import { createUserPrompt } from 'ee/ai/duo_agentic_chat/services/user_prompt';
import { DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY } from 'ee/ai/constants';

describe('PromptQueue', () => {
  let wrapper;

  const promptFor = (text) => createUserPrompt({ text });
  const queued = (text) => ({ id: expect.any(String), prompt: promptFor(text) });

  const stored = () => JSON.parse(sessionStorage.getItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY));
  const lastChange = () => wrapper.emitted('change').at(-1)[0];
  const sentPrompts = () => (wrapper.emitted('send') ?? []).map(([prompt]) => prompt.text);

  const createComponent = ({ canSend = false } = {}) => {
    wrapper = shallowMount(PromptQueue, { propsData: { canSend } });
  };

  // The queue only ever fills up while the chat cannot take a prompt, so that is
  // the state every seeding helper starts from.
  const enqueueAll = async (...texts) => {
    texts.forEach((text) => wrapper.vm.enqueue(promptFor(text)));
    await nextTick();
  };

  beforeEach(() => {
    sessionStorage.clear();
  });

  it('renders nothing', () => {
    createComponent();

    expect(wrapper.html()).toBe('');
  });

  describe('holding prompts', () => {
    beforeEach(() => {
      createComponent();
    });

    it('appends each prompt with a unique id, preserving order', async () => {
      await enqueueAll('first', 'second');

      expect(lastChange()).toEqual([queued('first'), queued('second')]);
      const [{ id: firstId }, { id: secondId }] = lastChange();
      expect(firstId).not.toBe(secondId);
    });

    it('removes only the prompt with the matching id', async () => {
      await enqueueAll('first', 'second');
      const [{ id }] = lastChange();

      wrapper.vm.remove(id);
      await nextTick();

      expect(lastChange()).toEqual([queued('second')]);
    });

    it('empties the queue on clear', async () => {
      await enqueueAll('first', 'second');

      wrapper.vm.clear();
      await nextTick();

      expect(lastChange()).toEqual([]);
    });
  });

  describe('persistence', () => {
    it('mirrors the queue to sessionStorage', async () => {
      createComponent();

      await enqueueAll('first');

      expect(stored()).toEqual([queued('first')]);
    });

    it('drops the stored queue once the last prompt leaves it', async () => {
      createComponent();
      await enqueueAll('first');

      wrapper.vm.clear();
      await nextTick();

      expect(sessionStorage.getItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY)).toBe(null);
    });

    it('restores a queue left behind by a previous page', () => {
      const restored = [{ id: 'q1', prompt: promptFor('from a previous page') }];
      sessionStorage.setItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY, JSON.stringify(restored));

      createComponent();

      expect(lastChange()).toEqual(restored);
    });

    it('discards a queue written by an older bundle rather than half-restoring it', () => {
      sessionStorage.setItem(
        DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY,
        JSON.stringify([{ id: 'q1', content: 'a bare string' }]),
      );

      createComponent();

      expect(wrapper.vm.prompts).toEqual([]);
    });

    it('starts empty, without announcing a change, when nothing was stored', () => {
      createComponent();

      expect(wrapper.emitted('change')).toBeUndefined();
    });
  });

  describe('discarding a queue left by the previous page', () => {
    const restored = [{ id: 'q1', prompt: promptFor('from a previous page') }];

    // jsdom implements no performance entries at all, so the method has to be
    // defined rather than spied on.
    const mockNavigation = (type) => {
      window.performance.getEntriesByType = jest.fn((entryType) =>
        entryType === 'navigation' ? [{ type }] : [],
      );
    };

    // The discard happens once per page load, which the module tracks, so each
    // case needs its own copy of it. Mounting the same copy again stands in for
    // re-opening the chat panel within that page load.
    let ReloadedPromptQueue;
    const startPageLoad = () => {
      jest.isolateModules(() => {
        // eslint-disable-next-line global-require
        ReloadedPromptQueue = require('ee/ai/duo_agentic_chat/components/prompt_queue.vue').default;
      });
    };
    const mountQueue = ({ canSend = false } = {}) => {
      wrapper = shallowMount(ReloadedPromptQueue, { propsData: { canSend } });
    };
    const mountFreshPageLoad = (options) => {
      startPageLoad();
      mountQueue(options);
    };

    beforeEach(() => {
      sessionStorage.setItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY, JSON.stringify(restored));
    });

    afterEach(() => {
      delete window.performance.getEntriesByType;
    });

    it('drops the stored queue when the page was reloaded', () => {
      mockNavigation('reload');

      mountFreshPageLoad();

      expect(wrapper.vm.prompts).toEqual([]);
      expect(sessionStorage.getItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY)).toBe(null);
    });

    it('never sends a prompt queued before the reload', async () => {
      mockNavigation('reload');
      mountFreshPageLoad();

      await wrapper.setProps({ canSend: true });
      await waitForPromises();

      expect(wrapper.emitted('send')).toBeUndefined();
    });

    it('keeps the stored queue when the page was navigated to', () => {
      mockNavigation('navigate');

      mountFreshPageLoad();

      expect(wrapper.vm.prompts).toEqual(restored);
    });

    it('keeps a queue built after the reload when the chat is re-opened', async () => {
      mockNavigation('reload');
      mountFreshPageLoad();
      wrapper.vm.enqueue(promptFor('queued since the reload'));
      await nextTick();

      // Re-opening the chat panel remounts the queue within the same page load.
      mountQueue();

      expect(wrapper.vm.prompts).toEqual([queued('queued since the reload')]);
    });
  });

  describe('draining', () => {
    it('holds every prompt while the chat cannot take one', async () => {
      createComponent({ canSend: false });

      await enqueueAll('first', 'second');

      expect(wrapper.emitted('send')).toBeUndefined();
      expect(lastChange()).toHaveLength(2);
    });

    it('sends the first prompt as soon as the chat can take one', async () => {
      createComponent({ canSend: false });
      await enqueueAll('first', 'second');

      await wrapper.setProps({ canSend: true });
      await nextTick();

      expect(sentPrompts()[0]).toBe('first');
    });

    it('keeps draining while the chat stays ready, so a prompt that starts no turn does not stall the rest', async () => {
      createComponent({ canSend: false });
      await enqueueAll('first', 'second');

      await wrapper.setProps({ canSend: true });
      await waitForPromises();

      expect(sentPrompts()).toEqual(['first', 'second']);
      expect(lastChange()).toEqual([]);
    });

    it('drains a queue restored from sessionStorage once the chat is ready', async () => {
      sessionStorage.setItem(
        DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY,
        JSON.stringify([{ id: 'q1', prompt: promptFor('from a previous page') }]),
      );
      createComponent({ canSend: false });

      await wrapper.setProps({ canSend: true });
      await waitForPromises();

      expect(sentPrompts()).toEqual(['from a previous page']);
      expect(sessionStorage.getItem(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY)).toBe(null);
    });

    it('does nothing when the chat becomes ready with an empty queue', async () => {
      createComponent({ canSend: false });

      await wrapper.setProps({ canSend: true });
      await waitForPromises();

      expect(wrapper.emitted('send')).toBeUndefined();
    });
  });
});
