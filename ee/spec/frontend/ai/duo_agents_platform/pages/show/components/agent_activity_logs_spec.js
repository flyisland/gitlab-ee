import { shallowMount } from '@vue/test-utils';
import { GlSkeletonLoader } from '@gitlab/ui';
import { DuoChatContextConversation as DuoChatConversation } from '@gitlab/duo-ui';
import AgentActivityLogs from 'ee/ai/duo_agents_platform/pages/show/components/agent_activity_logs.vue';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowSessionMessage from 'ee/ai/duo_agents_platform/components/common/agent_flow_session_message.vue';
import MessageTodoChecklist from 'ee/ai/duo_agents_platform/components/common/message_todo_checklist.vue';
import { mockItems, mockDelegationSequence } from '../../../components/common/mock';

describe('AgentActivityLogs', () => {
  let wrapper;

  const findActivityLogs = () => wrapper.findComponent(ActivityLogs);
  const findChatConversation = () => wrapper.findComponent(DuoChatConversation);
  const findSkeletonLoader = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findEmptyState = () => wrapper.findComponent(AgentFlowEmptyState);
  const findFailedState = () => wrapper.findAllComponents(AgentFlowSessionMessage);

  const createWrapper = (props = {}, { provide } = {}) => {
    wrapper = shallowMount(AgentActivityLogs, {
      propsData: {
        isLoading: false,
        duoMessages: [],
        createdAt: '2022-03-11T04:30:00Z',
        updatedAt: '2022-03-11T04:35:00Z',
        status: 'FINISHED',
        user: {},
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
        ...props,
      },
      provide: {
        glFeatures: { duoSessionChatBubbles: false },
        ...provide,
      },
    });
  };

  describe('when loading', () => {
    beforeEach(() => createWrapper({ isLoading: true }));

    it('renders skeleton loaders', () => {
      expect(findSkeletonLoader().exists()).toBe(true);
    });

    it('does not render the empty state or activity logs', () => {
      expect(findEmptyState().exists()).toBe(false);
      expect(findActivityLogs().exists()).toBe(false);
    });
  });

  describe('when not loading with no messages', () => {
    beforeEach(() => createWrapper({ duoMessages: [] }));

    it('renders the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('does not render activity logs or skeleton loaders', () => {
      expect(findActivityLogs().exists()).toBe(false);
      expect(findSkeletonLoader().exists()).toBe(false);
    });
  });

  describe('when not loading with messages', () => {
    beforeEach(() => createWrapper({ duoMessages: mockItems }));

    it('renders ActivityLogs with all messages by default', () => {
      expect(findActivityLogs().props('items')).toHaveLength(mockItems.length);
    });

    it('does not render the failed state when status is not FAILED', () => {
      expect(findFailedState()).toHaveLength(0);
    });
  });

  describe('when session has failed with messages', () => {
    beforeEach(() => createWrapper({ duoMessages: mockItems, status: 'FAILED' }));
    it('renders ActivityLogs', () => {
      expect(findActivityLogs().exists()).toBe(true);
    });

    it('renders the failed state session message with correct props', () => {
      const failedMessage = findFailedState().at(0);
      expect(failedMessage.props()).toMatchObject({
        icon: 'status_failed',
        iconVariant: 'danger',
        title: 'Session failed',
      });
    });
  });
  describe('when messages include delegation entries', () => {
    beforeEach(() => {
      createWrapper({ duoMessages: mockDelegationSequence });
    });

    it('passes all messages including delegation entries to ActivityLogs', () => {
      expect(findActivityLogs().props('items')).toEqual(mockDelegationSequence);
    });
  });

  describe('todo_write spinner freezing', () => {
    const todoItem = (todos) => ({
      id: JSON.stringify(todos),
      content: 'Plan updated',
      messageType: 'tool',
      status: 'success',
      timestamp: '2023-01-01T10:00:00Z',
      toolInfo: JSON.stringify({ name: 'todo_write', args: { todos } }),
    });
    const todoItems = [
      todoItem([{ description: 'first plan', status: 'in_progress' }]),
      todoItem([{ description: 'second plan', status: 'in_progress' }]),
    ];
    const findTodoItems = () =>
      findActivityLogs()
        .props('items')
        .filter((item) => item.toolInfo?.includes('todo_write'));

    describe('when the session is still running', () => {
      beforeEach(() => {
        createWrapper({ duoMessages: todoItems, status: 'RUNNING' });
      });

      it('marks earlier todo lists as finished and leaves the latest one active', () => {
        const todos = findTodoItems();
        expect(todos[0].todoFinished).toBe(true);
        expect(todos[1].todoFinished).toBe(false);
      });
    });

    describe('when the session has reached a terminal state', () => {
      beforeEach(() => {
        createWrapper({ duoMessages: todoItems, status: 'FINISHED' });
      });

      it('freezes all todo lists', () => {
        expect(findTodoItems().every((item) => item.todoFinished)).toBe(true);
      });
    });
  });

  describe('with duoSessionChatBubbles feature flag enabled', () => {
    const chatBubblesProvide = { glFeatures: { duoSessionChatBubbles: true } };

    describe('with messages', () => {
      beforeEach(() => {
        createWrapper({ duoMessages: mockItems }, { provide: chatBubblesProvide });
      });

      it('renders DuoChatConversation instead of ActivityLogs', () => {
        expect(findChatConversation().exists()).toBe(true);
        expect(findActivityLogs().exists()).toBe(false);
      });

      it('passes transformed messages to DuoChatConversation', () => {
        const messages = findChatConversation().props('messages');

        expect(messages).toHaveLength(mockItems.length);
        expect(messages[0]).toMatchObject({
          message_type: mockItems[0].messageType,
          role: expect.any(String),
        });
      });

      it('passes useChatBubbles to the empty state', () => {
        expect(findEmptyState().props('useChatBubbles')).toBe(true);
      });

      it('disables feedback, code insertion, and delimiter', () => {
        expect(findChatConversation().props('showDelimiter')).toBe(false);
        expect(findChatConversation().props('withFeedback')).toBe(false);
        expect(findChatConversation().props('enableCodeInsertion')).toBe(false);
      });

      it('passes messageRenderers with the approval request renderer', () => {
        const renderers = findChatConversation().props('messageRenderers');

        expect(renderers).toHaveLength(2);
        expect(renderers[0].matchMessage({ message_type: 'request' })).toBe(true);
        expect(renderers[0].matchMessage({ message_type: 'agent' })).toBe(false);
      });

      it('passes messageRenderers with the todo_write renderer', () => {
        const renderers = findChatConversation().props('messageRenderers');
        const todoRenderer = renderers.find((r) => r.component === MessageTodoChecklist);

        expect(todoRenderer.matchMessage({ tool_info: { name: 'todo_write' } })).toBe(true);
        expect(
          todoRenderer.matchMessage({ tool_info: JSON.stringify({ name: 'todo_write' }) }),
        ).toBe(true);
        expect(todoRenderer.matchMessage({ tool_info: { name: 'read_file' } })).toBe(false);
        expect(todoRenderer.matchMessage({ tool_info: null })).toBe(false);
        expect(todoRenderer.matchMessage({})).toBe(false);
      });
    });

    describe('todo_write spinner freezing', () => {
      const todoMessage = (todos) => ({
        messageType: 'tool',
        toolInfo: JSON.stringify({ name: 'todo_write', args: { todos } }),
      });
      const todoMessages = [
        todoMessage([{ description: 'first plan', status: 'in_progress' }]),
        todoMessage([{ description: 'second plan', status: 'in_progress' }]),
      ];
      const findTodoMessages = () =>
        findChatConversation()
          .props('messages')
          .filter((message) => message.tool_info?.name === 'todo_write');

      describe('when the session is still running', () => {
        beforeEach(() => {
          createWrapper(
            { duoMessages: todoMessages, status: 'RUNNING' },
            { provide: chatBubblesProvide },
          );
        });

        it('marks earlier todo lists as finished and leaves the latest one active', () => {
          const todos = findTodoMessages();
          expect(todos[0].todoFinished).toBe(true);
          expect(todos[1].todoFinished).toBe(false);
        });
      });

      describe('when the session has reached a terminal state', () => {
        beforeEach(() => {
          createWrapper(
            { duoMessages: todoMessages, status: 'FINISHED' },
            { provide: chatBubblesProvide },
          );
        });

        it('freezes all todo lists', () => {
          expect(findTodoMessages().every((message) => message.todoFinished)).toBe(true);
        });
      });
    });

    describe('with no messages', () => {
      beforeEach(() => {
        createWrapper({ duoMessages: [] }, { provide: chatBubblesProvide });
      });

      it('renders the empty state', () => {
        expect(findEmptyState().exists()).toBe(true);
      });

      it('does not render DuoChatConversation', () => {
        expect(findChatConversation().exists()).toBe(false);
      });
    });

    describe('when session has failed', () => {
      beforeEach(() => {
        createWrapper(
          { duoMessages: mockItems, status: 'FAILED' },
          { provide: chatBubblesProvide },
        );
      });

      it('does not render the timeline failed state message', () => {
        expect(findFailedState()).toHaveLength(0);
      });

      it('does not append a session failed error bubble to chatMessages', () => {
        const messages = findChatConversation().props('messages');
        const lastMessage = messages[messages.length - 1];

        expect(lastMessage.requestId).not.toBe('session-failed');
      });
    });
  });

  describe('with duoSessionChatBubbles feature flag disabled', () => {
    beforeEach(() => {
      createWrapper({ duoMessages: mockItems });
    });

    it('renders ActivityLogs', () => {
      expect(findActivityLogs().exists()).toBe(true);
    });

    it('does not render DuoChatConversation', () => {
      expect(findChatConversation().exists()).toBe(false);
    });
  });
});
