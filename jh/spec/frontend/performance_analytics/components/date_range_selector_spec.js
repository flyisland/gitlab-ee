import { GlButton, GlButtonGroup, GlDaterangePicker } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DateRangeSelector from 'jh/analytics/performance_analytics/components/date_range_selector.vue';
import {
  DATE_RANGE_LIST,
  DATE_RANGE_LIMIT,
  DEFAULT_SELECT_RANGE,
} from 'jh/analytics/performance_analytics/constants';
import { sprintf } from '~/locale';
import { getDayDifference } from '~/lib/utils/datetime_utility';
import { mockSelectedDate } from '../mock';

function createComponent() {
  return shallowMount(DateRangeSelector, {
    propsData: {
      currentDate: mockSelectedDate.endDate,
      startDate: mockSelectedDate.startDate,
      endDate: mockSelectedDate.endDate,
    },
  });
}

describe('DateRangeSelector', () => {
  let wrapper;

  const findGlButtonGroup = () => wrapper.findComponent(GlButtonGroup);
  const findGlButtons = () => wrapper.findAllComponents(GlButton);
  const findGlDaterangePicker = () => wrapper.findComponent(GlDaterangePicker);

  beforeEach(() => {
    wrapper = createComponent();
  });

  describe('date button group', () => {
    let buttons = null;
    beforeEach(() => {
      wrapper = createComponent();
      buttons = findGlButtons();
    });

    it('render correctly', () => {
      expect(findGlButtonGroup().exists()).toBe(true);
      expect(buttons.exists()).toBe(true);
    });

    it('has 3 buttons', () => {
      expect(buttons).toHaveLength(3);
      DATE_RANGE_LIST.forEach((item, i) => {
        expect(buttons.at(i).text()).toBe(sprintf('Last %{days} days', { days: item }));
      });
    });

    it(`should default select ${DEFAULT_SELECT_RANGE} days`, () => {
      expect(buttons.at(2).props().selected).toBe(true);
      expect(buttons.at(2).text()).toBe(
        sprintf('Last %{days} days', { days: DEFAULT_SELECT_RANGE }),
      );
    });

    it('could click button to switch date range', () => {
      buttons.at(0).vm.$emit('click');
      const { startDate, endDate } = wrapper.emitted().updateDate[0][0];
      const dayDifference = getDayDifference(startDate, endDate);
      expect(wrapper.vm.selectedRange).toBe(7);
      expect(dayDifference).toBe(6);
    });
  });

  describe('date range picker', () => {
    it('render correctly', () => {
      expect(findGlDaterangePicker().exists()).toBe(true);
    });

    it(`limited to select ${DATE_RANGE_LIMIT} days`, () => {
      expect(findGlDaterangePicker().props().maxDateRange).toBe(DATE_RANGE_LIMIT);
    });

    it(`has the tooltip`, () => {
      expect(findGlDaterangePicker().props().tooltip).toBe(
        sprintf('Date range limited to %{number} days', {
          number: DATE_RANGE_LIMIT,
        }),
      );
    });
  });
});
