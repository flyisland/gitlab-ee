import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import Vue from 'vue';
import ProjectsDropdownFilter from '~/analytics/shared/components/projects_dropdown_filter.vue';
import RefSelector from '~/vue_shared/components/ref/components/ref_selector.vue';
import PerformanceValueFilters from 'jh/analytics/performance_analytics/components/performance_value_filters.vue';
import DateRangeSelector from 'jh/analytics/performance_analytics/components/date_range_selector.vue';
import createState from 'jh/analytics/performance_analytics/store/state';
import mutations from 'jh/analytics/performance_analytics/store/mutations';
import * as types from 'jh/analytics/performance_analytics/store/mutation_types';
import { currentGroup } from '../mock';

Vue.use(Vuex);

describe('PerformanceValueFilters', () => {
  let wrapper;
  const refreshPerformanceDataSpy = jest.fn();

  const fakeStore = (state) =>
    new Vuex.Store({
      state: createState({
        groupId: currentGroup.groupId,
        fullPath: currentGroup.fullPath,
        isGroup: currentGroup.isGroup,
        projectId: null,
        ...state,
      }),
      actions: {
        refreshPerformanceData: refreshPerformanceDataSpy,
      },
      mutations,
    });

  function createComponent(props = {}, state = {}) {
    const store = fakeStore(state);

    return shallowMount(PerformanceValueFilters, {
      store,
      propsData: {
        groupId: currentGroup.groupId,
        fullPath: currentGroup.fullPath,
        ...props,
      },
    });
  }

  const findProjectsDropdown = () => wrapper.findComponent(ProjectsDropdownFilter);
  const findDateRangeSelector = () => wrapper.findComponent(DateRangeSelector);
  const findRefSelector = () => wrapper.findComponent(RefSelector);

  beforeEach(() => {
    wrapper = createComponent();
    wrapper.vm.$store.commit(types.SET_LOADING_TOGGLE, false);
  });

  describe('in the group page', () => {
    it('will render the projects filter dropdown', () => {
      expect(findProjectsDropdown().exists()).toBe(true);

      expect(findProjectsDropdown().props()).toEqual(
        expect.objectContaining({
          queryParams: wrapper.vm.projectsQueryParams,
          multiSelect: true,
        }),
      );
    });

    describe('change the selected project', () => {
      it('should call refreshPerformanceData action', () => {
        findProjectsDropdown().vm.$emit('selected', ['test-project']);
        expect(wrapper.vm.selectedProjects).toEqual(['test-project']);
        expect(refreshPerformanceDataSpy).toHaveBeenCalled();
      });
    });
  });

  describe('in the project page', () => {
    beforeEach(() => {
      wrapper = createComponent({}, { isGroup: false });
    });

    it('does not render the projects filter dropdown', () => {
      expect(findProjectsDropdown().exists()).toBe(false);
    });

    it('should render the branch selector', () => {
      expect(findRefSelector().exists()).toBe(true);
    });
  });

  describe('change the selected date', () => {
    it('should call refreshPerformanceData action', () => {
      expect(findDateRangeSelector().exists()).toBe(true);
      findDateRangeSelector().vm.$emit('updateDate', {
        startDate: new Date('2022-05-03'),
        endDate: new Date('2022-05-04'),
      });
      expect(refreshPerformanceDataSpy).toHaveBeenCalled();
    });
  });
});
