import { GlBreadcrumb } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AuditEventDetailsPanel from 'ee/agent_artifacts/components/audit_event_details_panel.vue';
import SummarySection from 'ee/agent_artifacts/components/summary_section.vue';
import DetailsSection from 'ee/agent_artifacts/components/details_section.vue';

describe('AuditEventDetailsPanel', () => {
  let wrapper;

  const mockEvent = {
    eventName: 'tool_execution',
    workflowId: '1908',
    details: { input_prompt: 'hello' },
  };

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(AuditEventDetailsPanel, {
      propsData: {
        event: mockEvent,
        sessionName: 'false_positive_detection/v1',
        workflowDefinition: 'false_positive_detection/v1',
        ...props,
      },
    });
  };

  const findPanel = () => wrapper.findByTestId('audit-event-details-panel');
  const findTitle = () => wrapper.findByTestId('audit-event-title');
  const findCloseButton = () => wrapper.findByTestId('audit-event-close-button');
  const findMaximizeButton = () => wrapper.findByTestId('audit-event-maximize-button');
  const findBackButton = () => wrapper.findByTestId('audit-event-back-button');
  const findBreadcrumb = () => wrapper.findComponent(GlBreadcrumb);
  const findSummarySection = () => wrapper.findComponent(SummarySection);
  const findDetailsSection = () => wrapper.findComponent(DetailsSection);

  beforeEach(() => {
    createComponent();
  });

  it('renders the panel', () => {
    expect(findPanel().exists()).toBe(true);
  });

  it('renders the formatted event name as the title', () => {
    expect(findTitle().text()).toBe('Tool execution');
  });

  it('renders the breadcrumb with three items', () => {
    const items = findBreadcrumb().props('items');

    expect(items).toHaveLength(3);
    expect(items[0].text).toBe('Agent audit events');
    expect(items[1].text).toBe('false_positive_detection/v1');
    expect(items[2].text).toBe('Tool execution');
  });

  it('omits the session crumb when the session name is blank', () => {
    createComponent({ sessionName: '' });

    const items = findBreadcrumb().props('items');

    expect(items).toHaveLength(2);
    expect(items.map((item) => item.text)).toEqual(['Agent audit events', 'Tool execution']);
  });

  it('renders the SummarySection with the event', () => {
    expect(findSummarySection().exists()).toBe(true);
    expect(findSummarySection().props('event')).toEqual(mockEvent);
  });

  it('passes the constant target type to the summary section', () => {
    expect(findSummarySection().props('targetType')).toBe('Ai::DuoWorkflows::Workflow');
  });

  it('reconstructs the target details from the raw workflow definition and id', () => {
    expect(findSummarySection().props('targetDetails')).toBe(
      'false_positive_detection/v1 session 1908',
    );
  });

  it('leaves the target details blank when the workflow definition is missing', () => {
    createComponent({ workflowDefinition: '' });

    expect(findSummarySection().props('targetDetails')).toBe('');
  });

  it('renders the DetailsSection with the event details', () => {
    expect(findDetailsSection().exists()).toBe(true);
    expect(findDetailsSection().props('details')).toEqual(mockEvent.details);
  });

  describe('in drawer mode (default)', () => {
    it('emits back when the back button is clicked', () => {
      findBackButton().vm.$emit('click');

      expect(wrapper.emitted('back')).toHaveLength(1);
    });

    it('does not render close or maximize (owned by the drawer chrome)', () => {
      expect(findCloseButton().exists()).toBe(false);
      expect(findMaximizeButton().exists()).toBe(false);
    });
  });

  describe('when isFullPage is true', () => {
    beforeEach(() => {
      createComponent({ isFullPage: true });
    });

    it('does not render the back button', () => {
      expect(findBackButton().exists()).toBe(false);
    });

    it('does not render a maximize button', () => {
      expect(findMaximizeButton().exists()).toBe(false);
    });

    it('renders the close button and emits close when clicked', () => {
      expect(findCloseButton().exists()).toBe(true);

      findCloseButton().vm.$emit('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });
});
