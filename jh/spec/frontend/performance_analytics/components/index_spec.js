import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import Vue from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import PerformanceAnalytics from 'jh/analytics/performance_analytics/components/index.vue';
import PerformanceValueFilters from 'jh/analytics/performance_analytics/components/performance_value_filters.vue';
import PerformanceBoard from 'jh/analytics/performance_analytics/components/performance_board.vue';
import PerformanceTable from 'jh/analytics/performance_analytics/components/performance_table.vue';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import createState from 'jh/analytics/performance_analytics/store/state';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import { currentGroup } from '../mock';

Vue.use(Vuex);

const fakeStore = () =>
  new Vuex.Store({
    state: createState({
      groupId: currentGroup.groupId,
      fullPath: currentGroup.fullPath,
      isGroup: currentGroup.isGroup,
      projectId: null,
    }),
    mutations,
  });

function createComponent(props = {}, state = {}) {
  const store = fakeStore(state);

  return shallowMount(PerformanceAnalytics, {
    store,
    propsData: props,
  });
}

describe('PerformanceAnalytics', () => {
  let wrapper;

  const findPerformanceValueFilters = () => wrapper.findComponent(PerformanceValueFilters);
  const findPerformanceBoard = () => wrapper.findComponent(PerformanceBoard);
  const findPerformanceTable = () => wrapper.findComponent(PerformanceTable);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);

  beforeEach(() => {
    wrapper = createComponent();
    wrapper.vm.$store.commit(types.SET_LOADING_TOGGLE, false);
  });

  it('will render performance value filters', () => {
    expect(findPerformanceValueFilters().exists()).toBe(true);
  });

  it('will render performance board component', () => {
    expect(findPerformanceBoard().exists()).toBe(true);
  });

  it('will render performance table component', () => {
    expect(findPerformanceTable().exists()).toBe(true);
  });

  describe('When loading', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('will render loading icon component', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('should not render board and table components', () => {
      expect(findPerformanceBoard().exists()).toBe(false);
      expect(findPerformanceTable().exists()).toBe(false);
    });
  });
});
