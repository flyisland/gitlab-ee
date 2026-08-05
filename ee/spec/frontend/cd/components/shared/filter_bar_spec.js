import { GlBadge, GlButton, GlButtonGroup } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';
import FilterBar from 'ee/cd/components/shared/filter_bar.vue';

describe('FilterBar', () => {
  let wrapper;

  const filters = [
    { id: 'ALL', text: 'All types' },
    { id: 'PRODUCTION', text: 'Production' },
    { id: 'STAGING', text: 'Staging' },
  ];

  const findButtonGroup = () => wrapper.findComponent(GlButtonGroup);
  const findFilterButtons = () => wrapper.findAllComponents(GlButton);
  const findFilterButtonById = (id) =>
    findFilterButtons().at(filters.findIndex((filter) => filter.id === id));
  const findSearchInput = () => wrapper.findByTestId('filter-search-input');

  const createComponent = (props = {}) => {
    wrapper = mountExtended(FilterBar, {
      propsData: {
        filters,
        ...props,
      },
    });
  };

  describe('filter buttons', () => {
    it('renders one button per filter inside a button group', () => {
      createComponent();

      expect(findButtonGroup().exists()).toBe(true);
      expect(findFilterButtons()).toHaveLength(3);
    });

    it('renders the text for each filter', () => {
      createComponent();

      expect(findFilterButtonById('ALL').text()).toBe('All types');
      expect(findFilterButtonById('PRODUCTION').text()).toBe('Production');
      expect(findFilterButtonById('STAGING').text()).toBe('Staging');
    });

    describe('active filter', () => {
      describe('when no selectedFilterId is provided', () => {
        it('marks the first filter as selected', () => {
          createComponent();

          expect(findFilterButtonById('ALL').props('selected')).toBe(true);
          expect(findFilterButtonById('PRODUCTION').props('selected')).toBe(false);
          expect(findFilterButtonById('STAGING').props('selected')).toBe(false);
        });
      });

      describe('when a selectedFilterId is provided', () => {
        beforeEach(() => {
          createComponent({ selectedFilterId: 'PRODUCTION' });
        });

        it('marks that filter as selected', () => {
          expect(findFilterButtonById('ALL').props('selected')).toBe(false);
          expect(findFilterButtonById('PRODUCTION').props('selected')).toBe(true);
        });
      });
    });

    describe('count badge', () => {
      it('does not render badges when no filter has a count', () => {
        createComponent();

        expect(wrapper.findAllComponents(GlBadge)).toHaveLength(0);
      });

      describe('when some filters have a count', () => {
        const filtersWithCounts = [
          { id: 'ALL', text: 'All types', count: 42 },
          { id: 'PRODUCTION', text: 'Production', count: 0 },
          { id: 'STAGING', text: 'Staging' },
        ];

        beforeEach(() => {
          createComponent({ filters: filtersWithCounts });
        });

        it('renders a badge only for filters that have a count', () => {
          expect(wrapper.findAllComponents(GlBadge)).toHaveLength(2);
        });

        it('displays the count inside each badge', () => {
          const badges = wrapper.findAllComponents(GlBadge);

          expect(badges.at(0).text()).toBe('42');
          expect(badges.at(1).text()).toBe('0');
        });
      });
    });

    describe('selecting a filter', () => {
      beforeEach(() => {
        createComponent();
      });

      describe('when a non-active filter is clicked', () => {
        beforeEach(async () => {
          await findFilterButtonById('PRODUCTION').trigger('click');
        });

        it('emits "filter-selected" with the filter id', () => {
          expect(wrapper.emitted('filter-selected')).toEqual([['PRODUCTION']]);
        });
      });

      describe('when the already-active filter is clicked', () => {
        beforeEach(async () => {
          await findFilterButtonById('ALL').trigger('click');
        });

        it('does not emit "filter-selected"', () => {
          expect(wrapper.emitted('filter-selected')).toBeUndefined();
        });
      });
    });
  });

  describe('search input', () => {
    it('renders the search input with the default placeholder and aria-label', () => {
      createComponent();

      expect(findSearchInput().attributes('placeholder')).toBe('Filter applications...');
      expect(findSearchInput().attributes('aria-label')).toBe('Filter applications...');
    });

    it('seeds the input with the searchTerm prop', () => {
      createComponent({ searchTerm: 'staging' });

      expect(findSearchInput().element.value).toBe('staging');
    });

    describe('when a custom searchPlaceholder is provided', () => {
      beforeEach(() => {
        createComponent({ searchPlaceholder: 'Filter environments...' });
      });

      it('uses the custom search placeholder', () => {
        expect(findSearchInput().attributes('placeholder')).toBe('Filter environments...');
      });
    });

    describe('when the searchTerm prop changes', () => {
      beforeEach(async () => {
        createComponent();

        await wrapper.setProps({ searchTerm: 'production' });
      });

      it('updates the input', () => {
        expect(findSearchInput().element.value).toBe('production');
      });
    });

    it('emits "search" with the typed value', async () => {
      createComponent();

      await findSearchInput().setValue('prod');

      expect(wrapper.emitted('search')).toEqual([['prod']]);
    });

    describe('debouncing', () => {
      // Opt the lodash-es debounce mock into its asynchronous mode so the
      // debounce delay and cleanup are observable.
      beforeAll(() => {
        createComponent();
        global.JEST_DEBOUNCE_THROTTLE_TIMEOUT = DEFAULT_DEBOUNCE_AND_THROTTLE_MS;
      });

      afterAll(() => {
        global.JEST_DEBOUNCE_THROTTLE_TIMEOUT = undefined;
      });

      it('debounces the search event until the delay elapses', async () => {
        await findSearchInput().setValue('prod');

        expect(wrapper.emitted('search')).toBeUndefined();

        jest.advanceTimersByTime(DEFAULT_DEBOUNCE_AND_THROTTLE_MS);

        expect(wrapper.emitted('search')).toEqual([['prod']]);
      });
    });
  });
});
