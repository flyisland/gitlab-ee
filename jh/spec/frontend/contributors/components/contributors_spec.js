import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import Vue, { nextTick } from 'vue';
import ContributorsCharts from 'jh/contributors/components/contributors.vue';
import { createStore } from '~/contributors/stores';
import axios from '~/lib/utils/axios_utils';
import { mockBranch, mockChartData, mockEndpoint } from '../mock_data';

let wrapper;
let mock;
let store;
const Component = Vue.extend(ContributorsCharts);

function factory() {
  mock = new MockAdapter(axios);
  jest.spyOn(axios, 'get');
  mock.onGet().reply(200, mockChartData);
  store = createStore();

  wrapper = mount(Component, {
    propsData: {
      branch: mockBranch,
      endpoint: mockEndpoint,
    },
    stubs: {
      GlLoadingIcon: true,
      GlAreaChart: true,
    },
    store,
  });
}

describe('Contributors charts', () => {
  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    mock.restore();
  });

  it('should fetch chart data when mounted', () => {
    expect(axios.get).toHaveBeenCalledWith(mockEndpoint);
  });

  it('should display loader whiled loading data', async () => {
    wrapper.vm.$store.state.loading = true;
    await nextTick();
    expect(wrapper.find('.contributors-loader').exists()).toBe(true);
  });

  it('should render charts when loading completed and there is chart data', async () => {
    expect(wrapper.find('.contributors-loader').exists()).toBe(true);
    expect(wrapper.find('.contributors-charts').exists()).toBe(false);
    wrapper.vm.$store.state.loading = false;
    wrapper.vm.$store.state.chartData = mockChartData;
    await nextTick();
    expect(wrapper.find('.contributors-loader').exists()).toBe(false);
    expect(wrapper.find('.contributors-charts').exists()).toBe(true);
  });
});
