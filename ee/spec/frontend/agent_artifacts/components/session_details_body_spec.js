import { GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import SessionDetailsBody from 'ee/agent_artifacts/components/session_details_body.vue';
import SessionAuditEventsList from 'ee/agent_artifacts/components/session_audit_events_list.vue';
import CrudComponent from '~/vue_shared/components/crud_component.vue';
import { formatAgentDefinition } from 'ee/ai/duo_agents_platform/utils';

jest.mock('ee/ai/duo_agents_platform/utils', () => ({
  formatAgentDefinition: jest.fn((name) => name),
}));

describe('SessionDetailsBody', () => {
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
    wrapper = shallowMountExtended(SessionDetailsBody, {
      propsData: {
        activeItem: mockActiveItem,
        sessionId: mockActiveItem.id,
        ...props,
      },
      stubs: {
        CrudComponent,
        GlButton,
        SessionAuditEventsList: true,
      },
    });
  };

  const findTitle = () => wrapper.findByTestId('session-content-title');
  const findProjectLink = () => wrapper.findByTestId('project-link');
  const findAuditEventsList = () => wrapper.findComponent(SessionAuditEventsList);

  beforeEach(() => {
    createComponent();
  });

  it('renders the formatted session title', () => {
    expect(findTitle().text()).toBe(formatAgentDefinition(mockActiveItem.workflowDefinition));
  });

  it('renders the project link from the active item', () => {
    expect(findProjectLink().exists()).toBe(true);
    expect(findProjectLink().attributes('href')).toBe(mockActiveItem.project.webPath);
  });

  describe('audit events list', () => {
    it('renders the list with the session id when present', () => {
      expect(findAuditEventsList().exists()).toBe(true);
      expect(findAuditEventsList().props('sessionId')).toBe(mockActiveItem.id);
    });

    it('does not render the list when there is no session id', () => {
      createComponent({ sessionId: null });

      expect(findAuditEventsList().exists()).toBe(false);
    });

    it('re-emits select when the list emits select', () => {
      const event = { id: 'event-1' };

      findAuditEventsList().vm.$emit('select', event);

      expect(wrapper.emitted('select')).toEqual([[event]]);
    });
  });
});
