import { GlToggle } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import getBoardNamespaceStatusesQuery from 'ee/work_items/board/graphql/get_namespace_statuses.query.graphql';
import WorkItemDisplaySettingsGroupBy from '~/work_items/list/components/work_item_display_settings_group_by.vue';
import {
  persistMetadataPreference,
  alertPreferenceError,
} from '~/work_items/list/display_settings_preferences';
import { buildStatus, buildNamespaceStatusesResponse } from 'jest/work_items/board/mock_data';

jest.mock('~/work_items/list/display_settings_preferences', () => ({
  persistMetadataPreference: jest.fn(),
  alertPreferenceError: jest.fn(),
}));

Vue.use(VueApollo);

describe('WorkItemDisplaySettingsGroupBy', () => {
  let wrapper;

  const statusesQueryHandler = jest.fn();

  const statuses = [buildStatus(1, 'Triage'), buildStatus(2, 'To do')];
  // getGroupId scopes the id to the status grouping: `status:<gid>`.
  const groupId = (status) => `status:${status.id}`;

  const findToggles = () => wrapper.findAllComponents(GlToggle);
  const findHideAll = () => wrapper.findByTestId('hide-all');

  const createComponent = async ({ props = {} } = {}) => {
    const apolloProvider = createMockApollo([
      [getBoardNamespaceStatusesQuery, statusesQueryHandler],
    ]);

    wrapper = shallowMountExtended(WorkItemDisplaySettingsGroupBy, {
      apolloProvider,
      propsData: {
        fullPath: 'group/full/path',
        workItemTypeId: 'gid://gitlab/WorkItems::Type/1',
        sortKey: 'CREATED_DESC',
        ...props,
      },
    });

    await waitForPromises();
  };

  beforeEach(() => {
    statusesQueryHandler.mockResolvedValue(buildNamespaceStatusesResponse(statuses));
  });

  describe('rendering', () => {
    it('renders an enabled toggle for each status, shown by default', async () => {
      await createComponent();

      const toggles = findToggles();
      expect(toggles).toHaveLength(2);
      expect(toggles.at(0).props()).toMatchObject({ value: true, label: 'Triage' });
      expect(toggles.at(1).props()).toMatchObject({ value: true, label: 'To do' });
    });

    it('reflects the persisted visibleGroups: only listed groups are on', async () => {
      await createComponent({
        props: { namespacePreferences: { visibleGroups: [groupId(statuses[0])] } },
      });

      expect(findToggles().at(0).props('value')).toBe(true);
      expect(findToggles().at(1).props('value')).toBe(false);
    });
  });

  describe('toggling group visibility', () => {
    it('persists the remaining visible groups when a group is hidden', async () => {
      await createComponent();

      findToggles().at(1).vm.$emit('change');
      await waitForPromises();

      expect(persistMetadataPreference).toHaveBeenCalledWith({
        apolloClient: expect.anything(),
        namespace: 'group/full/path',
        workItemTypeId: 'gid://gitlab/WorkItems::Type/1',
        userPreferencesOnly: false,
        displaySettings: { visibleGroups: [groupId(statuses[0])] },
        sort: 'CREATED_DESC',
      });
    });

    it('normalizes back to null when every group becomes visible again', async () => {
      await createComponent({
        props: { namespacePreferences: { visibleGroups: [groupId(statuses[0])] } },
      });

      findToggles().at(1).vm.$emit('change');
      await waitForPromises();

      expect(persistMetadataPreference).toHaveBeenCalledWith(
        expect.objectContaining({ displaySettings: { visibleGroups: null } }),
      );
    });

    it('preserves other display settings when persisting', async () => {
      await createComponent({
        props: { namespacePreferences: { hiddenMetadataKeys: ['labels'] } },
      });

      findToggles().at(0).vm.$emit('change');
      await waitForPromises();

      expect(persistMetadataPreference).toHaveBeenCalledWith(
        expect.objectContaining({
          displaySettings: {
            hiddenMetadataKeys: ['labels'],
            visibleGroups: [groupId(statuses[1])],
          },
        }),
      );
    });

    it('emits update-settings instead of persisting for a saved view', async () => {
      await createComponent({ props: { isSavedView: true } });

      findToggles().at(1).vm.$emit('change');
      await waitForPromises();

      expect(persistMetadataPreference).not.toHaveBeenCalled();
      expect(wrapper.emitted('update-settings')).toEqual([
        [{ visibleGroups: [groupId(statuses[0])] }],
      ]);
    });

    it('surfaces an alert when persistence fails', async () => {
      const error = new Error('nope');
      persistMetadataPreference.mockRejectedValueOnce(error);
      await createComponent();

      findToggles().at(0).vm.$emit('change');
      await waitForPromises();

      expect(alertPreferenceError).toHaveBeenCalledWith(error);
    });
  });

  describe('Hide all', () => {
    it('persists an empty visibleGroups array', async () => {
      await createComponent();

      findHideAll().trigger('click');
      await waitForPromises();

      expect(persistMetadataPreference).toHaveBeenCalledWith(
        expect.objectContaining({ displaySettings: { visibleGroups: [] } }),
      );
    });

    it('does not persist again when every group is already hidden', async () => {
      await createComponent({ props: { namespacePreferences: { visibleGroups: [] } } });

      findHideAll().trigger('click');
      await waitForPromises();

      expect(persistMetadataPreference).not.toHaveBeenCalled();
    });
  });
});
