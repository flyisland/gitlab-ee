import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import MockAdapter from 'axios-mock-adapter';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import axios from '~/lib/utils/axios_utils';
import {
  HTTP_STATUS_INTERNAL_SERVER_ERROR,
  HTTP_STATUS_OK,
  HTTP_STATUS_UNPROCESSABLE_ENTITY,
} from '~/lib/utils/http_status';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import adminGroupsQuery from 'ee/orbit/settings/admin/graphql/admin_groups.query.graphql';
import adminExcludedGroupsQuery from 'ee/orbit/settings/admin/graphql/admin_excluded_groups.query.graphql';
import orbitUpdateMutation from 'ee/orbit/graphql/mutations/orbit_update.mutation.graphql';
import excludedNamespaceCreateMutation from 'ee/orbit/graphql/mutations/excluded_namespace_create.mutation.graphql';
import excludedNamespaceDestroyMutation from 'ee/orbit/graphql/mutations/excluded_namespace_destroy.mutation.graphql';
import { ADMIN_CACHE_CONFIG } from 'ee/orbit/settings/admin/graphql/cache_config';
import AdminSettingsPage from 'ee/orbit/settings/admin/admin_settings_page.vue';
import AdminBulkResultAlert from 'ee/orbit/settings/admin/admin_bulk_result_alert.vue';
import AdminConfirmModal from 'ee/orbit/settings/admin/admin_confirm_modal.vue';
import AdminGroupsTable from 'ee/orbit/settings/admin/admin_groups_table.vue';
import AdminGroupsWarnings from 'ee/orbit/settings/admin/admin_groups_warnings.vue';
import AdminHealthCard from 'ee/orbit/settings/admin/admin_health_card.vue';
import AdminInstanceSettings from 'ee/orbit/settings/admin/admin_instance_settings.vue';
import {
  buildGroup,
  buildOnGroup,
  excludeResponse,
  excludedGroupsResponse,
  groupsResponse,
  includeResponse,
  orbitStatusResponse,
  orbitUpdateResponse,
} from './mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');

Vue.use(VueApollo);

const STATUS_URL = '/api/v4/orbit/status';
const SETTINGS_PATH = '/admin/orbit.json';

