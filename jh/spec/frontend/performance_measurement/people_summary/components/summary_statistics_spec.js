import { shallowMount } from '@vue/test-utils';
import SummaryStatistics from 'jh/performance_measurement/people_summary/components/summary_statistics.vue';
import SingleStat from '~/analytics/analytics_dashboards/components/visualizations/single_stat.vue';
import { ACTIVITY_METRICS } from 'jh/performance_measurement/people_summary/constants';

describe('SummaryStatistics', () => {
  const defaultFilters = {};
  let wrapper;
  const createComponent = (props = {}) => {
    wrapper = shallowMount(SummaryStatistics, {
      propsData: {
        filters: defaultFilters,
        ...props,
      },
    });
  };

  const findStatComponents = () => wrapper.findAllComponents(SingleStat);

  it('renders correctly', () => {
    createComponent();

    expect(findStatComponents()).toHaveLength(ACTIVITY_METRICS.length);
  });
});
