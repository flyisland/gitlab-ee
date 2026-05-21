import { shallowMount } from '@vue/test-utils';
import { GlSkeletonLoader } from '@gitlab/ui';
import AgentActivityLogs from 'ee/ai/duo_agents_platform/pages/show/components/agent_activity_logs.vue';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';
import AgentFlowFailedState from 'ee/ai/duo_agents_platform/components/common/agent_flow_failed_state.vue';
import { mockItems } from '../../../components/common/mock';

describe('AgentActivityLogs', () => {
  let wrapper;

  const findActivityLogs = () => wrapper.findComponent(ActivityLogs);
  const findSkeletonLoader = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findEmptyState = () => wrapper.findComponent(AgentFlowEmptyState);
  const findFailedState = () => wrapper.findComponent(AgentFlowFailedState);

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(AgentActivityLogs, {
      propsData: {
        isLoading: false,
        duoMessages: [],
        status: 'RUNNING',
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-15T00:00:00Z',
        userId: 'gid://gitlab/User/1',
        canResumeWorkflow: false,
        canUpdateWorkflow: false,
        ...props,
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
      expect(findFailedState().exists()).toBe(false);
    });
  });

  describe('when session has failed with messages', () => {
    beforeEach(() => createWrapper({ duoMessages: mockItems, status: 'FAILED' }));

    it('renders ActivityLogs', () => {
      expect(findActivityLogs().exists()).toBe(true);
    });

    it('renders the failed state', () => {
      expect(findFailedState().exists()).toBe(true);
    });
  });
});
