import { shallowMount } from '@vue/test-utils';
import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import GraphExplorer from 'ee/orbit/components/graph_explorer.vue';
import NodeDetailOverlay from 'ee/orbit/components/node_detail_overlay.vue';
import ExplorerHeroBanner from 'ee/orbit/components/explorer_hero_banner.vue';
import ExplorerQueryPanel from 'ee/orbit/components/explorer_query_panel.vue';
import ExplorerNodeSidebar from 'ee/orbit/components/explorer_node_sidebar.vue';
import ExplorerTabBar from 'ee/orbit/components/explorer_tab_bar.vue';
import ExplorerTablePanel from 'ee/orbit/components/explorer_table_panel.vue';
import ExplorerGraphToolbar from 'ee/orbit/components/explorer_graph_toolbar.vue';
import ownedNamespacesQuery from 'ee/orbit/graphql/queries/owned_namespaces.query.graphql';
import * as orbitApi from 'ee/orbit/api/orbit_api';
import { TAB_GRAPH, TAB_TABLE } from 'ee/orbit/constants';
import { mockNamespacesResponse, mockQueryResponse, mockNeighborResponse } from '../mock_data';

Vue.use(VueApollo);

jest.mock('~/alert');
jest.mock('ee/orbit/api/orbit_api');

describe('GraphExplorer', () => {
  let wrapper;
  let namespacesHandler;

  const GraphCanvasStub = {
    name: 'GraphCanvas',
    template: '<div></div>',
    methods: {
      setFullData: jest.fn(),
      addData: jest.fn(),
    },
  };

  const createWrapper = ({ namespacesResponse = mockNamespacesResponse } = {}) => {
    namespacesHandler = jest.fn().mockResolvedValue(namespacesResponse);

    wrapper = shallowMount(GraphExplorer, {
      apolloProvider: createMockApollo([[ownedNamespacesQuery, namespacesHandler]]),
      stubs: { GraphCanvas: GraphCanvasStub },
    });
  };

  const findTabBar = () => wrapper.findComponent(ExplorerTabBar);
  const findQueryPanel = () => wrapper.findComponent(ExplorerQueryPanel);
  const findGraphToolbar = () => wrapper.findComponent(ExplorerGraphToolbar);
  const findTablePanel = () => wrapper.findComponent(ExplorerTablePanel);

  describe('initial group loading', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('loads user top-level groups on mount', async () => {
      await waitForPromises();

      expect(namespacesHandler).toHaveBeenCalledWith(expect.objectContaining({ first: 25 }));
    });

    it('renders groups as initial graph nodes', async () => {
      await waitForPromises();

      expect(wrapper.vm.nodes).toHaveLength(2);
      expect(wrapper.vm.nodes[0].label).toBe('Frontend');
      expect(wrapper.vm.nodes[0].type).toBe('group');
      expect(wrapper.vm.nodes[0].id).toBe('Group_1');
      expect(wrapper.vm.nodes[0].properties.id).toBe(1);
      expect(wrapper.vm.nodes[1].label).toBe('Backend');
    });

    it('sets initialLoading to false after groups load', async () => {
      expect(wrapper.vm.initialLoading).toBe(true);

      await waitForPromises();

      expect(wrapper.vm.initialLoading).toBe(false);
    });
  });

  describe('with empty groups', () => {
    beforeEach(async () => {
      createWrapper({
        namespacesResponse: { data: { groups: { nodes: [], pageInfo: {} } } },
      });
      await waitForPromises();
    });

    it('handles empty groups gracefully', () => {
      expect(wrapper.vm.nodes).toHaveLength(0);
      expect(wrapper.vm.initialLoading).toBe(false);
    });
  });

  describe('with group fetch failure', () => {
    beforeEach(async () => {
      namespacesHandler = jest.fn().mockRejectedValue(new Error('fail'));

      wrapper = shallowMount(GraphExplorer, {
        apolloProvider: createMockApollo([[ownedNamespacesQuery, namespacesHandler]]),
        stubs: { GraphCanvas: GraphCanvasStub },
      });
      await waitForPromises();
    });

    it('shows error alert and sets initialLoading to false', () => {
      expect(createAlert).toHaveBeenCalledWith(expect.objectContaining({ message: 'fail' }));
      expect(wrapper.vm.initialLoading).toBe(false);
      expect(wrapper.vm.nodes).toHaveLength(0);
    });
  });

  describe('hero section', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders hero banner component', () => {
      const banner = wrapper.findComponent(ExplorerHeroBanner);

      expect(banner.exists()).toBe(true);
      expect(banner.props('logoSrc')).toBeDefined();
    });
  });

  describe('tab bar', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders tab bar', () => {
      expect(findTabBar().exists()).toBe(true);
    });

    it('defaults to graph tab', () => {
      expect(findTabBar().props('activeTab')).toBe(TAB_GRAPH);
    });
  });

  describe('query editor', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders query panel with default template', () => {
      const panel = findQueryPanel();

      expect(panel.exists()).toBe(true);
      expect(panel.props('queryText')).toContain('query_type');
    });

    it('updates query text when template selected', async () => {
      const stringifySpy = jest.spyOn(JSON, 'stringify');
      findQueryPanel().vm.$emit('template-select', 'user_authored_mrs');
      await nextTick();

      expect(stringifySpy).toHaveBeenCalledWith(
        expect.objectContaining({ query_type: 'traversal' }),
        null,
        2,
      );
      stringifySpy.mockRestore();
    });

    it('clears query text on clear event', async () => {
      const stringifySpy = jest.spyOn(JSON, 'stringify');
      findQueryPanel().vm.$emit('clear');
      await nextTick();

      expect(stringifySpy).toHaveBeenCalledWith({}, null, 2);
      stringifySpy.mockRestore();
    });
  });

  describe('execute query', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('calls executeOrbitQuery with parsed JSON', async () => {
      orbitApi.executeOrbitQuery.mockResolvedValue(mockQueryResponse);

      wrapper.vm.executeCurrentQuery();
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalled();
    });

    it('shows error alert on invalid JSON', async () => {
      wrapper.vm.queryText = '{ invalid json';

      wrapper.vm.executeCurrentQuery();
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Invalid JSON') }),
      );
    });

    it('shows error alert on API failure', async () => {
      orbitApi.executeOrbitQuery.mockRejectedValue(new Error('Server error'));

      wrapper.vm.executeCurrentQuery();
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: 'Server error' }),
      );
    });

    it('transforms results into nodes and edges', async () => {
      orbitApi.executeOrbitQuery.mockResolvedValue(mockQueryResponse);
      await waitForPromises();

      wrapper.vm.executeCurrentQuery();
      await waitForPromises();

      expect(wrapper.vm.nodes).toHaveLength(2);
      expect(wrapper.vm.nodes[0].id).toBe('User_1');
      expect(wrapper.vm.nodes[1].id).toBe('User_2');
    });
  });

  describe('node interaction', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('sets selectedNode on node select', () => {
      const node = wrapper.vm.nodes[0];
      wrapper.vm.onNodeSelect(node);

      expect(wrapper.vm.selectedNode).toEqual(node);
    });

    it('clears selectedNode on closeSidebar', () => {
      wrapper.vm.onNodeSelect(wrapper.vm.nodes[0]);
      wrapper.vm.closeSidebar();

      expect(wrapper.vm.selectedNode).toBeNull();
    });

    it('shows sidebar when a node is selected', async () => {
      wrapper.vm.onNodeSelect(wrapper.vm.nodes[0]);
      await nextTick();

      const sidebar = wrapper.findComponent(ExplorerNodeSidebar);

      expect(sidebar.exists()).toBe(true);
      expect(sidebar.props('node')).toEqual(wrapper.vm.nodes[0]);
    });

    it('sets hoveredNode on node-hover', () => {
      const mockNode = { id: '1', label: 'Test' };
      const mockPosition = { x: 100, y: 200 };

      wrapper.vm.onNodeHover(mockNode, mockPosition);

      expect(wrapper.vm.hoveredNode).toEqual(mockNode);
      expect(wrapper.vm.hoveredPosition).toEqual(mockPosition);
    });

    it('renders node detail overlay', () => {
      expect(wrapper.findComponent(NodeDetailOverlay).exists()).toBe(true);
    });
  });

  describe('node expansion', () => {
    beforeEach(async () => {
      createWrapper();
      await waitForPromises();
    });

    it('triggers neighbor expansion', async () => {
      orbitApi.executeOrbitQuery.mockResolvedValue(mockNeighborResponse);

      wrapper.vm.onNodeExpand(wrapper.vm.nodes[0]);
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).toHaveBeenCalledWith(
        expect.objectContaining({
          query_type: 'neighbors',
          node: expect.objectContaining({ id: 'center', entity: 'Group', node_ids: [1] }),
          neighbors: expect.objectContaining({ node: 'center', direction: 'both' }),
        }),
      );
    });

    it('does not expand the same node twice', async () => {
      orbitApi.executeOrbitQuery.mockResolvedValue(mockNeighborResponse);

      wrapper.vm.onNodeExpand(wrapper.vm.nodes[0]);
      await waitForPromises();

      orbitApi.executeOrbitQuery.mockClear();
      wrapper.vm.onNodeExpand(wrapper.vm.nodes[0]);
      await waitForPromises();

      expect(orbitApi.executeOrbitQuery).not.toHaveBeenCalled();
    });

    it('shows error alert on expand failure', async () => {
      orbitApi.executeOrbitQuery.mockRejectedValue(new Error('expand failed'));

      wrapper.vm.onNodeExpand(wrapper.vm.nodes[0]);
      await waitForPromises();

      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: 'expand failed' }),
      );
    });
  });

  describe('graph toolbar', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders graph toolbar on graph tab', () => {
      expect(findGraphToolbar().exists()).toBe(true);
    });
  });

  describe('table view', () => {
    beforeEach(async () => {
      createWrapper();
      wrapper.vm.activeTab = TAB_TABLE;
      await nextTick();
    });

    it('shows table panel on table tab', () => {
      expect(findTablePanel().exists()).toBe(true);
    });

    it('hides graph toolbar on table tab', () => {
      expect(findGraphToolbar().exists()).toBe(false);
    });
  });
});
