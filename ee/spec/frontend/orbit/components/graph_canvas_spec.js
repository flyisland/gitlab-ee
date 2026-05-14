import { shallowMount } from '@vue/test-utils';
import GraphCanvas from 'ee/orbit/components/graph_canvas.vue';

const mockGraphInstance = {
  init: jest.fn(),
  setData: jest.fn(),
  addData: jest.fn(),
  dispose: jest.fn(),
  selectNode: jest.fn(),
  deselectNode: jest.fn(),
  setViewMode: jest.fn(),
  resize: jest.fn(),
  onNodeHover: jest.fn(),
  onNodeSelect: jest.fn(),
  onNodeExpand: jest.fn(),
  nodes: [],
};

jest.mock('ee/orbit/utils/three_graph', () => {
  return jest.fn().mockImplementation(() => mockGraphInstance);
});

describe('GraphCanvas', () => {
  let wrapper;

  const mockNodes = [
    { id: 'User_1', label: 'Admin', type: 'user' },
    { id: 'User_2', label: 'Dev', type: 'user' },
  ];

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(GraphCanvas, {
      propsData: {
        nodes: mockNodes,
        edges: [],
        ...props,
      },
      attachTo: document.body,
    });
  };

  describe('rendering', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders canvas container', () => {
      expect(wrapper.find('[data-testid="graph-canvas"]').exists()).toBe(true);
    });
  });

  describe('initialization', () => {
    it('initializes ThreeGraph on mount', () => {
      createWrapper();

      expect(mockGraphInstance.init).toHaveBeenCalled();
    });

    it('sets data when nodes are provided', () => {
      createWrapper();

      expect(mockGraphInstance.setData).toHaveBeenCalledWith(mockNodes, []);
    });
  });
});
