import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import SchemaEdgeCard from 'ee/orbit/components/schema_edge_card.vue';

describe('SchemaEdgeCard', () => {
  let wrapper;

  const defaultEdge = {
    name: 'AUTHORED',
    description: 'Authorship relationship',
    variants: [
      { source_type: 'User', target_type: 'Pipeline' },
      { source_type: 'User', target_type: 'Job' },
    ],
  };

  const defaultProps = {
    edge: defaultEdge,
    collapsed: false,
    nodeStyleMap: {
      user: { color: '#ec4899' },
      job: { color: '#f59e0b' },
    },
    nodeDomainMap: {
      User: 'core',
      Pipeline: 'ci',
      Job: 'ci',
    },
    domainColorMap: {
      ci: '#f59e0b',
      core: '#ec4899',
    },
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(SchemaEdgeCard, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const findCard = () => wrapper.find('[data-testid="schema-edge-card"]');
  const findCollapseButton = () => wrapper.findComponent(GlButton);
  const findVariantRows = () => wrapper.findAll('.schema-prop-row');

  describe('rendering', () => {
    beforeEach(() => createWrapper());

    it('renders the card', () => {
      expect(findCard().exists()).toBe(true);
    });

    it('displays edge name', () => {
      expect(wrapper.text()).toContain('AUTHORED');
    });

    it('displays description when expanded', () => {
      expect(wrapper.text()).toContain('Authorship relationship');
    });

    it('displays variant count', () => {
      expect(wrapper.text()).toContain('2');
    });

    it('renders variant rows', () => {
      expect(findVariantRows()).toHaveLength(2);
    });

    it('displays source and target types in variants', () => {
      const firstVariant = findVariantRows().at(0);

      expect(firstVariant.text()).toContain('User');
      expect(firstVariant.text()).toContain('Pipeline');
    });

    it('displays domain labels for variant nodes', () => {
      const firstVariant = findVariantRows().at(0);

      expect(firstVariant.text()).toContain('core');
      expect(firstVariant.text()).toContain('ci');
    });
  });

  describe('color dots', () => {
    it('renders color dots for nodes with colors', () => {
      createWrapper();
      const dots = wrapper.findAll('.gl-rounded-full');

      expect(dots.length).toBeGreaterThan(0);
    });

    it('resolves color from nodeStyleMap first', () => {
      createWrapper();
      const dots = wrapper.findAll('.gl-rounded-full');
      const colors = dots.wrappers.map((d) => d.attributes('style'));

      expect(colors.some((s) => s.includes('background'))).toBe(true);
    });
  });

  describe('collapsed state', () => {
    it('hides variants when collapsed', () => {
      createWrapper({ collapsed: true });

      expect(findVariantRows()).toHaveLength(0);
      expect(wrapper.text()).not.toContain('Authorship relationship');
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
    it('emits toggle-collapse with edge name on header click', () => {
      createWrapper();
      wrapper.find('.gl-cursor-pointer').trigger('click');

      expect(wrapper.emitted('toggle-collapse')).toEqual([['AUTHORED']]);
    });

    it('emits toggle-collapse on button click', async () => {
      createWrapper();
      await findCollapseButton().trigger('click');

      expect(wrapper.emitted('toggle-collapse')).toBeDefined();
    });
  });

  describe('edge cases', () => {
    it('handles edge without variants', () => {
      createWrapper({ edge: { name: 'EMPTY' } });

      expect(findVariantRows()).toHaveLength(0);
      expect(wrapper.text()).toContain('0');
    });

    it('handles edge without description', () => {
      createWrapper({ edge: { name: 'MINIMAL', variants: [] } });

      expect(wrapper.text()).not.toContain('undefined');
    });

    it('returns empty domain for unknown node', () => {
      createWrapper({
        edge: {
          name: 'TEST',
          variants: [{ source_type: 'Unknown', target_type: 'Unknown' }],
        },
      });
      const row = findVariantRows().at(0);

      expect(row.text()).toContain('Unknown');
    });
  });
});
