import { shallowMount } from '@vue/test-utils';
import { GlTable } from '@gitlab/ui';
import QueryResultsTable from 'ee/orbit/components/query_results_table.vue';

describe('QueryResultsTable', () => {
  let wrapper;

  const mockResults = {
    nodes: [
      { type: 'User', id: 1, username: 'admin', name: 'Administrator' },
      { type: 'User', id: 2, username: 'dev', name: 'Developer' },
    ],
    edges: [],
    columns: [],
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(QueryResultsTable, {
      propsData: {
        results: { nodes: [], edges: [], columns: [] },
        ...props,
      },
    });
  };

  describe('with empty results', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('renders the GlEmptyState', () => {
      expect(wrapper.find('[data-testid="results-empty-state"]').exists()).toBe(true);
    });
  });

  describe('with results', () => {
    beforeEach(() => {
      createWrapper({ results: mockResults });
    });

    it('renders GlTable', () => {
      expect(wrapper.findComponent(GlTable).exists()).toBe(true);
    });

    it('passes flattened rows to table', () => {
      const table = wrapper.findComponent(GlTable);

      expect(table.props('items')).toHaveLength(2);
    });

    it('generates fields from row keys', () => {
      const table = wrapper.findComponent(GlTable);
      const fields = table.props('fields');

      expect(fields.map((f) => f.key)).toContain('username');
      expect(fields.map((f) => f.key)).toContain('name');
    });

    it('emits row-click on table row click', () => {
      const row = { type: 'User', id: 1 };
      wrapper.findComponent(GlTable).vm.$emit('row-clicked', row);

      expect(wrapper.emitted('row-click')[0]).toEqual([row]);
    });
  });
});
