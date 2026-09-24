import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import PeopleSummaryApp from 'jh/performance_measurement/people_summary/app.vue';
import SummaryHeader from 'jh/performance_measurement/people_summary/components/summary_header.vue';
import Statistics from 'jh/performance_measurement/people_summary/components/summary_statistics.vue';

describe('PeopleSummaryApp', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMount(PeopleSummaryApp);
  };

  const findSummaryHeader = () => wrapper.findComponent(SummaryHeader);
  const findStatistics = () => wrapper.findComponent(Statistics);

  beforeEach(() => {
    createComponent();
  });

  it('renders app correctly', () => {
    expect(findSummaryHeader().exists()).toBe(true);
    expect(findStatistics().exists()).toBe(true);
  });

  it('handles filter updates from summary header and pass it down to the statistics', async () => {
    const updates = {
      startDate: new Date(),
      endDate: new Date(),
    };

    findSummaryHeader().vm.$emit('change', updates);
    await nextTick();

    expect(findStatistics().props('filters')).toBe(updates);
  });
});
