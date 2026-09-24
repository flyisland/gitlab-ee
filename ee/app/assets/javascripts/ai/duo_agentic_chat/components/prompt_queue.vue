<script>
import { v4 as uuidv4 } from 'uuid';
import {
  getSessionStorageValue,
  saveSessionStorageValue,
  removeSessionStorageValue,
} from '~/lib/utils/local_storage';
import { normalizeRender } from '~/lib/utils/vue3compat/normalize_render';
import { DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY } from 'ee/ai/constants';

const isReload = () => window.performance?.getEntriesByType?.('navigation')?.[0]?.type === 'reload';

// Only the first queue of a page load discards a stale one, so re-opening the
// chat later in that same page keeps whatever the user has queued since.
let staleQueueDiscarded = false;

/**
 * A link navigation carries the queue over to the next page, but a reload is the
 * user deliberately resetting the chat, and prompts they queued before it should
 * not fire on their own afterwards.
 */
const loadQueuedPrompts = () => {
  const discard = !staleQueueDiscarded && isReload();
  staleQueueDiscarded = true;

  if (discard) {
    removeSessionStorageValue(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY);
    return [];
  }

  const stored = getSessionStorageValue(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY);
  // The storage key is versioned, so anything read here was written by a bundle that
  // agrees on the shape. The guard is for a hand-edited or truncated value.
  return Array.isArray(stored.value) ? stored.value.filter((item) => item?.prompt) : [];
};

/**
 * Renderless owner of the prompts a user submits while an agent turn is in
 * progress. Holds them in sessionStorage so a queue survives a page navigation
 * the same way the active workflow does, and releases them one at a time
 * through `send` whenever `canSend` says the chat could take a prompt.
 */
export default normalizeRender({
  name: 'PromptQueue',
  props: {
    /**
     * Whether the chat could accept a prompt right now. The queue drains itself
     * the moment this turns true, so it must cover every reason a prompt would
     * be dropped rather than sent.
     */
    canSend: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['change', 'send'],
  data() {
    return {
      prompts: loadQueuedPrompts(),
    };
  },
  watch: {
    prompts(prompts) {
      if (prompts.length) {
        saveSessionStorageValue(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY, prompts);
      } else {
        removeSessionStorageValue(DUO_CHAT_QUEUED_PROMPTS_STORAGE_KEY);
      }
      this.$emit('change', prompts);
    },
    canSend: 'drain',
  },
  created() {
    if (this.prompts.length) {
      this.$emit('change', this.prompts);
    }
  },
  methods: {
    // enqueue, remove and clear are the imperative surface the state manager
    // drives through its ref.
    enqueue(prompt) {
      this.prompts = [...this.prompts, { id: uuidv4(), prompt }];
    },
    remove(id) {
      this.prompts = this.prompts.filter((prompt) => prompt.id !== id);
    },
    clear() {
      this.prompts = [];
    },
    async drain() {
      if (!this.canSend || !this.prompts.length) return;

      const [next] = this.prompts;
      this.remove(next.id);
      this.$emit('send', next.prompt);

      // Base commands (/reset, /clear, /new) and easter eggs are handled without
      // starting a turn, so canSend never flips and this watcher won't run again.
      // Re-check once the parent has re-rendered so later prompts don't stall.
      await this.$nextTick();
      this.drain();
    },
  },
  render: () => null,
});
</script>
