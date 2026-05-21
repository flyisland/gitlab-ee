import { GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SessionDetailsDrawer from 'ee/agent_artifacts/components/session_details_drawer.vue';
import SessionAuditEventsList from 'ee/agent_artifacts/components/session_audit_events_list.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';

jest.mock('ee/ai/duo_agents_platform/utils', () => ({
  formatAgentDefinition: jest.fn((name) => name),
}));

describe('SessionDetailsDrawer', () => {
  let wrapper;

  const mockActiveItem = {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1',
    name: 'false_positive_detection/v1',
    startTime: '2024-01-01T12:00:00Z',
    creditsUsed: 42,
    session: {
      id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
      webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions',
      model: 'claude-3.5-sonnet',
    },
    project: {
      name: 'security-scanner',
      webPath: '/gitlab-org/security-scanner',
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
        CrudComponent,
        GlButton,
      },
    });
  };

  const findDrawer = () => wrapper.findByTestId('session-details-drawer');
  const findDrawerTitle = () => wrapper.findByTestId('drawer-title');
  const findCloseButton = () => wrapper.findByTestId('session-details-drawer-close-button');
  const findDrawerContentTitle = () => wrapper.findByTestId('drawer-content-title');
  const findCrudComponent = () => wrapper.findComponent(CrudComponent);
  const findViewFullSessionButton = () => wrapper.findByTestId('view-full-session-details-button');
  const findSessionRow = () => wrapper.findByTestId('session-row');
  const findDateRow = () => wrapper.findByTestId('date-row');
  const findModelRow = () => wrapper.findByTestId('model-row');
  const findCreditsRow = () => wrapper.findByTestId('credits-row');
  const findProjectRow = () => wrapper.findByTestId('project-row');
  const findAuditEventsList = () => wrapper.findComponent(SessionAuditEventsList);

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

  describe('audit events list', () => {
    it('renders the audit events list with the session id', () => {
      expect(findAuditEventsList().exists()).toBe(true);
    });

    it('does not render the audit events list when there is no session id', () => {
      createComponent({
        activeItem: { ...mockActiveItem, session: { ...mockActiveItem.session, id: null } },
      });

      expect(findAuditEventsList().exists()).toBe(false);
    });
  });

  describe('session details section', () => {
    it('renders CrudComponent', () => {
      expect(findCrudComponent().exists()).toBe(true);
    });

    it('renders view full session details button in actions slot', () => {
      expect(findViewFullSessionButton().exists()).toBe(true);
      expect(findViewFullSessionButton().text()).toBe('View full session details');
      expect(findViewFullSessionButton().attributes('href')).toBe(mockActiveItem.session.webPath);
    });

    it('renders session row with session link', () => {
      expect(findSessionRow().exists()).toBe(true);
      expect(wrapper.findByTestId('session-link').attributes('href')).toBe(
        mockActiveItem.session.webPath,
      );
      expect(wrapper.findByTestId('session-link').text()).toBe('#1908');
    });

    it('renders date row with formatted date', () => {
      expect(findDateRow().exists()).toBe(true);
      expect(wrapper.findByTestId('formatted-date').text()).toBe('2024-01-01 12:00:00 UTC');
    });

    it('renders model row with model name', () => {
      expect(findModelRow().exists()).toBe(true);
      expect(wrapper.findByTestId('model-name').text()).toBe(mockActiveItem.session.model);
    });

    it('does not render model name when model is not present', () => {
      createComponent({
        activeItem: {
          ...mockActiveItem,
          session: {
            ...mockActiveItem.session,
            model: null,
          },
        },
      });

      expect(findModelRow().exists()).toBe(true);
      expect(wrapper.findByTestId('model-name').exists()).toBe(false);
    });

    it('renders credits row with credits used', () => {
      expect(findCreditsRow().exists()).toBe(true);
      expect(wrapper.findByTestId('credits-used').text()).toBe('42');
    });

    it('renders project row with project link', () => {
      expect(findProjectRow().exists()).toBe(true);
      expect(wrapper.findByTestId('project-link').attributes('href')).toBe(
        mockActiveItem.project.webPath,
      );
    });

    it('does not render project link when project is not present', () => {
      createComponent({
        activeItem: {
          ...mockActiveItem,
          project: null,
        },
      });

      expect(findProjectRow().exists()).toBe(true);
      expect(wrapper.findByTestId('project-link').exists()).toBe(false);
    });
  });
});
