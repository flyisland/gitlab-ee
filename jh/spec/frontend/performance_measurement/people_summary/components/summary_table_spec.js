import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import { GlTable, GlPagination } from '@gitlab/ui';
import SummaryTable from 'jh/performance_measurement/people_summary/components/summary_table.vue';
import { fetchTableData } from 'jh/performance_measurement/people_summary/api';

jest.mock('jh/performance_measurement/people_summary/api', () => {
  return {
    fetchTableData: jest.fn().mockResolvedValue([]),
  };
});

describe('SummaryTable', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMount(SummaryTable);
  };
  const findTable = () => wrapper.findComponent(GlTable);
  const findPagination = () => wrapper.findComponent(GlPagination);

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    fetchTableData.mockClear();
  });

  it('renders correctly', () => {
    expect(findTable().exists()).toBe(true);
    expect(findPagination().exists()).toBe(true);
  });

  it('loads data correctly', () => {
    expect(fetchTableData).toHaveBeenCalledTimes(1);
  });

  describe('updates params', () => {
    it('updates page', async () => {
      const pagination = findPagination();

      const page = 2;
      pagination.vm.$emit('input', page);
      await nextTick();
      expect(fetchTableData).toHaveBeenCalledTimes(2);
      expect(fetchTableData).toHaveBeenNthCalledWith(
        2,
        expect.objectContaining({
          page,
        }),
      );
    });
    it('updates sort', async () => {
      const table = findTable();
      const sortBy = 'name';
      const sortDesc = true;
      table.vm.$emit('update:sortBy', sortBy);
      table.vm.$emit('update:sortDesc', sortDesc);
      await nextTick();
      expect(fetchTableData).toHaveBeenCalledTimes(2);
      expect(fetchTableData).toHaveBeenNthCalledWith(
        2,
        expect.objectContaining({
          sort: sortBy,
          sortDesc,
        }),
      );
    });
  });
});
