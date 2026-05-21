import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentFlowSessionMessage from 'ee/ai/duo_agents_platform/components/common/agent_flow_session_message.vue';

describe('AgentFlowSessionMessage', () => {
  let wrapper;

  const defaultProps = {
    icon: 'status_running',
    title: 'Creating session',
    timestamp: '2024-01-01T00:00:00Z',
  };

  const createComponent = (props = {}, slots = {}) => {
    wrapper = shallowMountExtended(AgentFlowSessionMessage, {
      propsData: { ...defaultProps, ...props },
      slots,
      stubs: {
        TimeAgoTooltip: true,
      },
    });
  };

  const findContainer = () => wrapper.findByTestId('agent-flow-session-message');
  const findIcon = () => wrapper.findByTestId('session-message-icon');
  const findTitle = () => wrapper.findByTestId('log-entry-title');
  const findTimestamp = () => wrapper.findByTestId('log-entry-timestamp');

  beforeEach(() => {
    createComponent();
  });

  it('renders the session message container as a list item', () => {
    expect(findContainer().element.tagName).toBe('LI');
  });

  it('renders the title', () => {
    expect(findTitle().text()).toBe(defaultProps.title);
  });

  it('renders the icon with the correct name and default subtle variant', () => {
    expect(findIcon().props()).toMatchObject({ name: defaultProps.icon, variant: 'subtle' });
  });

  it('renders the timestamp with the given time', () => {
    expect(findTimestamp().props('time')).toBe(defaultProps.timestamp);
  });

  describe('iconVariant prop', () => {
    it('applies a custom icon variant when provided', () => {
      createComponent({ iconVariant: 'danger' });

      expect(findIcon().props('variant')).toBe('danger');
    });
  });

  describe('default slot', () => {
    it('renders slot content below the title row', () => {
      createComponent({}, { default: '<span data-testid="slot-content">Extra info</span>' });

      expect(wrapper.findByTestId('slot-content').text()).toBe('Extra info');
    });

    it('renders nothing in the slot area when no slot content is provided', () => {
      createComponent();

      expect(findContainer().text()).toContain(defaultProps.title);
    });
  });
});
