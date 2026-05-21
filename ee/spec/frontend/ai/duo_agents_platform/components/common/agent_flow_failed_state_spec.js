import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowFailedState from 'ee/ai/duo_agents_platform/components/common/agent_flow_failed_state.vue';
import AgentFlowSessionMessage from 'ee/ai/duo_agents_platform/components/common/agent_flow_session_message.vue';

describe('AgentFlowFailedState', () => {
  let wrapper;

  const defaultProps = {
    updatedAt: '2024-01-15T00:00:00Z',
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AgentFlowFailedState, {
      propsData: { ...defaultProps, ...props },
      stubs: {
        AgentFlowSessionMessage: true,
      },
    });
  };

  const findSessionMessage = () => wrapper.findComponent(AgentFlowSessionMessage);

  beforeEach(() => {
    createComponent();
  });

  it('renders an AgentFlowSessionMessage with the correct props', () => {
    expect(findSessionMessage().props()).toMatchObject({
      icon: 'status_failed',
      iconVariant: 'danger',
      title: 'Session failed',
      timestamp: defaultProps.updatedAt,
    });
  });
});
