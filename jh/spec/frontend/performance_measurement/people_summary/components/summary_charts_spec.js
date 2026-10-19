import { nextTick } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import SummaryCharts from 'jh/performance_measurement/people_summary/components/summary_charts.vue';

describe('SummaryCharts', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMountExtended(SummaryCharts);
  };
  const findChart = () => wrapper.findByTestId('summary-chart');
  const findTabs = () => wrapper.findByTestId('summary-chart-tabs');
  const findTab = (tabName) => wrapper.findComponentByTestId(`summary-chart-tab-${tabName}`);
  const findTitle = () => wrapper.findByTestId('summary-chart-title');
  const findLoadingIcon = () => wrapper.findByTestId('summary-chart-loading-icon');

  beforeEach(() => {
    createComponent();
  });

  it('renders correctly', async () => {
    await waitForPromises();
    const loadingIcon = findLoadingIcon();
    const chart = findChart();
    const tabs = findTabs();

    expect(loadingIcon.exists()).toBe(false);
    expect(chart.exists()).toBe(true);
    expect(tabs.exists()).toBe(true);
  });

  it('updates the title when a tab is clicked', async () => {
    const title = findTitle();
    const tabs = wrapper.vm.$options.CHART_TABS;
    const tab = findTab(tabs.at(2).value);

    expect(title.text()).toBe(tabs.at(0).title);

    tab.vm.$emit('click');
    await nextTick();

    expect(title.text()).toBe(tabs.at(2).title);
  });
});
