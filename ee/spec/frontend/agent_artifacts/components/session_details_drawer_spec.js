import { GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SessionDetailsDrawer from 'ee/agent_artifacts/components/session_details_drawer.vue';
import SessionDetailsBody from 'ee/agent_artifacts/components/session_details_body.vue';
import AuditEventDetailsPanel from 'ee/agent_artifacts/components/audit_event_details_panel.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';

jest.mock('ee/ai/duo_agents_platform/utils', () => ({
  formatAgentDefinition: jest.fn((name) => name),
}));

describe('SessionDetailsDrawer', () => {
  let wrapper;

  const mockActiveItem = {
    id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1908',
    workflowDefinition: 'false_positive_detection/v1',
    workflowCreatedAt: '2024-01-01T12:00:00Z',
    webPath: '/gitlab-org/security-scanner/-/automate/agent-sessions/1908',
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
        SessionDetailsBody,
        SessionAuditEventsList: true,
        CrudComponent,
        GlButton,
      },
    });
  };

  const findDrawer = () => wrapper.findByTestId('session-details-drawer');
  const findDrawerTitle = () => wrapper.findByTestId('drawer-title');
  const findCloseButton = () => wrapper.findByTestId('session-details-drawer-close-button');
  const findDrawerContentTitle = () => wrapper.findByTestId('session-content-title');
  const findCrudComponent = () => wrapper.findComponent(CrudComponent);
  const findViewFullSessionButton = () => wrapper.findByTestId('view-full-session-details-button');
  const findSessionRow = () => wrapper.findByTestId('session-row');
  const findDateRow = () => wrapper.findByTestId('date-row');
  const findProjectRow = () => wrapper.findByTestId('project-row');
  const findSessionDetailsBody = () => wrapper.findComponent(SessionDetailsBody);

  beforeEach(() => {
    createComponent();
  });

  it('renders the drawer', () => {
    expect(findDrawer().exists()).toBe(true);
  });

  it('displays formatted agent name in title', () => {
    expect(findDrawerTitle().text()).toBe(formatAgentDefinition(mockActiveItem.workflowDefinition));
  });

  it('displays formatted agent name in content', () => {
    expect(findDrawerContentTitle().text()).toBe(
      formatAgentDefinition(mockActiveItem.workflowDefinition),
    );
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

  describe('session details body', () => {
    it('renders the SessionDetailsBody and passes through the session id', () => {
      expect(findSessionDetailsBody().exists()).toBe(true);
      expect(findSessionDetailsBody().props('sessionId')).toBe(mockActiveItem.id);
    });

    it('passes a null session id through when the active item has none', () => {
      createComponent({
        activeItem: { ...mockActiveItem, id: null },
      });

      expect(findSessionDetailsBody().props('sessionId')).toBe(null);
    });

    it('forwards the body select event as its own select', () => {
      findSessionDetailsBody().vm.$emit('select', { id: 'event-1' });

      expect(wrapper.emitted('select')).toEqual([[{ id: 'event-1' }]]);
    });
  });

  describe('when an audit event is selected', () => {
    const mockEvent = { eventName: 'ai_agent_session_ended', details: {} };

    const findMaximizeButton = () => wrapper.findByTestId('audit-event-maximize-button');
    const findAuditEventPanel = () => wrapper.findComponent(AuditEventDetailsPanel);

    beforeEach(() => {
      createComponent({ selectedEvent: mockEvent, sessionName: 'Software development' });
    });

    it('renders the audit event details panel instead of the session body', () => {
      expect(findAuditEventPanel().exists()).toBe(true);
      expect(findSessionDetailsBody().exists()).toBe(false);
    });

    it('does not render the chrome title heading while viewing an event', () => {
      expect(findDrawerTitle().exists()).toBe(false);
    });

    it('renders a maximize button that emits maximize', async () => {
      expect(findMaximizeButton().exists()).toBe(true);

      await findMaximizeButton().trigger('click');

      expect(wrapper.emitted('maximize')).toHaveLength(1);
    });

    it('keeps a single close button in the chrome that emits close', async () => {
      await findCloseButton().trigger('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });

  describe('session details section', () => {
    it('renders CrudComponent', () => {
      expect(findCrudComponent().exists()).toBe(true);
    });

    it('renders view full session details button in actions slot', () => {
      expect(findViewFullSessionButton().exists()).toBe(true);
      expect(findViewFullSessionButton().text()).toBe('View full session details');
      expect(findViewFullSessionButton().attributes('href')).toBe(mockActiveItem.webPath);
    });

    it('renders session row with session link', () => {
      expect(findSessionRow().exists()).toBe(true);
      expect(wrapper.findByTestId('session-link').attributes('href')).toBe(mockActiveItem.webPath);
      expect(wrapper.findByTestId('session-link').text()).toBe('#1908');
    });

    it('renders date row with formatted date', () => {
      expect(findDateRow().exists()).toBe(true);
      expect(wrapper.findByTestId('formatted-date').text()).toBe('2024-01-01 12:00:00 UTC');
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
