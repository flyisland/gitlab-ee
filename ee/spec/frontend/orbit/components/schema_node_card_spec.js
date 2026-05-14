import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import SchemaNodeCard from 'ee/orbit/components/schema_node_card.vue';

describe('SchemaNodeCard', () => {
  let wrapper;

  const defaultNode = {
    name: 'Job',
    domain: 'ci',
    description: 'A CI/CD job',
    properties: [
      { name: 'id', data_type: 'int64' },
      { name: 'name', data_type: 'string' },
    ],
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(SchemaNodeCard, {
      propsData: {
        node: defaultNode,
        collapsed: false,
        nodeColor: '#f59e0b',
        ...props,
      },
    });
  };

  const findCard = () => wrapper.find('[data-testid="schema-node-card"]');
  const findCollapseButton = () => wrapper.findComponent(GlButton);
  const findProperties = () => wrapper.findAll('.schema-prop-row');

  describe('rendering', () => {
    beforeEach(() => createWrapper());

    it('renders the card', () => {
      expect(findCard().exists()).toBe(true);
    });

    it('displays node name', () => {
      expect(wrapper.text()).toContain('Job');
    });

    it('displays node domain', () => {
      expect(wrapper.text()).toContain('ci');
    });

    it('displays description when expanded', () => {
      expect(wrapper.text()).toContain('A CI/CD job');
    });

    it('displays property count', () => {
      expect(wrapper.text()).toContain('2');
    });

    it('renders property rows', () => {
      expect(findProperties()).toHaveLength(2);
    });

    it('displays property name and data type', () => {
      const firstProp = findProperties().at(0);

      expect(firstProp.text()).toContain('id');
      expect(firstProp.text()).toContain('int64');
    });
  });

  describe('color indicator', () => {
    it('shows color dot when nodeColor is provided', () => {
      createWrapper({ nodeColor: '#f59e0b' });
      const dot = wrapper.find('.gl-rounded-full');

      expect(dot.exists()).toBe(true);
      expect(dot.attributes('style')).toContain('background');
    });

    it('hides color dot when nodeColor is null', () => {
      createWrapper({ nodeColor: null });

      expect(wrapper.find('.gl-rounded-full').exists()).toBe(false);
    });
  });

  describe('collapsed state', () => {
    it('hides properties when collapsed', () => {
      createWrapper({ collapsed: true });

      expect(findProperties()).toHaveLength(0);
      expect(wrapper.text()).not.toContain('A CI/CD job');
    });

    it('uses chevron-right icon when collapsed', () => {
      createWrapper({ collapsed: true });

      expect(findCollapseButton().props('icon')).toBe('chevron-right');
    });

    it('uses chevron-down icon when expanded', () => {
      createWrapper({ collapsed: false });

      expect(findCollapseButton().props('icon')).toBe('chevron-down');
    });
  });

  describe('events', () => {
    it('emits toggle-collapse with node name on header click', () => {
      createWrapper();
      wrapper.find('.gl-cursor-pointer').trigger('click');

      expect(wrapper.emitted('toggle-collapse')).toEqual([['Job']]);
    });

    it('emits toggle-collapse on button click', async () => {
      createWrapper();
      await findCollapseButton().trigger('click');

      expect(wrapper.emitted('toggle-collapse')).toBeDefined();
    });
  });

  describe('edge cases', () => {
    it('handles node without properties', () => {
      createWrapper({ node: { name: 'Empty', domain: 'test' } });

      expect(findProperties()).toHaveLength(0);
      expect(wrapper.text()).toContain('0');
    });

    it('handles node without description', () => {
      createWrapper({ node: { name: 'Minimal', domain: 'test', properties: [] } });

      expect(wrapper.text()).not.toContain('undefined');
    });
  });
});
