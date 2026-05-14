import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ThreadExpiredEmptyState from 'ee/ai/duo_agentic_chat/components/thread_expired_empty_state.vue';

describe('ThreadExpiredEmptyState', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMountExtended(ThreadExpiredEmptyState);
  };

  const findContainer = () => wrapper.findByTestId('thread-expired-empty-state');
  const findImage = () => wrapper.find('img');
  const findHeading = () => wrapper.find('h2');
  const findDescription = () => wrapper.find('p');
  const findBackButton = () => wrapper.findByTestId('back-to-threads-button');
  const findNewConversationButton = () => wrapper.findByTestId('new-conversation-button');

  describe('rendering', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the container', () => {
      expect(findContainer().exists()).toBe(true);
    });

    it('renders the tanuki image', () => {
      expect(findImage().exists()).toBe(true);
    });

    it('renders the heading', () => {
      expect(findHeading().text()).toBe('This conversation has expired');
    });

    it('renders the description', () => {
      expect(findDescription().text()).toContain(
        'Conversations expire after more than 30 days of inactivity. Start a new conversation, or select an active conversation from your chat history.',
      );
    });

    it('renders back to threads button', () => {
      expect(findBackButton().exists()).toBe(true);
    });

    it('renders new conversation button', () => {
      expect(findNewConversationButton().exists()).toBe(true);
    });
  });

  describe('events', () => {
    beforeEach(() => {
      createComponent();
    });

    it('emits back-to-list when back button is clicked', () => {
      findBackButton().vm.$emit('click');

      expect(wrapper.emitted('back-to-list')).toHaveLength(1);
    });

    it('emits new-chat when new conversation button is clicked', () => {
      findNewConversationButton().vm.$emit('click');

      expect(wrapper.emitted('new-chat')).toHaveLength(1);
    });
  });
});
