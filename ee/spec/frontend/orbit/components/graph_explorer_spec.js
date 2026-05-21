import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import GraphExplorer from 'ee/orbit/components/graph_explorer.vue';
import GraphCanvas from 'ee/orbit/components/graph_canvas.vue';
import GraphFilterBar from 'ee/orbit/components/graph_filter_bar.vue';
import GraphLegend from 'ee/orbit/components/graph_legend.vue';
import ExplorerNodeSidebar from 'ee/orbit/components/explorer_node_sidebar.vue';
import ExplorerQueryPanel from 'ee/orbit/components/explorer_query_panel.vue';
import ExplorerTablePanel from 'ee/orbit/components/explorer_table_panel.vue';
import * as orbitApi from 'ee/orbit/api/orbit_api';
import { mockQueryResponse, mockNeighborResponse } from '../mock_data';

jest.mock('~/alert');
jest.mock('ee/orbit/api/orbit_api');

describe('GraphExplorer', () => {
  let wrapper;

  const mockGroupNode = {
    id: 'Group_1',
    label: 'frontend',
    type: 'group',
    properties: { id: 1, full_path: 'gitlab-org/frontend' },
  };

  const GraphCanvasStub = {
    name: 'GraphCanvas',
    props: ['nodes', 'edges', 'selectedNodeId', 'nodeStyleMap', 'darkMode', 'mapMode'],
    template: '<div data-testid="graph-canvas-stub"></div>',
    methods: {
      setFullData: jest.fn(),
      addData: jest.fn(),
      highlightByTypes: jest.fn(),
      zoomIn: jest.fn(),
      zoomOut: jest.fn(),
    },
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(GraphExplorer, {
      propsData: {
        initialNodes: [mockGroupNode],
        initialEdges: [],
        ...props,
      },
      stubs: { GraphCanvas: GraphCanvasStub },
    });
  };

  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
    orbitApi.executeOrbitQuery.mockResolvedValue({ data: { result: { nodes: [], edges: [] } } });
  });

  describe('rendering', () => {
    it('renders the explorer container', () => {
      createWrapper();

      expect(wrapper.find('[data-testid="graph-explorer"]').exists()).toBe(true);
    });

    it('renders the graph canvas in map view', () => {
      createWrapper({ view: 'map' });

      expect(wrapper.findComponent(GraphCanvas).exists()).toBe(true);
      expect(wrapper.findComponent(ExplorerTablePanel).exists()).toBe(false);
    });

    it('renders the table panel in table view', () => {
      createWrapper({ view: 'table' });

      expect(wrapper.findComponent(ExplorerTablePanel).exists()).toBe(true);
      expect(wrapper.findComponent(GraphCanvas).exists()).toBe(false);
    });

    it('renders the query panel only when advancedOpen is true', () => {
      createWrapper({ advancedOpen: false });
      expect(wrapper.findComponent(ExplorerQueryPanel).exists()).toBe(false);

      createWrapper({ advancedOpen: true });
      expect(wrapper.findComponent(ExplorerQueryPanel).exists()).toBe(true);
    });

    it('renders the filter bar with the legend items derived from nodes', async () => {
      createWrapper({ initialNodes: [mockGroupNode] });
      await nextTick();

      const filterBar = wrapper.findComponent(GraphFilterBar);
      expect(filterBar.exists()).toBe(true);
      expect(filterBar.props('legendItems')).toEqual(
        expect.arrayContaining([expect.objectContaining({ type: 'group' })]),
      );
    });

    it('renders graph controls above the legend panel', () => {
      createWrapper();

      expect(wrapper.find('[data-testid="graph-controls"]').classes()).toContain('gl-z-4');
      expect(wrapper.find('[data-testid="graph-legend-panel"]').classes()).toContain('gl-z-3');
    });
  });

  describe('initial neighbor expansion', () => {
    it('fetches neighbors of the initial group nodes on mount', async () => {
      createWrapper();
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(
        expect.objectContaining({
          query_type: 'neighbors',
          node: expect.objectContaining({ entity: 'Group', node_ids: [1] }),
          limit: 500,
        }),
      );
    });

    it('fetches neighbors when initial group nodes arrive after mount', async () => {
      createWrapper({ initialNodes: [] });
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).not.toHaveBeenCalled();

      await wrapper.setProps({ initialNodes: [mockGroupNode] });
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(
        expect.objectContaining({
          query_type: 'neighbors',
          node: expect.objectContaining({ entity: 'Group', node_ids: [1] }),
          limit: 500,
        }),
      );
    });

    it('skips initial expansion when an instance map request is supplied', async () => {
      createWrapper({
        instanceMapRequest: { entityType: 'Project', filters: { name: 'foo' } },
      });
      await waitForPromises();

      // The instance-map query goes through executeOrbitQuery as a traversal
      // (single-node, no relationships), not a neighbors query.
      const { calls } = orbitApi.executeOrbitQuery.mock;
      expect(calls.some((c) => c[0].query_type === 'neighbors')).toBe(false);
      expect(calls.some((c) => c[0].query_type === 'traversal')).toBe(true);
    });

    it('alerts when the neighbor fetch fails', async () => {
      orbitApi.executeOrbitQuery.mockRejectedValueOnce(new Error('boom'));
      createWrapper();
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith({ message: 'boom' });
    });
  });

  describe('executing a custom query', () => {
    it('forwards the parsed query to the API and stores the response', async () => {
      orbitApi.executeOrbitQuery.mockResolvedValueOnce(mockQueryResponse);
      createWrapper({ initialNodes: [], advancedOpen: true, view: 'table' });

      const query = {
        query_type: 'traversal',
        node: { id: 'n', entity: 'User', columns: '*' },
      };
      const queryPanel = wrapper.findComponent(ExplorerQueryPanel);
      queryPanel.vm.$emit('update:query-text', JSON.stringify(query));
      queryPanel.vm.$emit('execute');
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(query);
      expect(wrapper.findComponent(ExplorerTablePanel).props('queryResponse')).toEqual(
        mockQueryResponse.data.result,
      );
    });

    it('alerts on invalid JSON', async () => {
      createWrapper({ initialNodes: [], advancedOpen: true });

      const queryPanel = wrapper.findComponent(ExplorerQueryPanel);
      queryPanel.vm.$emit('update:query-text', '{ invalid');
      queryPanel.vm.$emit('execute');
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith({
        message: expect.stringContaining('Invalid JSON'),
      });
    });

    it('passes the chosen template back to the query panel as selectedTemplate', async () => {
      createWrapper({ initialNodes: [], advancedOpen: true });

      const queryPanel = wrapper.findComponent(ExplorerQueryPanel);
      const [firstTemplate] = queryPanel.props('templateItems');
      queryPanel.vm.$emit('template-select', firstTemplate.value);
      await nextTick();

      expect(wrapper.findComponent(ExplorerQueryPanel).props('selectedTemplate')).toBe(
        firstTemplate.value,
      );
    });

    it('clears selectedTemplate when the panel emits clear', async () => {
      createWrapper({ initialNodes: [], advancedOpen: true });

      const queryPanel = wrapper.findComponent(ExplorerQueryPanel);
      const [firstTemplate] = queryPanel.props('templateItems');
      queryPanel.vm.$emit('template-select', firstTemplate.value);
      await nextTick();

      queryPanel.vm.$emit('clear');
      await nextTick();

      expect(wrapper.findComponent(ExplorerQueryPanel).props('selectedTemplate')).toBeNull();
    });
  });

  describe('node interaction', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('records the selected node and shows the sidebar', async () => {
      const canvas = wrapper.findComponent(GraphCanvas);
      canvas.vm.$emit('node-select', { id: 'Group_1', label: 'frontend', type: 'group' });
      await nextTick();

      expect(wrapper.findComponent(ExplorerNodeSidebar).exists()).toBe(true);
    });

    it('hides the sidebar when the selection is cleared', async () => {
      const canvas = wrapper.findComponent(GraphCanvas);
      canvas.vm.$emit('node-select', { id: 'Group_1' });
      await nextTick();

      wrapper.findComponent(ExplorerNodeSidebar).vm.$emit('close');
      await nextTick();

      expect(wrapper.findComponent(ExplorerNodeSidebar).exists()).toBe(false);
    });

    it('expands a node by fetching its neighbors with the per-node limit', async () => {
      // Wait for the mount-time auto-expand to complete first so we can
      // observe the per-node expansion in isolation.
      await waitForPromises();
      orbitApi.executeOrbitQuery.mockClear();
      orbitApi.executeOrbitQuery.mockResolvedValue(mockNeighborResponse);

      const canvas = wrapper.findComponent(GraphCanvas);
      canvas.vm.$emit('node-expand', {
        id: 'Project_2',
        type: 'project',
        properties: { id: 2 },
      });
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(
        expect.objectContaining({
          query_type: 'neighbors',
          limit: 50,
          node: expect.objectContaining({ node_ids: [2] }),
        }),
      );
    });

    it('does not re-expand a node that was already expanded', async () => {
      await waitForPromises();
      orbitApi.executeOrbitQuery.mockClear();
      orbitApi.executeOrbitQuery.mockResolvedValue(mockNeighborResponse);

      const canvas = wrapper.findComponent(GraphCanvas);
      const node = { id: 'Project_2', type: 'project', properties: { id: 2 } };

      canvas.vm.$emit('node-expand', node);
      await waitForPromises();
      const firstCallCount = orbitApi.executeOrbitQuery.mock.calls.length;

      canvas.vm.$emit('node-expand', node);
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledTimes(firstCallCount);
    });
  });

  describe('legend interactions', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('soloes a type when the legend emits select-type', async () => {
      const legend = wrapper.findComponent(GraphLegend);
      legend.vm.$emit('select-type', 'group');
      await nextTick();

      expect(Array.from(wrapper.findComponent(GraphLegend).props('activeTypeFilters'))).toEqual([
        'group',
      ]);
    });

    it('clears the highlight when the same type is selected twice', async () => {
      const legend = wrapper.findComponent(GraphLegend);
      legend.vm.$emit('select-type', 'group');
      await nextTick();
      legend.vm.$emit('select-type', 'group');
      await nextTick();

      expect(Array.from(wrapper.findComponent(GraphLegend).props('activeTypeFilters'))).toEqual([]);
    });
  });

  describe('row clicks from the table view', () => {
    beforeEach(async () => {
      // Skip auto-expand by starting with no initial nodes, so the only API
      // call we observe is the explicit query below.
      orbitApi.executeOrbitQuery.mockResolvedValue(mockQueryResponse);
      createWrapper({ view: 'table', advancedOpen: true, initialNodes: [] });
      const queryPanel = wrapper.findComponent(ExplorerQueryPanel);
      queryPanel.vm.$emit(
        'update:query-text',
        JSON.stringify({
          query_type: 'traversal',
          node: { id: 'n', entity: 'User' },
        }),
      );
      queryPanel.vm.$emit('execute');
      await waitForPromises();
    });

    it('selects the matching graph node when a row is clicked', async () => {
      const tablePanel = wrapper.findComponent(ExplorerTablePanel);
      tablePanel.vm.$emit('row-click', { type: 'User', id: 1 });
      await nextTick();
      await wrapper.setProps({ view: 'map' });

      const sidebar = wrapper.findComponent(ExplorerNodeSidebar);
      expect(sidebar.exists()).toBe(true);
      expect(sidebar.props('node')).toEqual(expect.objectContaining({ id: 'User_1' }));
    });

    it('alerts when the row has no matching graph node', async () => {
      const tablePanel = wrapper.findComponent(ExplorerTablePanel);
      tablePanel.vm.$emit('row-click', { type: 'User', id: 9999 });
      await nextTick();

      expect(createAlert).toHaveBeenCalledWith({
        message: expect.stringContaining('Could not locate'),
      });
    });
  });

  describe('search and clear', () => {
    beforeEach(async () => {
      createWrapper({ activeTypeFilters: new Set(['project']) });
      await waitForPromises();
      orbitApi.executeOrbitQuery.mockClear();
    });

    it('issues a traversal query when the filter bar emits search-graph', async () => {
      const filterBar = wrapper.findComponent(GraphFilterBar);
      filterBar.vm.$emit('search-graph', { text: 'foo', field: 'name' });
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(
        expect.objectContaining({
          query_type: 'traversal',
          node: expect.objectContaining({
            entity: 'Project',
            filters: expect.objectContaining({
              name: { op: 'contains', value: 'foo' },
            }),
          }),
        }),
      );
    });

    it('restores the initial graph when clear-filters is emitted', async () => {
      const filterBar = wrapper.findComponent(GraphFilterBar);
      const canvas = wrapper.findComponent(GraphCanvas);

      filterBar.vm.$emit('update-search-query', 'foo');
      canvas.vm.$emit('node-select', { id: 'Group_1', label: 'frontend', type: 'group' });
      await nextTick();

      expect(wrapper.findComponent(ExplorerNodeSidebar).exists()).toBe(true);

      filterBar.vm.$emit('clear-filters');
      await nextTick();

      expect(wrapper.findComponent(GraphCanvas).props('nodes')).toEqual([mockGroupNode]);
      expect(wrapper.findComponent(ExplorerNodeSidebar).exists()).toBe(false);
      expect(wrapper.findComponent(GraphFilterBar).props('searchQuery')).toBe('');
    });
  });

  describe('zoom controls', () => {
    it('proxies zoom controls to the canvas', async () => {
      createWrapper();
      const canvas = wrapper.findComponent(GraphCanvas);
      canvas.vm.zoomIn = jest.fn();
      canvas.vm.zoomOut = jest.fn();

      wrapper.find('[data-testid="zoom-in"]').vm.$emit('click');
      wrapper.find('[data-testid="zoom-out"]').vm.$emit('click');
      await nextTick();

      expect(canvas.vm.zoomIn).toHaveBeenCalled();
      expect(canvas.vm.zoomOut).toHaveBeenCalled();
    });
  });
});
