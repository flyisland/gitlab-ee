import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import AgentArtifactsApp from 'ee/agent_artifacts/components/agent_artifacts_app.vue';
import AgentArtifactsTable from 'ee/agent_artifacts/components/agent_artifacts_table.vue';
import AgentArtifactsFilteredSearch from 'ee/agent_artifacts/components/agent_artifacts_filtered_search.vue';
import SessionDetailsDrawer from 'ee/agent_artifacts/components/session_details_drawer.vue';

describe('AgentArtifactsApp', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMountExtended(AgentArtifactsApp);
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
      const mockItem = { id: '1', name: 'test-agent' };

      await wrapper.findComponent(AgentArtifactsTable).vm.$emit('row-click', mockItem);

      expect(wrapper.findComponent(SessionDetailsDrawer).exists()).toBe(true);
      expect(wrapper.findComponent(SessionDetailsDrawer).props('activeItem')).toEqual(mockItem);
    });

    it('closes drawer when close event is emitted', async () => {
      const mockItem = { id: '1', name: 'test-agent' };

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
});
