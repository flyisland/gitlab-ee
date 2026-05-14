import { shallowMount } from '@vue/test-utils';
import { GlSkeletonLoader } from '@gitlab/ui';
import AgentActivityLogs from 'ee/ai/duo_agents_platform/pages/show/components/agent_activity_logs.vue';
import ActivityLogs from 'ee/ai/duo_agents_platform/components/common/activity_logs.vue';
import AgentFlowEmptyState from 'ee/ai/duo_agents_platform/components/common/agent_flow_empty_state.vue';

describe('AgentActivityLogs', () => {
  let wrapper;

  // Finders
  const findActivityLogs = () => wrapper.findComponent(ActivityLogs);
  const findSkeletonLoader = () => wrapper.findAllComponents(GlSkeletonLoader);
  const findEmptyState = () => wrapper.findComponent(AgentFlowEmptyState);

  const createWrapper = (props = {}) => {
    return shallowMount(AgentActivityLogs, {
      propsData: {
        isLoading: false,
        duoMessages: [],
        ...props,
      },
    });
  };

  describe('when component is rendered', () => {
    describe('and it is loading', () => {
      beforeEach(() => {
        wrapper = createWrapper({ isLoading: true });
      });

      it('renders the fetching logs message', () => {
        expect(findSkeletonLoader().exists()).toBe(true);
      });

      it('does not render the empty state', () => {
        expect(findEmptyState().exists()).toBe(false);
      });

      it('does not render the activity logs', () => {
        expect(findActivityLogs().exists()).toBe(false);
      });
    });

    describe('when not loading', () => {
      describe('when no logs', () => {
        beforeEach(() => {
          wrapper = createWrapper({ duoMessages: [] });
        });

        it('displays the empty state', () => {
          expect(findEmptyState().exists()).toBe(true);
        });

        it('does not render ActivityLogs component', () => {
          expect(findActivityLogs().exists()).toBe(false);
        });

        it('does not renders the loading state', () => {
          expect(findSkeletonLoader().exists()).toBe(false);
        });
      });

      describe('when has logs', () => {
        const mockDuoMessages = [
          {
            id: 1,
            content: 'Start message',
            messageType: 'agent',
            status: 'success',
            timestamp: '2022-03-11T04:34:59Z',
          },
          {
            id: 2,
            content: 'Tool message',
            messageType: 'tool',
            status: 'success',
            timestamp: '2022-03-11T04:34:59Z',
            toolInfo: { name: 'read_file' },
          },
          {
            id: 3,
            content: 'Agent reasoning',
            messageType: 'agent',
            status: 'success',
            timestamp: '2022-03-11T04:34:59Z',
          },
        ];

        beforeEach(() => {
          wrapper = createWrapper({ duoMessages: mockDuoMessages });
        });

        it('renders ActivityLogs component', () => {
          expect(findActivityLogs().exists()).toBe(true);
        });

        it('passes all logs to ActivityLogs component by default', () => {
          expect(findActivityLogs().props('items')).toHaveLength(3);
        });
      });
    });
  });
});
