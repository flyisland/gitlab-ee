import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentArtifactsApp from 'ee/agent_artifacts/components/agent_artifacts_app.vue';
import AgentArtifactsTable from 'ee/agent_artifacts/components/agent_artifacts_table.vue';
import AgentArtifactsFilteredSearch from 'ee/agent_artifacts/components/agent_artifacts_filtered_search.vue';
import SessionDetailsDrawer from 'ee/agent_artifacts/components/session_details_drawer.vue';
import SessionDetailsBody from 'ee/agent_artifacts/components/session_details_body.vue';
import AuditEventDetailsPanel from 'ee/agent_artifacts/components/audit_event_details_panel.vue';

describe('AgentArtifactsApp', () => {
  let wrapper;

  const mockItem = { id: 'gid://gitlab/Ai::DuoWorkflows::Workflow/1', name: 'test-agent' };
  const mockEvent = { id: 'event-1', eventName: 'tool_execution' };

  const createComponent = () => {
    wrapper = shallowMountExtended(AgentArtifactsApp);
  };

  const findTable = () => wrapper.findComponent(AgentArtifactsTable);
  const findFilteredSearch = () => wrapper.findComponent(AgentArtifactsFilteredSearch);
  const findDrawer = () => wrapper.findComponent(SessionDetailsDrawer);
  const findBody = () => wrapper.findComponent(SessionDetailsBody);
  const findPanel = () => wrapper.findComponent(AuditEventDetailsPanel);

  const openDrawer = () => findTable().vm.$emit('row-click', mockItem);
  const maximize = async () => {
    await openDrawer();
    await findDrawer().vm.$emit('select', mockEvent);
    await findDrawer().vm.$emit('maximize');
  };

  beforeEach(() => {
    createComponent();
  });

  it('renders the agent artifacts filtered search', () => {
    expect(wrapper.findComponent(AgentArtifactsFilteredSearch).exists()).toBe(true);
  });

  it('renders the agent artifacts table', () => {
    expect(wrapper.findComponent(AgentArtifactsTable).exists()).toBe(true);
  });

  describe('SessionDetailsDrawer', () => {
    it('does not render drawer when no active item', () => {
      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(false);
    });

    it('renders drawer when row is clicked', async () => {
      await wrapper.findComponent(AgentArtifactsTable).vm.$emit('row-click', mockItem);

      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(true);
      expect(wrapper.findComponent(SessionDetailsDrawer).props('activeItem')).toEqual(mockItem);
    });

    it('closes drawer when close event is emitted', async () => {
      await wrapper.findComponent(AgentArtifactsTable).vm.$emit('row-click', mockItem);
      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(true);

      await wrapper.findComponent(SessionDetailsDrawer).vm.$emit('close');
      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(false);
    });
  });

  describe('filtering', () => {
    it('closes session details drawer when filter changes', async () => {
      await wrapper
        .findComponent(AgentArtifactsTable)
        .vm.$emit('row-click', { id: '1', name: 'test-agent' });
      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(true);

      await wrapper
        .findComponent(AgentArtifactsFilteredSearch)
        .vm.$emit('filter', { name: 'another-agent' });

      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(false);
    });
  });

  describe('event selection', () => {
    it('sets the selected event when the drawer emits select', async () => {
      await openDrawer();

      await findDrawer().vm.$emit('select', mockEvent);

      expect(findDrawer().props('selectedEvent')).toEqual(mockEvent);
    });

    it('clears the selected event when the drawer emits back', async () => {
      await openDrawer();
      await findDrawer().vm.$emit('select', mockEvent);

      await findDrawer().vm.$emit('back');

      expect(findDrawer().props('selectedEvent')).toBeNull();
    });
  });

  describe('full-page mode', () => {
    beforeEach(async () => {
      await maximize();
    });

    it('renders the SessionDetailsBody and AuditEventDetailsPanel', () => {
      expect(findBody().exists()).toBe(true);
      expect(findPanel().exists()).toBe(true);
      expect(findPanel().props('event')).toEqual(mockEvent);
      expect(findPanel().props('isFullPage')).toBe(true);
    });

    it('hides the table, filtered search and drawer', () => {
      expect(findTable().exists()).toBe(false);
      expect(findFilteredSearch().exists()).toBe(false);
      expect(findDrawer().exists()).toBe(false);
    });

    it('swaps the selected event when the full-page body emits select', async () => {
      const otherEvent = { id: 'event-2', eventName: 'other_event' };

      await findBody().vm.$emit('select', otherEvent);

      expect(findPanel().props('event')).toEqual(otherEvent);
    });

    it('returns to the table when the panel emits close', async () => {
      await findPanel().vm.$emit('close');

      expect(findBody().exists()).toBe(false);
      expect(findPanel().exists()).toBe(false);
      expect(findTable().exists()).toBe(true);
      expect(findDrawer().exists()).toBe(false);
    });
  });
});
