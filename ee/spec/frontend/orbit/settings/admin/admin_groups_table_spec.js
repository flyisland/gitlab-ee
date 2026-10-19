import {
  GlAlert,
  GlCollapsibleListbox,
  GlDisclosureDropdown,
  GlKeysetPagination,
  GlSearchBoxByType,
} from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import AdminGroupsTable from 'ee/orbit/settings/admin/admin_groups_table.vue';
import { ENABLED_AT, buildRow } from './mock_data';

describe('AdminGroupsTable', () => {
  let wrapper;

  const defaultProps = {
    groups: [
      buildRow({ name: 'acme', isOn: true, phase: 'SYNCING', enabledAt: ENABLED_AT }),
      buildRow({ name: 'beta', isExcluded: true }),
    ],
    selectedPaths: [],
    actionItems: [],
    search: '',
    filter: 'all',
    pageInfo: { hasNextPage: true, hasPreviousPage: false, startCursor: 'a', endCursor: 'b' },
    isLoading: false,
    loadError: null,
    bulkProgress: null,
    newGroupPath: '/groups/new',
  };

  const createComponent = (props = {}) => {
    wrapper = mountExtended(AdminGroupsTable, { propsData: { ...defaultProps, ...props } });
  };

  const findRows = () => wrapper.findAll('tbody tr');
  const findRowText = (index) => findRows().at(index).text().replace(/\s+/g, ' ');
  const findRowCheckbox = (name) => wrapper.find(`tbody input[aria-label="Select ${name}"]`);
  const findSelectAll = () => wrapper.find('thead input[type="checkbox"]');
  const findActions = () => wrapper.findComponent(GlDisclosureDropdown);
  const findSearch = () => wrapper.findComponent(GlSearchBoxByType);
  const findFilter = () => wrapper.findComponent(GlCollapsibleListbox);
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findEmpty = () => wrapper.findByTestId('groups-empty');
  const findLoadError = () => wrapper.findComponent(GlAlert);
  const findNote = () => wrapper.findByTestId('group-note');

  describe('with groups', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows the Orbit state and index status of each group', () => {
      expect(findRowText(0)).toContain('acme On Indexing · Turned on');
      expect(findRowText(1)).toContain('beta Off Excluded Not indexed');
    });

    it('shows the filter with the current state', () => {
      expect(findFilter().props('toggleText')).toBe('Orbit state: All');
    });

    it('disables the Actions menu', () => {
      expect(findActions().props('disabled')).toBe(true);
    });

    it('emits select with the path of a checked group', async () => {
      await findRowCheckbox('beta').setChecked(true);

      expect(wrapper.emitted('select')).toEqual([[['beta']]]);
    });

    it('emits select with every path from the header checkbox', async () => {
      await findSelectAll().setChecked(true);

      expect(wrapper.emitted('select')).toEqual([[['acme', 'beta']]]);
    });

    it('emits next with the end cursor', () => {
      findPagination().vm.$emit('next', 'b');

      expect(wrapper.emitted('next')).toEqual([['b']]);
    });

    it('emits search with the new text', () => {
      findSearch().vm.$emit('input', 'ac');

      expect(wrapper.emitted('search')).toEqual([['ac']]);
    });
  });

  describe('with a selection and action items', () => {
    beforeEach(() => {
      createComponent({
        selectedPaths: ['beta'],
        actionItems: [{ value: 'turnOn', text: 'Turn on Orbit' }],
      });
    });

    it('shows the selected count', () => {
      expect(wrapper.text()).toContain('1 group selected');
    });

    it('emits action with the chosen action', () => {
      findActions().vm.$emit('action', { value: 'turnOn', text: 'Turn on Orbit' });

      expect(wrapper.emitted('action')).toEqual([['turnOn']]);
    });
  });

  describe('while a bulk action runs', () => {
    beforeEach(() => {
      createComponent({
        selectedPaths: ['acme', 'beta'],
        actionItems: [{ value: 'exclude', text: 'Exclude from automatic indexing' }],
        bulkProgress: { action: 'exclude', done: 1, total: 2, pendingPaths: ['beta'] },
      });
    });

    it('shows the progress', () => {
      expect(wrapper.text()).toContain('Excluding groups: 1 of 2 done');
    });

    it('shows the pending row as updating', () => {
      expect(findRowText(1)).toContain('Updating…');
    });

    it('disables the Actions menu, search, and row checkboxes', () => {
      expect(findActions().props('disabled')).toBe(true);
      expect(findSearch().props('disabled')).toBe(true);
      expect(findRowCheckbox('acme').attributes('disabled')).toBeDefined();
    });
  });

  describe('with groups that share a name', () => {
    beforeEach(() => {
      createComponent({
        groups: [
          buildRow({ name: 'acme' }),
          { ...buildRow({ name: 'acme' }), id: 'gid://gitlab/Group/2', fullPath: 'acme-2' },
        ],
      });
    });

    it('shows the path of the group whose path differs from its name', () => {
      expect(findRowText(0)).not.toContain('acme-2');
      expect(findRowText(1)).toContain('acme acme-2');
      expect(findRowCheckbox('acme-2').exists()).toBe(true);
    });
  });

  describe('with a failed group', () => {
    beforeEach(() => {
      createComponent({
        groups: [buildRow({ name: 'acme', failure: { kind: 'rejected', message: 'Not allowed' } })],
      });
    });

    it('shows the failed badge and the reason in the info button', () => {
      expect(findRowText(0)).toContain('Off Failed');
      expect(findNote().attributes('aria-label')).toBe('Not allowed');
    });
  });

  describe('with no groups', () => {
    describe('and no search', () => {
      beforeEach(() => {
        createComponent({ groups: [], pageInfo: {} });
      });

      it('shows the new group empty state and hides the toolbar', () => {
        expect(findEmpty().text()).toContain('No top-level groups yet');
        expect(findEmpty().find('a').attributes('href')).toBe('/groups/new');
        expect(findSearch().exists()).toBe(false);
      });
    });

    describe('and a search', () => {
      beforeEach(() => {
        createComponent({ groups: [], pageInfo: {}, search: 'zz&co' });
      });

      it('shows the no match empty state and keeps the toolbar', () => {
        expect(findEmpty().text()).toContain('No groups match "zz&co"');
        expect(findSearch().exists()).toBe(true);
      });

      it('emits an empty search from Clear search', async () => {
        await findEmpty().find('button').trigger('click');

        expect(wrapper.emitted('search')).toEqual([['']]);
      });
    });

    describe('and the excluded filter', () => {
      beforeEach(() => {
        createComponent({ groups: [], pageInfo: {}, filter: 'excluded' });
      });

      it('shows the no excluded groups empty state', () => {
        expect(findEmpty().text()).toContain('No groups are excluded');
      });
    });
  });

  describe('with a load error', () => {
    beforeEach(() => {
      createComponent({ groups: [], loadError: 'Something went wrong on the server. Try again.' });
    });

    it('shows the error and hides the table', () => {
      expect(findLoadError().text()).toContain('Something went wrong on the server. Try again.');
      expect(wrapper.findByTestId('groups-table').exists()).toBe(false);
    });

    it('emits retry from Try again', () => {
      findLoadError().vm.$emit('primary-action');

      expect(wrapper.emitted('retry')).toEqual([[]]);
    });
  });
});
