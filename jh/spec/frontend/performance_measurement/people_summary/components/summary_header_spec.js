import { nextTick } from 'vue';
import { GlDaterangePicker } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { getDayDifference } from '~/lib/utils/datetime_utility';
import SummaryHeader from 'jh/performance_measurement/people_summary/components/summary_header.vue';
import GroupsAndProjectsListbox from 'jh/performance_measurement/people_summary/components/groups_and_projects_listbox.vue';
import { DATE_RANGE_PICKER_SHORTCUTS } from 'jh/performance_measurement/people_summary/constants';

describe('SummaryHeader', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMountExtended(SummaryHeader);
  };

  const findDateRangeShortcut = () =>
    wrapper.findComponentByTestId('people-summary-date-range-shortcut');
  const findDateRangePicker = () => wrapper.findComponent(GlDaterangePicker);
  const findGroupsAndProjects = () => wrapper.findComponent(GroupsAndProjectsListbox);
  const findBranchSelector = () => wrapper.findComponentByTestId('people-summary-branch-selector');
  const findMemberSelector = () => wrapper.findComponentByTestId('people-summary-member-selector');

  beforeEach(() => {
    createComponent();
  });

  it('renders correctly', () => {
    expect(findDateRangeShortcut().exists()).toBe(true);
    expect(findDateRangePicker().exists()).toBe(true);
    expect(findGroupsAndProjects().exists()).toBe(true);
    expect(findBranchSelector().exists()).toBe(true);
    expect(findMemberSelector().exists()).toBe(true);
  });

  describe('filters events', () => {
    it.each`
      name                   | finder                   | event       | value
      ${'groupsAndProjects'} | ${findGroupsAndProjects} | ${'input'}  | ${['groups']}
      ${'branches'}          | ${findBranchSelector}    | ${'select'} | ${['branch-a']}
      ${'members'}           | ${findMemberSelector}    | ${'select'} | ${['member-b']}
    `('$name can update value correctly', async ({ name, finder, event, value }) => {
      const component = finder();

      component.vm.$emit(event, value);
      await nextTick();

      expect(wrapper.emitted('change').at(1)).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            [name]: value,
          }),
        ]),
      );
    });

    it('updates date ranges correctly', async () => {
      const picker = findDateRangePicker();

      const range = {
        startDate: new Date(),
        endDate: new Date(),
      };

      picker.vm.$emit('input', range);
      await nextTick();

      expect(wrapper.emitted('change').at(1)).toEqual(
        expect.arrayContaining([expect.objectContaining(range)]),
      );
    });

    it.each(DATE_RANGE_PICKER_SHORTCUTS.slice(1).map(({ value }) => value))(
      'updates the date ranges %s correctly',
      async (days) => {
        const raw = Number.parseInt(days.split('_')[1], 10);
        const shortcutSelector = findDateRangeShortcut();
        shortcutSelector.vm.$emit('input', days);
        await nextTick();

        const { startDate, endDate } = wrapper.vm.filters;

        expect(getDayDifference(startDate, endDate)).toBe(raw);
      },
    );
  });
});