describe('AdminSettingsPage', () => {
  let wrapper;
  let axiosMock;
  let groupsHandler;
  let excludedHandler;
  let updateHandler;
  let excludeHandler;
  let includeHandler;

  const acme = buildGroup({ name: 'acme' });
  const beta = buildGroup({ name: 'beta' });
  const gamma = buildGroup({ name: 'gamma' });
  const ready = buildOnGroup('ready');

  const createComponent = () => {
    wrapper = shallowMountExtended(AdminSettingsPage, {
      apolloProvider: createMockApollo(
        [
          [adminGroupsQuery, groupsHandler],
          [adminExcludedGroupsQuery, excludedHandler],
          [orbitUpdateMutation, updateHandler],
          [excludedNamespaceCreateMutation, excludeHandler],
          [excludedNamespaceDestroyMutation, includeHandler],
        ],
        {},
        ADMIN_CACHE_CONFIG,
      ),
      propsData: {
        settingsPath: SETTINGS_PATH,
        overviewPath: '/dashboard/orbit/overview',
        schemaPath: '/dashboard/orbit/schema',
        newGroupPath: '/groups/new',
        autoIndexEnabled: false,
        duoDefaultEnabled: true,
      },
    });
  };

  const findTable = () => wrapper.findComponent(AdminGroupsTable);
  const findHealth = () => wrapper.findComponent(AdminHealthCard);
  const findSettings = () => wrapper.findComponent(AdminInstanceSettings);
  const findModal = () => wrapper.findComponent(AdminConfirmModal);
  const findBulkResult = () => wrapper.findComponent(AdminBulkResultAlert);
  const findTableNames = () =>
    findTable()
      .props('groups')
      .map(({ name }) => name);

  const selectAndRun = async (paths, action) => {
    findTable().vm.$emit('select', paths);
    await nextTick();
    findTable().vm.$emit('action', action);
    await waitForPromises();
  };

  beforeEach(() => {
    window.gon = { ...window.gon, api_version: 'v4' };
    axiosMock = new MockAdapter(axios);
    axiosMock.onGet(STATUS_URL).reply(HTTP_STATUS_OK, orbitStatusResponse);
    groupsHandler = jest.fn().mockResolvedValue(groupsResponse([acme, beta, gamma, ready]));
    excludedHandler = jest.fn().mockResolvedValue(excludedGroupsResponse([beta]));
    updateHandler = jest.fn().mockResolvedValue(orbitUpdateResponse());
    excludeHandler = jest.fn().mockResolvedValue(excludeResponse());
    includeHandler = jest.fn().mockResolvedValue(includeResponse());
  });

  afterEach(() => {
    axiosMock.restore();
  });

  describe('when the page loads', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('passes the groups with their exclusion to the table', () => {
      expect(findTable().props()).toMatchObject({ isLoading: false, loadError: null });
      expect(findTable().props('groups')).toMatchObject([
        { name: 'acme', isExcluded: false, isOn: false },
        { name: 'beta', isExcluded: true, isOn: false },
        { name: 'gamma', isExcluded: false, isOn: false },
        { name: 'ready', isOn: true, phase: 'READY' },
      ]);
    });

    it('queries the first page of all top-level groups', () => {
      expect(groupsHandler).toHaveBeenCalledWith({
        search: null,
        withKnowledgeGraphEnabled: false,
        first: 20,
      });
    });

    it('passes the Orbit status to the health card', () => {
      expect(findHealth().props()).toEqual({
        isLoading: false,
        loadError: null,
        status: {
          overall: 'healthy',
          version: '0.128.0',
          components: orbitStatusResponse.system.components,
        },
      });
    });

    it('passes the initial settings', () => {
      expect(findSettings().props()).toMatchObject({
        autoIndexEnabled: false,
        duoDefaultEnabled: true,
      });
    });
  });

  describe('when the Orbit status call fails', () => {
    beforeEach(async () => {
      axiosMock.onGet(STATUS_URL).reply(HTTP_STATUS_INTERNAL_SERVER_ERROR);
      createComponent();
      await waitForPromises();
    });

    it('passes the load error to the health card and reports it', () => {
      expect(findHealth().props()).toMatchObject({
        isLoading: false,
        loadError: 'Something went wrong on the server. Try again.',
      });
      expect(Sentry.captureException).toHaveBeenCalled();
    });
  });

  describe('when the groups query fails', () => {
    beforeEach(async () => {
      groupsHandler.mockRejectedValue(new Error('Network error'));
      createComponent();
      await waitForPromises();
    });

    it('passes a load error to the table', () => {
      expect(findTable().props('loadError')).toBe(
        'The request did not reach GitLab. Check your connection and try again.',
      );
    });

    it('queries again on retry', async () => {
      groupsHandler.mockResolvedValue(groupsResponse([acme]));
      expect(groupsHandler).toHaveBeenCalledTimes(1);

      findTable().vm.$emit('retry');
      await waitForPromises();

      expect(groupsHandler).toHaveBeenCalledTimes(2);
      expect(findTable().props('loadError')).toBe(null);
    });
  });

  describe('when the index status is not available', () => {
    beforeEach(async () => {
      groupsHandler.mockResolvedValue({
        ...groupsResponse([buildGroup({ name: 'acme', knowledgeGraphEnabled: true })]),
        errors: [{ message: 'Knowledge graph request failed' }],
      });
      createComponent();
      await waitForPromises();
    });

    it('keeps the groups and passes the server message to the warnings', () => {
      expect(findTableNames()).toEqual(['acme']);
      expect(wrapper.findComponent(AdminGroupsWarnings).props()).toEqual({
        indexStatusError: 'Knowledge graph request failed',
        excludedGroupsError: null,
      });
    });
  });

  describe('when a group that is on has no index status', () => {
    beforeEach(async () => {
      groupsHandler.mockResolvedValue(
        groupsResponse([buildGroup({ name: 'acme', knowledgeGraphEnabled: true })]),
      );
      createComponent();
      await waitForPromises();
    });

    it('passes a generic index status warning', () => {
      expect(wrapper.findComponent(AdminGroupsWarnings).props('indexStatusError')).toBe(
        'Orbit did not return the index status of some groups.',
      );
    });
  });

  describe('when the excluded groups query fails', () => {
    beforeEach(async () => {
      excludedHandler.mockResolvedValue({
        data: { knowledgeGraphExcludedNamespaces: null },
        errors: [{ message: 'Excluded groups are not available' }],
      });
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('select', ['acme']);
      await nextTick();
    });

    it('passes the error to the warnings and offers no action', () => {
      expect(wrapper.findComponent(AdminGroupsWarnings).props('excludedGroupsError')).toBe(
        'Excluded groups are not available',
      );
      expect(findTable().props('actionItems')).toEqual([]);
    });
  });

  describe('when a later page of excluded groups returns no data', () => {
    beforeEach(async () => {
      excludedHandler
        .mockResolvedValueOnce(
          excludedGroupsResponse([beta], { hasNextPage: true, endCursor: 'c1' }),
        )
        .mockResolvedValueOnce({
          data: { knowledgeGraphExcludedNamespaces: null },
          errors: [{ message: 'Excluded groups are not available' }],
        });
      createComponent();
      await waitForPromises();
    });

    it('passes the server message to the warnings and keeps the first page', () => {
      expect(wrapper.findComponent(AdminGroupsWarnings).props('excludedGroupsError')).toBe(
        'Excluded groups are not available',
      );
      expect(findTable().props('groups')).toMatchObject([
        { name: 'acme', isExcluded: false },
        { name: 'beta', isExcluded: true },
        { name: 'gamma', isExcluded: false },
        { name: 'ready', isExcluded: false },
      ]);
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });

  describe('when the excluded groups have no index status', () => {
    beforeEach(async () => {
      excludedHandler.mockResolvedValue({
        ...excludedGroupsResponse([buildGroup({ name: 'beta', knowledgeGraphEnabled: true })]),
        errors: [{ message: 'Knowledge graph request failed', path: ['nodes', 0, 'orbit'] }],
      });
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('select', ['beta']);
      await nextTick();
    });

    it('keeps the exclusion of each group and offers no turn on', () => {
      expect(wrapper.findComponent(AdminGroupsWarnings).props('excludedGroupsError')).toBe(null);
      expect(findTable().props('groups')).toMatchObject([
        { name: 'acme', isExcluded: false },
        { name: 'beta', isExcluded: true },
        { name: 'gamma', isExcluded: false },
        { name: 'ready', isExcluded: false },
      ]);
      expect(findTable().props('actionItems')).toEqual([
        { value: 'include', text: 'Remove exclusion' },
      ]);
    });
  });

  describe('when a group is indexing', () => {
    beforeEach(async () => {
      jest.useFakeTimers();
      groupsHandler.mockResolvedValue(groupsResponse([buildOnGroup('acme', 'SYNCING')]));
      createComponent();
      await waitForPromises();
    });

    it('polls the groups every 30 seconds', async () => {
      expect(groupsHandler).toHaveBeenCalledTimes(1);

      jest.advanceTimersByTime(30000);
      await waitForPromises();

      expect(groupsHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('when the excluded groups span more than one page', () => {
    beforeEach(async () => {
      excludedHandler
        .mockResolvedValueOnce(
          excludedGroupsResponse([beta], { hasNextPage: true, endCursor: 'c1' }),
        )
        .mockResolvedValueOnce(excludedGroupsResponse([ready]));
      createComponent();
      await waitForPromises();
    });

    it('loads every page and marks the groups of each page as excluded', () => {
      expect(excludedHandler).toHaveBeenCalledTimes(2);
      expect(excludedHandler).toHaveBeenLastCalledWith({ first: 100, after: 'c1' });
      expect(findTable().props('groups')).toMatchObject([
        { name: 'acme', isExcluded: false },
        { name: 'beta', isExcluded: true },
        { name: 'gamma', isExcluded: false },
        { name: 'ready', isExcluded: true },
      ]);
    });
  });

  describe('while the next page of excluded groups loads', () => {
    beforeEach(async () => {
      excludedHandler
        .mockResolvedValueOnce(
          excludedGroupsResponse([beta], { hasNextPage: true, endCursor: 'c1' }),
        )
        .mockReturnValueOnce(new Promise(() => {}));
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('select', ['acme']);
      await nextTick();
    });

    it('offers no action', () => {
      expect(findTable().props('actionItems')).toEqual([]);
    });
  });

  describe('when the filter changes', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('queries only the groups with Orbit on', async () => {
      findTable().vm.$emit('filter', 'on');
      await waitForPromises();

      expect(groupsHandler).toHaveBeenLastCalledWith(
        expect.objectContaining({ withKnowledgeGraphEnabled: true }),
      );
    });

    it('shows the excluded groups for the excluded filter', async () => {
      findTable().vm.$emit('filter', 'excluded');
      await waitForPromises();

      expect(findTableNames()).toEqual(['beta']);
      expect(findTable().props('pageInfo')).toEqual({});
    });
  });

  describe('when the excluded groups are searched by full path', () => {
    beforeEach(async () => {
      excludedHandler.mockResolvedValue(
        excludedGroupsResponse([buildGroup({ name: 'Beta', fullPath: 'orbit-page-01' })]),
      );
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('filter', 'excluded');
      findTable().vm.$emit('search', 'page-01');
      await waitForPromises();
    });

    it('shows the group whose path matches', () => {
      expect(findTableNames()).toEqual(['Beta']);
    });
  });

  describe('when the search changes', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('select', ['acme']);
      findTable().vm.$emit('search', 'ac');
      await waitForPromises();
    });

    it('queries with the search and clears the selection', () => {
      expect(groupsHandler).toHaveBeenLastCalledWith(expect.objectContaining({ search: 'ac' }));
      expect(findTable().props('selectedPaths')).toEqual([]);
    });
  });

  describe('when the next page is requested', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('next', 'cursor-1');
      await waitForPromises();
    });

    it('queries after the cursor', () => {
      expect(groupsHandler).toHaveBeenLastCalledWith(
        expect.objectContaining({ first: 20, after: 'cursor-1' }),
      );
    });
  });

  describe('when groups are selected', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      findTable().vm.$emit('select', ['acme', 'ready']);
      await nextTick();
    });

    it('passes only the actions that change a selected group', () => {
      expect(findTable().props('actionItems')).toEqual([
        { value: 'turnOn', text: 'Turn on Orbit' },
        { value: 'turnOff', text: 'Turn off Orbit' },
        { value: 'exclude', text: 'Exclude from automatic indexing' },
      ]);
    });
  });

  describe('when turning on selected groups', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await selectAndRun(['acme', 'beta', 'gamma', 'ready'], 'turnOn');
    });

    it('runs one update for each group that is off and not excluded', () => {
      expect(updateHandler).toHaveBeenCalledTimes(2);
      expect(updateHandler).toHaveBeenCalledWith({ input: { groupPath: 'acme', enabled: true } });
      expect(updateHandler).toHaveBeenCalledWith({ input: { groupPath: 'gamma', enabled: true } });
    });

    it('shows the result, clears the selection, and refetches the groups', () => {
      expect(findBulkResult().props('result')).toEqual({ action: 'turnOn', total: 2, failed: [] });
      expect(findTable().props()).toMatchObject({ selectedPaths: [], bulkProgress: null });
      expect(groupsHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('when some groups fail to turn on', () => {
    beforeEach(async () => {
      updateHandler.mockImplementation(({ input }) =>
        input.groupPath === 'gamma'
          ? Promise.resolve(orbitUpdateResponse(['Orbit is not available for this group']))
          : Promise.resolve(orbitUpdateResponse()),
      );
      createComponent();
      await waitForPromises();
      await selectAndRun(['acme', 'gamma'], 'turnOn');
    });

    it('lists the failed group and keeps it selected', () => {
      expect(findBulkResult().props('result')).toEqual({
        action: 'turnOn',
        total: 2,
        failed: [
          { name: 'gamma', fullPath: 'gamma', message: 'Orbit is not available for this group' },
        ],
      });
      expect(findTable().props('selectedPaths')).toEqual(['gamma']);
    });

    it('marks the failed row', () => {
      const failedRow = findTable()
        .props('groups')
        .find(({ name }) => name === 'gamma');

      expect(failedRow.failure).toEqual({
        kind: 'rejected',
        message: 'Orbit is not available for this group',
      });
    });

    describe('and the admin selects more groups and retries', () => {
      beforeEach(async () => {
        findTable().vm.$emit('select', ['gamma', 'beta', 'acme']);
        await nextTick();
        findBulkResult().vm.$emit('retry');
        await waitForPromises();
      });

      it('runs the action again for the failed group only', () => {
        expect(updateHandler).toHaveBeenCalledTimes(3);
        expect(updateHandler).toHaveBeenLastCalledWith({
          input: { groupPath: 'gamma', enabled: true },
        });
      });
    });

    describe('and the search changes', () => {
      beforeEach(async () => {
        findTable().vm.$emit('search', 'ga');
        await nextTick();
      });

      it('clears the result', () => {
        expect(findBulkResult().exists()).toBe(false);
      });
    });
  });

  describe('when a bulk action runs on many groups', () => {
    beforeEach(async () => {
      const groups = Array.from({ length: 7 }, (_, index) => buildGroup({ name: `g${index}` }));
      groupsHandler.mockResolvedValue(groupsResponse(groups));
      updateHandler.mockReturnValue(new Promise(() => {}));
      createComponent();
      await waitForPromises();
      await selectAndRun(
        groups.map(({ fullPath }) => fullPath),
        'turnOn',
      );
    });

    it('sends at most 5 requests at a time', () => {
      expect(updateHandler).toHaveBeenCalledTimes(5);
    });
  });

  describe('when the bulk requests do not reach GitLab', () => {
    const message = 'The request did not reach GitLab. Check your connection and try again.';

    beforeEach(async () => {
      updateHandler.mockRejectedValue(new Error('Network error'));
      createComponent();
      await waitForPromises();
      await selectAndRun(['acme', 'gamma'], 'turnOn');
    });

    it('lists the network error of each group and reports one error to Sentry', () => {
      expect(findBulkResult().props('result').failed).toEqual([
        { name: 'acme', fullPath: 'acme', message },
        { name: 'gamma', fullPath: 'gamma', message },
      ]);
      expect(Sentry.captureException).toHaveBeenCalledTimes(1);
    });
  });

  describe('when excluding a group that is off', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await selectAndRun(['acme'], 'exclude');
    });

    it('runs the exclusion and refetches the excluded groups', () => {
      expect(excludeHandler).toHaveBeenCalledWith({ input: { groupPath: 'acme' } });
      expect(excludedHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('when the excluded groups refetch fails after a bulk action', () => {
    beforeEach(async () => {
      excludedHandler
        .mockResolvedValueOnce(excludedGroupsResponse([beta]))
        .mockRejectedValueOnce(new Error('Network error'));
      createComponent();
      await waitForPromises();
      await selectAndRun(['acme'], 'exclude');
      findTable().vm.$emit('select', ['acme']);
      await nextTick();
    });

    it('keeps the error and offers no action', () => {
      expect(wrapper.findComponent(AdminGroupsWarnings).props('excludedGroupsError')).toBe(
        'The request did not reach GitLab. Check your connection and try again.',
      );
      expect(findTable().props('actionItems')).toEqual([]);
    });

    describe('and the admin retries in the excluded view', () => {
      beforeEach(async () => {
        excludedHandler.mockResolvedValue(excludedGroupsResponse([acme, beta]));
        findTable().vm.$emit('filter', 'excluded');
        await nextTick();
        findTable().vm.$emit('retry');
        await waitForPromises();
      });

      it('loads the excluded groups and clears the error', () => {
        expect(findTable().props('loadError')).toBe(null);
        expect(findTableNames()).toEqual(['acme', 'beta']);
      });
    });
  });

  describe('when removing the exclusion of a group', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await selectAndRun(['beta'], 'include');
    });

    it('runs the removal with no confirmation and refetches the excluded groups', () => {
      expect(includeHandler).toHaveBeenCalledWith({ input: { groupPath: 'beta' } });
      expect(findModal().props('kind')).toBe(null);
      expect(excludedHandler).toHaveBeenCalledTimes(2);
    });
  });

  describe('when excluding a group that is on', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await selectAndRun(['ready'], 'exclude');
    });

    it('asks for confirmation before it runs', () => {
      expect(findModal().props()).toMatchObject({
        kind: 'exclude',
        groups: [expect.objectContaining({ fullPath: 'ready' })],
        autoIndexEnabled: false,
      });
      expect(excludeHandler).not.toHaveBeenCalled();
    });

    describe('and the admin confirms', () => {
      beforeEach(async () => {
        findModal().vm.$emit('confirm', 'exclude');
        await waitForPromises();
      });

      it('runs the exclusion', () => {
        expect(excludeHandler).toHaveBeenCalledWith({ input: { groupPath: 'ready' } });
      });
    });
  });

  describe('when turning off a group', () => {
    const { bindInternalEventDocument } = useMockInternalEventsTracking();

    beforeEach(async () => {
      createComponent();
      await waitForPromises();
      await selectAndRun(['ready'], 'turnOff');
    });

    it('tracks the click and asks for confirmation before it runs', () => {
      const { trackEventSpy } = bindInternalEventDocument(wrapper.element);

      expect(trackEventSpy).toHaveBeenCalledWith('click_orbit_turn_off_indexing', {}, undefined);
      expect(findModal().props()).toMatchObject({
        kind: 'turnOff',
        groups: [expect.objectContaining({ fullPath: 'ready' })],
      });
      expect(updateHandler).not.toHaveBeenCalled();
    });

    describe('and the admin confirms', () => {
      beforeEach(async () => {
        findModal().vm.$emit('confirm', 'turnOff');
        findModal().vm.$emit('cancel');
        await waitForPromises();
      });

      it('turns off the group and closes the modal', () => {
        expect(updateHandler).toHaveBeenCalledWith({
          input: { groupPath: 'ready', enabled: false },
        });
        expect(findModal().props('kind')).toBe(null);
      });
    });
  });

  describe('when a setting changes', () => {
    beforeEach(async () => {
      axiosMock.onPatch(SETTINGS_PATH).reply(HTTP_STATUS_OK, {});
      createComponent();
      await waitForPromises();
      findSettings().vm.$emit('change', { setting: 'orbit_dap_enabled_by_default', value: false });
      await waitForPromises();
    });

    it('saves the setting and shows the new value', () => {
      expect(JSON.parse(axiosMock.history.patch[0].data)).toEqual({
        application_setting: { orbit_dap_enabled_by_default: false },
      });
      expect(findSettings().props('duoDefaultEnabled')).toBe(false);
    });
  });

  describe('when a setting fails to save', () => {
    beforeEach(async () => {
      axiosMock
        .onPatch(SETTINGS_PATH)
        .reply(HTTP_STATUS_UNPROCESSABLE_ENTITY, { message: 'Orbit settings are invalid' });
      createComponent();
      await waitForPromises();
      findSettings().vm.$emit('change', { setting: 'orbit_dap_enabled_by_default', value: false });
      await waitForPromises();
    });

    it('keeps the old value and passes the server message', () => {
      expect(findSettings().props()).toMatchObject({
        duoDefaultEnabled: true,
        saveError: 'Orbit settings are invalid',
      });
    });

    it('clears the error on dismiss', async () => {
      findSettings().vm.$emit('dismiss-error');
      await nextTick();

      expect(findSettings().props('saveError')).toBe(null);
    });
  });

  describe('when automatic indexing is turned on', () => {
    beforeEach(async () => {
      axiosMock.onPatch(SETTINGS_PATH).reply(HTTP_STATUS_OK, {});
      createComponent();
      await waitForPromises();
      findSettings().vm.$emit('change', {
        setting: 'orbit_auto_index_root_namespace',
        value: true,
      });
      await nextTick();
    });

    it('asks for confirmation before it saves', () => {
      expect(findModal().props('kind')).toBe('autoIndex');
      expect(axiosMock.history.patch).toHaveLength(0);
    });

    it('saves the setting after the admin confirms', async () => {
      findModal().vm.$emit('confirm', 'autoIndex');
      await waitForPromises();

      expect(axiosMock.history.patch).toHaveLength(1);
      expect(findSettings().props('autoIndexEnabled')).toBe(true);
    });
  });
});
