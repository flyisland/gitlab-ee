import { shallowMount } from '@vue/test-utils';
import { GlBadge, GlLoadingIcon } from '@gitlab/ui';
import ExplorerTablePanel from 'ee/orbit/components/explorer_table_panel.vue';
import QueryResultsTable from 'ee/orbit/components/query_results_table.vue';

jest.mock('ee/orbit/utils/csv_export', () => ({
  downloadCsv: jest.fn(),
}));

describe('ExplorerTablePanel', () => {
  let wrapper;

  const mockResponse = {
    nodes: [{ type: 'User', id: 1, username: 'admin' }],
    edges: [],
    columns: [],
    row_count: 1,
  };

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(ExplorerTablePanel, {
      propsData: {
        resultCount: 0,
        ...props,
      },
    });
  };

  describe('when loading', () => {
    beforeEach(() => {
      createWrapper({ loading: true, resultCount: 0 });
    });

    it('shows loading icon', () => {
      expect(wrapper.findComponent(GlLoadingIcon).exists()).toBe(true);
    });
  });

  describe('with no results', () => {
    beforeEach(() => {
      createWrapper({ resultCount: 0 });
    });

    it('shows empty state message', () => {
      expect(wrapper.find('[data-testid="table-empty-state"]').exists()).toBe(true);
    });
  });

  describe('with results', () => {
    beforeEach(() => {
      createWrapper({
        queryResponse: mockResponse,
        generatedSql: 'SELECT * FROM users',
        resultCount: 1,
      });
    });

    it('shows results header', () => {
      expect(wrapper.find('[data-testid="table-results-header"]').exists()).toBe(true);
    });

    it('shows result count badge', () => {
      expect(wrapper.findComponent(GlBadge).text()).toContain('1');
    });

    it('renders query results table', () => {
      expect(wrapper.findComponent(QueryResultsTable).exists()).toBe(true);
    });

    it('shows SQL toggle button when SQL is available', () => {
      expect(wrapper.find('[data-testid="toggle-sql-btn"]').exists()).toBe(true);
    });

    it('shows download CSV button', () => {
      expect(wrapper.find('[data-testid="download-csv-btn"]').exists()).toBe(true);
    });
  });

  describe('SQL toggle', () => {
    beforeEach(() => {
      createWrapper({
        queryResponse: mockResponse,
        generatedSql: 'SELECT * FROM users',
        resultCount: 1,
      });
    });

    it('hides SQL by default', () => {
      expect(wrapper.find('[data-testid="sql-display"]').exists()).toBe(false);
    });

    it('shows SQL after toggle', async () => {
      await wrapper.find('[data-testid="toggle-sql-btn"]').vm.$emit('click');

      expect(wrapper.find('[data-testid="sql-display"]').exists()).toBe(true);
      expect(wrapper.find('[data-testid="sql-display"]').text()).toContain('SELECT * FROM users');
    });
  });

  describe('expand toggle', () => {
    beforeEach(() => {
      createWrapper({ queryResponse: mockResponse, resultCount: 1 });
    });

    it('emits toggle-expand on expand button click', () => {
      wrapper.find('[data-testid="table-expand-btn"]').vm.$emit('click');

      expect(wrapper.emitted('toggle-expand')).toHaveLength(1);
    });
  });

  describe('row click', () => {
    beforeEach(() => {
      createWrapper({ queryResponse: mockResponse, resultCount: 1 });
    });

    it('emits row-click from results table', () => {
      const row = { type: 'User', id: 1 };
      wrapper.findComponent(QueryResultsTable).vm.$emit('row-click', row);

      expect(wrapper.emitted('row-click')[0]).toEqual([row]);
    });
  });
});
