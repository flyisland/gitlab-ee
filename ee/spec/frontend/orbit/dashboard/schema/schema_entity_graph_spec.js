import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { createMockDirective } from 'helpers/vue_mock_directive';
import SchemaEntityGraph from 'ee/orbit/dashboard/schema/schema_entity_graph.vue';

const neighbor = (name, ...edges) => ({
  name,
  icon: null,
  color: '#000000',
  edges: edges.map((edge) => ({ name: edge })),
});

describe('SchemaEntityGraph', () => {
  let wrapper;

  const createComponent = (neighbors) => {
    wrapper = shallowMountExtended(SchemaEntityGraph, {
      propsData: { entity: { name: 'MergeRequest', icon: null, color: '#ff9900' }, neighbors },
      directives: { GlTooltip: createMockDirective('gl-tooltip') },
    });
  };

  const findEdgeLabels = () => wrapper.findAllByTestId('schema-edge-label');
  const findNeighbors = () => wrapper.findAllByTestId('schema-neighbor');

  describe('with a few neighbors', () => {
    beforeEach(() => {
      createComponent([
        neighbor('User', 'AUTHORED', 'MERGED', 'CLOSED'),
        neighbor('Label', 'HAS_LABEL'),
      ]);
    });

    it('labels each edge with its first relationship and how many more there are', () => {
      expect(findEdgeLabels().wrappers.map((label) => label.text())).toEqual([
        'AUTHORED +2 more',
        'HAS_LABEL',
      ]);
    });

    it('shows all relationship names of each neighbor in its tooltip', () => {
      expect(findNeighbors().wrappers.map((node) => node.attributes('title'))).toEqual([
        'AUTHORED, MERGED, CLOSED',
        'HAS_LABEL',
      ]);
    });

    it('says how many entities it connects to', () => {
      expect(wrapper.text()).toContain('MergeRequest connects to 2 entities.');
    });

    it('emits select with the neighbor name', async () => {
      await findNeighbors()
        .wrappers.find((node) => node.text() === 'Label')
        .trigger('click');

      expect(wrapper.emitted('select')).toEqual([['Label']]);
    });
  });

  describe('with exactly 14 neighbors', () => {
    beforeEach(() => {
      createComponent(Array.from({ length: 14 }, (_, i) => neighbor(`Entity${i}`, 'IN_PROJECT')));
    });

    it('still labels every edge', () => {
      expect(findEdgeLabels()).toHaveLength(14);
    });
  });

  describe('with more than 14 neighbors', () => {
    beforeEach(() => {
      createComponent(Array.from({ length: 15 }, (_, i) => neighbor(`Entity${i}`, 'IN_PROJECT')));
    });

    it('drops the edge labels and keeps every neighbor', () => {
      expect(findEdgeLabels()).toHaveLength(0);
      expect(findNeighbors()).toHaveLength(15);
    });
  });
});
