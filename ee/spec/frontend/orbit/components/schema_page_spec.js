import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { GlBadge, GlLoadingIcon } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { createAlert } from '~/alert';
import SchemaPage from 'ee/orbit/components/schema_page.vue';
import SchemaDomainSidebar from 'ee/orbit/components/schema_domain_sidebar.vue';
import SchemaNodeCard from 'ee/orbit/components/schema_node_card.vue';
import SchemaEdgeCard from 'ee/orbit/components/schema_edge_card.vue';
import * as orbitApi from 'ee/orbit/api/orbit_api';
import { mockExpandedSchema } from '../mock_data';

jest.mock('~/alert');
jest.mock('ee/orbit/api/orbit_api');

describe('SchemaPage', () => {
  let wrapper;

  const findSchemaContent = () => wrapper.find('[data-testid="schema-content"]');
  const findSidebar = () => wrapper.findComponent(SchemaDomainSidebar);
  const findNodeCards = () => wrapper.findAllComponents(SchemaNodeCard);
  const findEdgeCards = () => wrapper.findAllComponents(SchemaEdgeCard);
  const findTabNodeTypes = () => wrapper.find('[data-testid="tab-node-types"]');
  const findTabRelationships = () => wrapper.find('[data-testid="tab-relationships"]');
  const findSearch = () => wrapper.find('[data-testid="schema-search"]');

  const createWrapper = () => {
    wrapper = shallowMount(SchemaPage);
  };

  describe('loading state', () => {
    beforeEach(() => {
      orbitApi.fetchOrbitSchema.mockReturnValue(new Promise(() => {}));
      createWrapper();
    });

    it('shows loading icon while fetching schema', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('when schema loads successfully', () => {
    beforeEach(() => {
      orbitApi.fetchOrbitSchema.mockResolvedValueOnce({ data: mockExpandedSchema });
      createWrapper();
      return waitForPromises();
    });

    it('hides loading icon', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(false);
    });

    it('calls fetchOrbitSchema once with wildcard expand', () => {
      expect(orbitApi.fetchOrbitSchema).toHaveBeenCalledTimes(1);
      expect(orbitApi.fetchOrbitSchema).toHaveBeenCalledWith({ expand: '*' });
    });

    it('renders schema content', () => {
      expect(findSchemaContent().exists()).toBe(true);
    });

    describe('domain sidebar', () => {
      it('renders sidebar with correct props', () => {
        const sidebar = findSidebar();

        expect(sidebar.exists()).toBe(true);
        expect(sidebar.props('totalNodeCount')).toBe(5);
        expect(sidebar.props('domains').map((d) => d.name)).toEqual(['ci', 'core']);
      });

      it('filters nodes by selected domain', async () => {
        expect(findNodeCards()).toHaveLength(5);

        findSidebar().vm.$emit('select-domain', 'ci');
        await nextTick();

        expect(findNodeCards()).toHaveLength(3);
      });

      it('shows all nodes when All domains is selected', async () => {
        findSidebar().vm.$emit('select-domain', 'ci');
        await nextTick();

        findSidebar().vm.$emit('select-domain', null);
        await nextTick();

        expect(findNodeCards()).toHaveLength(5);
      });

      it('expands domain via toggleDomainExpand', async () => {
        findSidebar().vm.$emit('toggle-expand', 'ci');
        await nextTick();

        expect(findSidebar().props('expandedDomains')).toEqual({ ci: true });
      });
    });

    describe('tab navigation', () => {
      it('defaults to Node Types tab', () => {
        expect(findTabNodeTypes().attributes('selected')).toBe('true');
      });

      it('renders tab badges with counts', () => {
        const badges = wrapper.findAllComponents(GlBadge);
        const badgeTexts = badges.wrappers.map((b) => b.text());

        expect(badgeTexts).toContain('5');
        expect(badgeTexts).toContain('2');
      });
    });

    describe('node types tab', () => {
      it('renders SchemaNodeCard for each filtered node', () => {
        const cards = findNodeCards();

        expect(cards).toHaveLength(5);
        expect(cards.at(0).props('node').name).toBe('Job');
        expect(cards.at(0).props('node').description).toBe('A CI/CD job');
      });

      it('passes correct props to node cards', () => {
        const firstCard = findNodeCards().at(0);

        expect(firstCard.props('collapsed')).toBe(false);
        expect(firstCard.props('nodeColor')).toBe('#f59e0b');
      });

      it('uses schema style colors when provided', () => {
        expect(findNodeCards().at(0).props('nodeColor')).toBe('#f59e0b');
      });

      it('toggles node card collapse state via event', async () => {
        findNodeCards().at(0).vm.$emit('toggle-collapse', 'Job');
        await nextTick();

        expect(findNodeCards().at(0).props('collapsed')).toBe(true);

        findNodeCards().at(0).vm.$emit('toggle-collapse', 'Job');
        await nextTick();

        expect(findNodeCards().at(0).props('collapsed')).toBe(false);
      });
    });

    describe('relationships tab', () => {
      beforeEach(async () => {
        findTabRelationships().vm.$emit('click');
        await nextTick();
      });

      it('renders SchemaEdgeCard for each edge', () => {
        const cards = findEdgeCards();

        expect(cards).toHaveLength(2);
        expect(cards.at(0).props('edge').name).toBe('AUTHORED');
        expect(cards.at(0).props('edge').description).toBe('Authorship relationship');
      });

      it('passes data props instead of function props', () => {
        const card = findEdgeCards().at(0);

        expect(card.props('nodeStyleMap')).toBeDefined();
        expect(card.props('nodeDomainMap')).toBeDefined();
        expect(card.props('domainColorMap')).toBeDefined();
      });

      it('filters edges by domain', async () => {
        findSidebar().vm.$emit('select-domain', 'ci');
        await nextTick();

        expect(findEdgeCards().wrappers.length).toBeGreaterThan(0);
        expect(findEdgeCards().wrappers.some((w) => w.props('edge').name === 'CONTAINS')).toBe(
          true,
        );
      });
    });

    describe('search', () => {
      it('filters nodes by search query', async () => {
        findSearch().vm.$emit('input', 'User');
        await nextTick();

        expect(findNodeCards()).toHaveLength(1);
        expect(findNodeCards().at(0).props('node').name).toBe('User');
      });

      it('filters edges by search query', async () => {
        findTabRelationships().vm.$emit('click');
        await nextTick();

        findSearch().vm.$emit('input', 'AUTHORED');
        await nextTick();

        expect(findEdgeCards()).toHaveLength(1);
        expect(findEdgeCards().at(0).props('edge').name).toBe('AUTHORED');
      });
    });

    describe('nodeDomainMap', () => {
      it('maps node names to their domains', () => {
        expect(wrapper.vm.nodeDomainMap.Job).toBe('ci');
        expect(wrapper.vm.nodeDomainMap.User).toBe('core');
      });
    });

    describe('highlightNode', () => {
      it('switches to node types tab and highlights node', async () => {
        findTabRelationships().vm.$emit('click');
        await nextTick();

        findSidebar().vm.$emit('select-node', 'Job');
        await nextTick();

        expect(findTabNodeTypes().attributes('selected')).toBe('true');
        expect(wrapper.find('[data-node-name="Job"]').classes()).toContain('schema-node-highlight');
      });
    });
  });

  describe('when schema fetch fails', () => {
    beforeEach(() => {
      orbitApi.fetchOrbitSchema.mockRejectedValue(new Error('Network error'));
      createWrapper();
      return waitForPromises();
    });

    it('shows error alert', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: expect.stringContaining('Failed to load schema') }),
      );
    });
  });
});
