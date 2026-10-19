import Vue, { nextTick, unref } from 'vue';
import VueApollo from 'vue-apollo';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { createAlert } from '~/alert';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import DashboardApp from 'ee/orbit/dashboard/dashboard_app.vue';
import OrbitExploreEmptyState from 'ee/orbit/components/orbit_explore_empty_state.vue';
import dashboardGroupsQuery from 'ee/orbit/dashboard/graphql/dashboard_groups.query.graphql';
import memberNamespacesQuery from 'ee/orbit/graphql/queries/member_namespaces.query.graphql';
import ownedTrialsQuery from 'ee/orbit/dashboard/graphql/owned_trials.query.graphql';
import { buildOrbitGroup } from '../mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');
jest.mock('~/alert');

Vue.use(VueApollo);

const groupsResponse = (nodes) => ({ data: { groups: { count: nodes.length, nodes } } });

// A render function: the MODE 3 host has no runtime compiler for a template stub.
const PageStub = {
  name: 'PageStub',
  inject: {
    enabledMemberGroups: { default: null },
    enabledGroupsCount: { default: null },
  },
  render(h) {
    const providedPaths = unref(this.enabledMemberGroups)?.map((group) => group.fullPath);

    return h('div', {
      attrs: {
        'data-testid': 'page',
        'data-provided-groups': providedPaths?.join(','),
        'data-groups-count': unref(this.enabledGroupsCount),
      },
    });
  },
};

