import { GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SessionDetailsDrawer from 'ee/agent_artifacts/components/session_details_drawer.vue';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';

jest.mock('ee/ai/duo_agents_platform/utils', () => ({
  formatAgentDefinition: jest.fn((name) => name),
}));

describe('SessionDetailsDrawer', () => {
  let wrapper;

  const mockActiveItem = {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
    name: 'false_positive_detection/v1',
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
      webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions',
    },
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(SessionDetailsDrawer, {
      propsData: {
        activeItem: mockActiveItem,
        ...props,
      },
      stubs: {
        MountingPortal: { template: '<div><slot /></div>' },
        GlButton,
      },
    });
  };

  const findDrawer = () => wrapper.findByTestId('session-details-drawer');
  const findDrawerTitle = () => wrapper.findByTestId('drawer-title');
  const findCloseButton = () => wrapper.findByTestId('session-details-drawer-close-button');
  const findDrawerContentTitle = () => wrapper.findByTestId('drawer-content-title');

  beforeEach(() => {
    createComponent();
  });

  it('renders the drawer', () => {
    expect(findDrawer().exists()).toBe(true);
  });

  it('displays formatted agent name in title', () => {
    expect(findDrawerTitle().text()).toBe(formatAgentDefinition(mockActiveItem.name));
  });

  it('displays formatted agent name in content', () => {
    expect(findDrawerContentTitle().text()).toBe(formatAgentDefinition(mockActiveItem.name));
  });

  it('renders close button', () => {
    expect(findCloseButton().exists()).toBe(true);
  });

  it('emits close event when close button is clicked', async () => {
    await findCloseButton().trigger('click');

    expect(wrapper.emitted('close')).toHaveLength(1);
  });

  describe('keyboard navigation', () => {
    it('emits close event when Escape key is pressed', () => {
      const event = new KeyboardEvent('keydown', { key: 'Escape' });
      document.dispatchEvent(event);

      expect(wrapper.emitted('close')).toHaveLength(1);
    });

    it('does not emit close event when other keys are pressed', () => {
      const event = new KeyboardEvent('keydown', { key: 'Enter' });
      document.dispatchEvent(event);

      expect(wrapper.emitted('close')).toBeUndefined();
    });
  });

  describe('event listener cleanup', () => {
    it('removes keydown event listener on destroy', () => {
      const removeEventListenerSpy = jest.spyOn(document, 'removeEventListener');

      wrapper.destroy();

      expect(removeEventListenerSpy).toHaveBeenCalledWith('keydown', wrapper.vm.closeOnEscape);
    });
  });
});