describe('OrbitDashboardApp', () => {
  let wrapper;
  let groupsHandler;
  let memberGroupsHandler;
  let trialsHandler;

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const mountComponent = ({
    routeName = 'overview',
    groups = [buildOrbitGroup()],
    memberGroups = [],
    ownedTrials = [],
    trialAvailable = false,
    adminConfigurationPath = null,
    duoAccessible = true,
    orbitSettingsEnabled = true,
    defaultGroupMissing = false,
    groupsHandlerFn = null,
    memberGroupsHandlerFn = null,
    trialsHandlerFn = null,
  } = {}) => {
    groupsHandler = groupsHandlerFn || jest.fn().mockResolvedValue(groupsResponse(groups));
    memberGroupsHandler =
      memberGroupsHandlerFn ||
      jest.fn().mockResolvedValue({ data: { groups: { nodes: memberGroups } } });
    trialsHandler =
      trialsHandlerFn || jest.fn().mockResolvedValue({ data: { groups: { nodes: ownedTrials } } });

    wrapper = mountExtended(DashboardApp, {
      apolloProvider: createMockApollo([
        [dashboardGroupsQuery, groupsHandler],
        [memberNamespacesQuery, memberGroupsHandler],
        [ownedTrialsQuery, trialsHandler],
      ]),
      propsData: { adminConfigurationPath, duoAccessible, orbitSettingsEnabled },
      provide: {
        trialAvailable,
        currentUserId: 1,
        defaultGroupMissing,
        preferencesPath: '/-/profile/preferences',
      },
      mocks: { $route: { name: routeName, query: {} } },
      attachTo: document.body,
      stubs: {
        RouterView: PageStub,
        OrbitExploreEmptyState: true,
        'router-link': { props: ['to'], template: '<a data-testid="orbit-tab"><slot /></a>' },
      },
    });
  };

  const createComponent = async (options) => {
    mountComponent(options);
    // A second flush lets the empty-state query run after the groups query un-skips it.
    await waitForPromises();
    await waitForPromises();
  };

  const findTabs = () => wrapper.findAllByTestId('orbit-tab');
  const findEmptyState = () => wrapper.findComponent(OrbitExploreEmptyState);
  const findProvidedGroups = () => wrapper.findByTestId('page').attributes('data-provided-groups');
  const findQuickstart = () => wrapper.findByTestId('orbit-quickstart');
  const findQuickstartToggle = () => wrapper.findByTestId('orbit-quickstart-toggle');
  const findTrialEndedAlert = () => wrapper.findByTestId('orbit-trial-ended-alert');
  const findHeading = () => wrapper.find('h1');
  const findSettingsButton = () => wrapper.findByTestId('orbit-settings-btn');

  beforeEach(() => {
    localStorage.clear();
  });

  describe('while the groups load', () => {
    beforeEach(() => mountComponent());

    it('shows a large spinner and no tabs', () => {
      expect(wrapper.findComponent(GlLoadingIcon).props('size')).toBe('lg');
      expect(findTabs()).toHaveLength(0);
    });
  });

  describe('when no group has Orbit on', () => {
    describe('and the route is Overview', () => {
      beforeEach(() =>
        createComponent({ groups: [], memberGroups: [buildOrbitGroup({ enabled: false })] }),
      );

      it('shows the empty state with the groups the user belongs to', () => {
        expect(findEmptyState().props('availableGroups')).toEqual([
          expect.objectContaining({ name: 'gl-demo' }),
        ]);
      });

      it('shows no header, no tabs, and no Quickstart', () => {
        expect(findHeading().exists()).toBe(false);
        expect(findTabs()).toHaveLength(0);
        expect(findQuickstartToggle().exists()).toBe(false);
      });
    });

    describe('and the route is Schema', () => {
      beforeEach(() => createComponent({ routeName: 'schema', groups: [] }));

      it('does not read the groups for the empty state', () => {
        expect(memberGroupsHandler).not.toHaveBeenCalled();
      });

      it('shows the header and the tabs', () => {
        expect(findHeading().text()).toBe('Orbit');
        expect(findTabs()).toHaveLength(3);
      });
    });
  });

  describe('when a group has Orbit on', () => {
    beforeEach(() => createComponent());

    it('does not read the groups for the empty state', () => {
      expect(memberGroupsHandler).not.toHaveBeenCalled();
    });

    it('shows the header and the Overview, Schema, and Query editor tabs', () => {
      expect(findHeading().text()).toBe('Orbit');
      expect(findTabs().wrappers.map((tab) => tab.text())).toEqual([
        'Overview',
        'Schema',
        'Query editor',
      ]);
    });

    it('shows the feedback link', () => {
      expect(wrapper.text()).toContain('Leave feedback');
    });

    it('does not show the settings button', () => {
      expect(findSettingsButton().exists()).toBe(false);
    });

    it('provides the groups with Orbit on to the page', () => {
      expect(findProvidedGroups()).toBe('gl-demo');
    });
  });

  describe('when the user has more groups with Orbit on than the page loads', () => {
    beforeEach(() =>
      createComponent({
        groupsHandlerFn: jest
          .fn()
          .mockResolvedValue({ data: { groups: { count: 161, nodes: [buildOrbitGroup()] } } }),
      }),
    );

    it('provides the total count to the page', () => {
      expect(wrapper.findByTestId('page').attributes('data-groups-count')).toBe('161');
    });
  });

  describe('when the user is an admin', () => {
    beforeEach(() => createComponent({ adminConfigurationPath: '/admin/orbit' }));

    it('links the Settings button to the admin page', () => {
      expect(findSettingsButton().attributes('href')).toBe('/admin/orbit');
    });
  });

  describe('when the user views Schema', () => {
    beforeEach(() =>
      createComponent({ routeName: 'schema', groups: [buildOrbitGroup({ phase: 'SYNCING' })] }),
    );

    it('provides the groups with Orbit on to the page', () => {
      expect(findProvidedGroups()).toBe('gl-demo');
    });

    it('shows no alerts', () => {
      expect(wrapper.findComponent(GlAlert).exists()).toBe(false);
    });

    it('shows no Quickstart button and no panel', () => {
      expect(findQuickstartToggle().exists()).toBe(false);
      expect(findQuickstart().exists()).toBe(false);
    });

    describe('and a minute passes', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(60000);
        await waitForPromises();
      });

      it('does not poll', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('Quickstart', () => {
    describe('when the user has not closed it before', () => {
      beforeEach(() => createComponent());

      it('opens the panel', () => {
        expect(findQuickstart().exists()).toBe(true);
        expect(findQuickstartToggle().attributes('aria-expanded')).toBe('true');
      });

      describe('and the user closes the panel', () => {
        beforeEach(async () => {
          await wrapper.findByTestId('orbit-quickstart-close').trigger('click');
          await nextTick();
        });

        it('hides the panel', () => {
          expect(findQuickstart().exists()).toBe(false);
          expect(findQuickstartToggle().attributes('aria-expanded')).toBe('false');
        });

        it('moves focus to the Quickstart button and drops its aria-controls', () => {
          expect(document.activeElement).toBe(findQuickstartToggle().element);
          expect(findQuickstartToggle().attributes('aria-controls')).toBeUndefined();
        });

        it('remembers the choice for that user', () => {
          expect(localStorage.getItem('orbit-quickstart-closed:1')).toBe('true');
        });

        describe('and the user clicks the Quickstart button', () => {
          beforeEach(() => findQuickstartToggle().trigger('click'));

          it('opens the panel and remembers it', () => {
            expect(findQuickstart().exists()).toBe(true);
            expect(localStorage.getItem('orbit-quickstart-closed:1')).toBe('false');
          });
        });
      });
    });

    describe('when the user closed it before', () => {
      beforeEach(() => {
        localStorage.setItem('orbit-quickstart-closed:1', 'true');
        return createComponent();
      });

      it('keeps the panel closed', () => {
        expect(findQuickstart().exists()).toBe(false);
        expect(findQuickstartToggle().attributes('aria-expanded')).toBe('false');
      });
    });

    describe('when another user closed it in the same browser', () => {
      beforeEach(() => {
        localStorage.setItem('orbit-quickstart-closed:2', 'true');
        return createComponent();
      });

      it('opens the panel', () => {
        expect(findQuickstart().exists()).toBe(true);
      });
    });
  });

  describe('tab tracking', () => {
    const clickTab = (label) => {
      const { triggerEvent, trackEventSpy } = bindInternalEventDocument(wrapper.element);
      expect(trackEventSpy).not.toHaveBeenCalled();

      triggerEvent(wrapper.findByText(label).element);

      return trackEventSpy;
    };

    describe.each`
      routeName     | label             | eventName
      ${'schema'}   | ${'Overview'}     | ${'click_orbit_overview_tab'}
      ${'overview'} | ${'Schema'}       | ${'click_orbit_schema_tab'}
      ${'overview'} | ${'Query editor'} | ${'click_orbit_query_editor_tab'}
    `('when the user views $routeName', ({ routeName, label, eventName }) => {
      beforeEach(() => createComponent({ routeName }));

      it(`tracks a click on the ${label} tab`, () => {
        expect(clickTab(label)).toHaveBeenCalledWith(eventName, {});
      });
    });

    describe('when the user views Overview', () => {
      beforeEach(() => createComponent({ routeName: 'overview' }));

      it('does not track a click on the active Overview tab', () => {
        expect(clickTab('Overview')).not.toHaveBeenCalled();
      });
    });
  });

  describe('when a group is indexing', () => {
    beforeEach(() => createComponent({ groups: [buildOrbitGroup({ phase: 'SYNCING' })] }));

    it('loads the groups one time and shows the indexing alert', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(1);
      expect(wrapper.findByTestId('orbit-indexing-alert').exists()).toBe(true);
    });

    describe('and 20 seconds pass', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(20000);
        await waitForPromises();
      });

      it('loads the groups again', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(2);
      });
    });
  });

  describe('when every group is ready', () => {
    beforeEach(() => createComponent({ groups: [buildOrbitGroup({ phase: 'READY' })] }));

    it('loads the groups one time', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(1);
    });

    describe('and a minute passes', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(60000);
        await waitForPromises();
      });

      it('does not poll', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('when the indexing group becomes ready', () => {
    beforeEach(() => {
      const handler = jest
        .fn()
        .mockResolvedValueOnce(groupsResponse([buildOrbitGroup({ phase: 'SYNCING' })]))
        .mockResolvedValue(groupsResponse([buildOrbitGroup({ phase: 'READY' })]));

      return createComponent({ groupsHandlerFn: handler });
    });

    it('loads the groups one time', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(1);
    });

    describe('and the next poll reports it ready', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(20000);
        await waitForPromises();
      });

      it('polls one more time', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(2);
      });

      describe('and a minute passes', () => {
        beforeEach(async () => {
          jest.advanceTimersByTime(60000);
          await waitForPromises();
        });

        it('stops polling', () => {
          expect(groupsHandler).toHaveBeenCalledTimes(2);
        });
      });
    });
  });

  describe('when the trial lookup is available and a trial has ended', () => {
    beforeEach(() =>
      createComponent({
        trialAvailable: true,
        ownedTrials: [{ id: 'gid://gitlab/Group/9', orbitTrial: { state: 'ENDED' } }],
      }),
    );

    it('reads the trials of the owned groups', () => {
      expect(trialsHandler).toHaveBeenCalledTimes(1);
    });

    it('shows the trial ended alert', () => {
      expect(findTrialEndedAlert().exists()).toBe(true);
    });
  });

  describe('when the trial is active', () => {
    beforeEach(() =>
      createComponent({
        trialAvailable: true,
        ownedTrials: [{ id: 'gid://gitlab/Group/9', orbitTrial: { state: 'ACTIVE' } }],
      }),
    );

    it('shows no trial ended alert', () => {
      expect(findTrialEndedAlert().exists()).toBe(false);
    });
  });

  describe('when the instance has no trials', () => {
    beforeEach(() => createComponent({ trialAvailable: false }));

    it('does not read the trials', () => {
      expect(trialsHandler).not.toHaveBeenCalled();
    });
  });

  describe('when no group has Orbit on and a trial has ended', () => {
    beforeEach(() =>
      createComponent({
        groups: [],
        trialAvailable: true,
        ownedTrials: [{ id: 'gid://gitlab/Group/9', orbitTrial: { state: 'ENDED' } }],
      }),
    );

    it('shows the trial ended alert with the empty state', () => {
      expect(findTrialEndedAlert().exists()).toBe(true);
      expect(findEmptyState().exists()).toBe(true);
    });
  });

  describe('when Orbit errors on the indexing status', () => {
    beforeEach(() =>
      createComponent({
        groupsHandlerFn: jest.fn().mockResolvedValue({
          ...groupsResponse([{ ...buildOrbitGroup(), orbit: { indexingStatus: null } }]),
          errors: [{ message: 'Orbit unavailable' }],
        }),
      }),
    );

    it('keeps the group list and shows the Overview, not the empty state', () => {
      expect(findEmptyState().exists()).toBe(false);
      expect(findProvidedGroups()).toBe('gl-demo');
    });

    it('does not alert or report to Sentry', () => {
      expect(createAlert).not.toHaveBeenCalled();
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });

    describe('and a minute passes', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(60000);
        await waitForPromises();
      });

      it('does not poll', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(1);
      });
    });
  });

  describe('when the groups query errors with no data', () => {
    beforeEach(() =>
      createComponent({
        groupsHandlerFn: jest
          .fn()
          .mockResolvedValue({ data: null, errors: [{ message: 'complexity exceeded' }] }),
      }),
    );

    it('alerts one time and does not show the turn-on empty state', () => {
      expect(createAlert).toHaveBeenCalledTimes(1);
      expect(findEmptyState().exists()).toBe(false);
    });
  });

  describe('when the groups fail to load', () => {
    beforeEach(() =>
      createComponent({ groupsHandlerFn: jest.fn().mockRejectedValue(new Error('boom')) }),
    );

    it('alerts and does not show the turn-on empty state', () => {
      expect(createAlert).toHaveBeenCalledTimes(1);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('does not show an Overview with no groups', () => {
      expect(wrapper.findByTestId('page').exists()).toBe(false);
    });
  });

  describe('when a poll gets no indexing status while a group indexes', () => {
    const indexingGroups = groupsResponse([buildOrbitGroup({ phase: 'SYNCING' })]);
    const throttledGroups = {
      ...groupsResponse([{ ...buildOrbitGroup(), orbit: { indexingStatus: null } }]),
      errors: [{ message: 'Too many requests' }],
    };

    beforeEach(async () => {
      await createComponent({
        groupsHandlerFn: jest
          .fn()
          .mockResolvedValueOnce(indexingGroups)
          .mockResolvedValueOnce(throttledGroups)
          .mockResolvedValue(indexingGroups),
      });

      jest.advanceTimersByTime(20000);
      await waitForPromises();
    });

    it('keeps the last known status and the indexing alert', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(2);
      expect(wrapper.findByTestId('orbit-indexing-alert').exists()).toBe(true);
    });

    describe('and 20 seconds pass', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(20000);
        await waitForPromises();
      });

      it('polls again', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(3);
      });
    });
  });

  describe('when the browser tab is hidden while a group indexes', () => {
    const setHidden = (hidden) => {
      jest.spyOn(document, 'hidden', 'get').mockReturnValue(hidden);
      document.dispatchEvent(new Event('visibilitychange'));
    };

    beforeEach(async () => {
      await createComponent({ groups: [buildOrbitGroup({ phase: 'SYNCING' })] });
      setHidden(true);
      await nextTick();
      jest.advanceTimersByTime(60000);
      await waitForPromises();
    });

    it('does not poll', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(1);
    });

    describe('and the tab is visible again', () => {
      beforeEach(async () => {
        setHidden(false);
        await nextTick();
        jest.advanceTimersByTime(20000);
        await waitForPromises();
      });

      it('polls again', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(2);
      });
    });
  });

  describe('when a poll fails while a group indexes', () => {
    const indexingGroups = groupsResponse([buildOrbitGroup({ phase: 'SYNCING' })]);

    beforeEach(async () => {
      await createComponent({
        groupsHandlerFn: jest
          .fn()
          .mockResolvedValueOnce(indexingGroups)
          .mockRejectedValueOnce(new Error('boom'))
          .mockResolvedValue(indexingGroups),
      });

      jest.advanceTimersByTime(20000);
      await waitForPromises();
    });

    it('keeps the Overview with its groups and does not alert', () => {
      expect(groupsHandler).toHaveBeenCalledTimes(2);
      expect(createAlert).not.toHaveBeenCalled();
      expect(findProvidedGroups()).toBe('gl-demo');
    });

    describe('and the next poll runs', () => {
      beforeEach(async () => {
        jest.advanceTimersByTime(20000);
        await waitForPromises();
      });

      it('loads the groups', () => {
        expect(groupsHandler).toHaveBeenCalledTimes(3);
      });
    });
  });

  describe('when the trials fail to load', () => {
    beforeEach(() =>
      createComponent({
        trialAvailable: true,
        trialsHandlerFn: jest.fn().mockRejectedValue(new Error('cdot down')),
      }),
    );

    it('reports to Sentry and shows no trial-ended alert', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error));
      expect(findTrialEndedAlert().exists()).toBe(false);
    });
  });

  describe('when the trials query returns GraphQL errors', () => {
    beforeEach(() =>
      createComponent({
        trialAvailable: true,
        trialsHandlerFn: jest
          .fn()
          .mockResolvedValue({ data: null, errors: [{ message: 'customers dot unavailable' }] }),
      }),
    );

    it('does not report to Sentry and shows no trial-ended alert', () => {
      expect(Sentry.captureException).not.toHaveBeenCalled();
      expect(findTrialEndedAlert().exists()).toBe(false);
    });
  });

  describe('when the empty-state groups fail to load', () => {
    beforeEach(() =>
      createComponent({
        groups: [],
        memberGroupsHandlerFn: jest.fn().mockRejectedValue(new Error('network down')),
      }),
    );

    it('shows one alert and reports the error', () => {
      expect(createAlert).toHaveBeenCalledTimes(1);
      expect(createAlert).toHaveBeenCalledWith({
        message: 'Failed to load groups.',
        error: expect.any(Error),
        captureError: true,
      });
    });
  });
});
