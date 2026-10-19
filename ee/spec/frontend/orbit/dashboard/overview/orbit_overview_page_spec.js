import { nextTick, ref } from 'vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import OrbitOverviewPage from 'ee/orbit/dashboard/overview/orbit_overview_page.vue';
import OverviewStatsCard from 'ee/orbit/dashboard/overview/overview_stats_card.vue';
import GraphExplorer from 'ee/orbit/components/graph_explorer.vue';
import { fetchOrbitSchema } from 'ee/orbit/api/orbit_api';
import { fetchCombinedGraphStats } from 'ee/orbit/utils/graph_stats';
import { buildOrbitGroup } from '../../mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');
jest.mock('ee/orbit/api/orbit_api');
jest.mock('ee/orbit/utils/graph_stats');

const buildStats = (total = 0, entityCounts = {}) => ({
  getTotalIndexedNodes: () => total,
  getEntityCounts: () => entityCounts,
  getDomains: () => [],
  getDomainTotals: () => ({}),
  getProjects: () => ({ indexed: 0 }),
});

const SCHEMA = { nodes: [{ name: 'Project' }] };

describe('OrbitOverviewPage', () => {
  let wrapper;
  let providedGroups;

  const mountComponent = ({
    enabledGroups = [buildOrbitGroup()],
    route = { query: {} },
    defaultGroupMissing = false,
    enabledGroupsCount = enabledGroups.length,
  } = {}) => {
    providedGroups = ref(enabledGroups);
    wrapper = shallowMountExtended(OrbitOverviewPage, {
      provide: {
        defaultGroupMissing,
        enabledMemberGroups: providedGroups,
        enabledGroupsCount: ref(enabledGroupsCount),
      },
      mocks: { $route: route },
    });
  };

  const createComponent = async (options) => {
    mountComponent(options);
    await waitForPromises();
  };

  const pollGroups = async (groups) => {
    providedGroups.value = groups;
    await waitForPromises();
  };

  const findStatsCard = () => wrapper.findComponent(OverviewStatsCard);
  const findExplorer = () => wrapper.findComponent(GraphExplorer);
  const findOverlay = () => wrapper.findByTestId('overview-indexing-overlay');
  const findStatusLine = () => wrapper.findByTestId('overview-status-line');

  let readyStats;

  beforeEach(() => {
    readyStats = buildStats();
    fetchOrbitSchema.mockResolvedValue({ data: SCHEMA });
    fetchCombinedGraphStats.mockResolvedValue(readyStats);
  });

  describe('when every group is ready', () => {
    beforeEach(() => createComponent());

    it('shows the stats card and no overlay', () => {
      expect(findStatsCard().exists()).toBe(true);
      expect(findStatsCard().props('groupCount')).toBe(1);
      expect(findOverlay().exists()).toBe(false);
    });

    it('lets the globe load the group neighbors', () => {
      expect(findExplorer().props('expandNeighbors')).toBe(true);
    });

    it('reads the expanded schema and hands it to the globe', () => {
      expect(fetchOrbitSchema).toHaveBeenCalledWith({ expand: '*' });
      expect(findExplorer().props('schema')).toBe(SCHEMA);
    });

    it('asks the globe for no instance map', () => {
      expect(findExplorer().props('instanceMapRequest')).toBe(null);
    });

    it('reads the combined stats of the groups', () => {
      expect(fetchCombinedGraphStats).toHaveBeenCalledWith(providedGroups.value, { strict: true });
    });

    it('hands the ready stats to the card', () => {
      expect(findStatsCard().props('status')).toBe('ready');
      expect(findStatsCard().props('graphStats')).toBe(readyStats);
    });
  });

  // Orbit queries return 422 until the user picks a default group.
  describe('when the default group is missing', () => {
    beforeEach(() => createComponent({ defaultGroupMissing: true }));

    it('does not let the globe load the group neighbors', () => {
      expect(findExplorer().props('expandNeighbors')).toBe(false);
    });
  });

  describe('when some groups are ready and one indexes', () => {
    beforeEach(() =>
      createComponent({
        enabledGroups: [buildOrbitGroup({ id: 1 }), buildOrbitGroup({ id: 2, phase: 'SYNCING' })],
      }),
    );

    it('shows the overlay and hides the stats card', () => {
      expect(findOverlay().exists()).toBe(true);
      expect(findStatsCard().exists()).toBe(false);
    });
  });

  describe('when a group failed and the others are ready', () => {
    beforeEach(() =>
      createComponent({
        enabledGroups: [buildOrbitGroup({ id: 1 }), buildOrbitGroup({ id: 2, phase: 'ERROR' })],
      }),
    );

    it('shows the stats card and no overlay', () => {
      expect(findStatsCard().exists()).toBe(true);
      expect(findOverlay().exists()).toBe(false);
    });
  });

  describe("when a group's indexing status failed to load", () => {
    // Orbit down or rate limited: the node arrives with no status.
    beforeEach(() =>
      createComponent({
        enabledGroups: [{ ...buildOrbitGroup(), orbit: { indexingStatus: null } }],
      }),
    );

    it('shows the stats card and no overlay', () => {
      expect(findStatsCard().exists()).toBe(true);
      expect(findOverlay().exists()).toBe(false);
    });
  });

  describe('when the stats request fails', () => {
    beforeEach(() => {
      fetchCombinedGraphStats.mockRejectedValue(new Error('timeout'));
      return createComponent();
    });

    it('marks the stats as failed and reports the error', () => {
      expect(findStatsCard().props('status')).toBe('failed');
      expect(findStatsCard().props('graphStats')).toBe(null);
      expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error));
    });
  });

  describe('when the stats request is forbidden', () => {
    beforeEach(() => {
      fetchCombinedGraphStats.mockRejectedValue({ response: { status: 403, data: {} } });
      return createComponent();
    });

    it('marks the stats as forbidden and does not report to Sentry', () => {
      expect(findStatsCard().props('status')).toBe('forbidden');
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });

  describe('while a group indexes', () => {
    beforeEach(() => createComponent({ enabledGroups: [buildOrbitGroup({ phase: 'SYNCING' })] }));

    it('shows the overlay and hides the stats card', () => {
      expect(findOverlay().text()).toContain(
        'Indexing in progress. The map fills in as data finishes indexing.',
      );
      expect(findStatsCard().exists()).toBe(false);
    });

    it('does not load the stats', () => {
      expect(fetchCombinedGraphStats).not.toHaveBeenCalled();
    });

    describe('and the progress changes while a group indexes', () => {
      beforeEach(async () => {
        await pollGroups([
          buildOrbitGroup({ phase: 'SYNCING', domains: [{ name: 'core', phase: 'READY' }] }),
        ]);
      });

      it('does not load the stats', () => {
        expect(fetchCombinedGraphStats).not.toHaveBeenCalled();
      });
    });

    describe('and the last group turns ready', () => {
      beforeEach(async () => {
        await pollGroups([buildOrbitGroup({ phase: 'READY' })]);
      });

      it('loads the stats one time and bumps the globe neighbors version', () => {
        expect(fetchCombinedGraphStats).toHaveBeenCalledTimes(1);
        expect(findExplorer().props('neighborsVersion')).toBe('gl-demo:READY');
      });
    });
  });

  describe('when a poll returns new group objects with no change', () => {
    let nodesBefore;

    beforeEach(async () => {
      await createComponent();
      nodesBefore = findExplorer().props('initialNodes');

      await pollGroups([buildOrbitGroup()]);
    });

    it('does not reload the stats and keeps the globe nodes', () => {
      expect(fetchCombinedGraphStats).toHaveBeenCalledTimes(1);
      expect(findExplorer().props('initialNodes')).toBe(nodesBefore);
    });
  });

  describe('when the route asks for the instances of an entity', () => {
    beforeEach(() => createComponent({ route: { query: { entity: 'Project' } } }));

    it('passes the instance map request to the globe', () => {
      expect(findExplorer().props('instanceMapRequest')).toEqual({ entityType: 'Project' });
    });
  });

  describe('when the route repeats the entity', () => {
    beforeEach(() => createComponent({ route: { query: { entity: ['Project', 'User'] } } }));

    it('maps the first entity', () => {
      expect(findExplorer().props('instanceMapRequest')).toEqual({ entityType: 'Project' });
    });
  });

  describe('when the schema request fails', () => {
    beforeEach(() => {
      fetchOrbitSchema.mockRejectedValue(new Error('no schema'));
      return createComponent();
    });

    it('reports the error and renders the globe', () => {
      expect(Sentry.captureException).toHaveBeenCalledWith(expect.any(Error));
      expect(findExplorer().exists()).toBe(true);
    });
  });

  describe('when the schema request answers 4xx', () => {
    beforeEach(() => {
      fetchOrbitSchema.mockRejectedValue({ response: { status: 429, data: {} } });
      return createComponent();
    });

    it('does not report to Sentry', () => {
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });

  describe('status line', () => {
    const showNodeCounts = async (counts) => {
      findExplorer().vm.$emit('node-counts-change', counts);
      await waitForPromises();
    };

    describe('when every group is ready', () => {
      beforeEach(async () => {
        fetchCombinedGraphStats.mockResolvedValue(buildStats(48213));
        await createComponent();
        await showNodeCounts({ project: 1000 });
      });

      it('shows the total', () => {
        expect(findStatusLine().text()).toBe(
          'Showing 1,000 of 48,213 items. Drag to rotate the globe.',
        );
      });
    });

    describe('while a group indexes', () => {
      beforeEach(async () => {
        fetchCombinedGraphStats.mockResolvedValue(buildStats(48213));
        await createComponent({ enabledGroups: [buildOrbitGroup({ phase: 'SYNCING' })] });
        await showNodeCounts({ project: 1840 });
      });

      it('omits the total', () => {
        expect(findStatusLine().text()).toBe('Showing 1,840 items. Drag to rotate the globe.');
      });
    });

    describe('when the globe shows the instances of one entity', () => {
      beforeEach(async () => {
        fetchCombinedGraphStats.mockResolvedValue(buildStats(48213, { project: 2140 }));
        await createComponent({ route: { query: { entity: 'Project' } } });
        await showNodeCounts({ project: 50 });
      });

      it('shows the total of that entity', () => {
        expect(findStatusLine().text()).toBe(
          'Showing 50 of 2,140 Project items. Drag to rotate the globe.',
        );
      });
    });

    describe('when the user has more groups with Orbit on than the page loads', () => {
      beforeEach(async () => {
        fetchCombinedGraphStats.mockResolvedValue(buildStats(48213));
        await createComponent({ enabledGroupsCount: 161 });
        await showNodeCounts({ project: 1000 });
      });

      it('says that only the first groups are shown', () => {
        expect(findStatusLine().text()).toBe(
          'Showing 1,000 of 48,213 items. Drag to rotate the globe. Only the first 1 of 161 groups are shown.',
        );
      });
    });

    describe('when the browser cannot show the map', () => {
      beforeEach(async () => {
        await createComponent();
        findExplorer().vm.$emit('map-unavailable');
        await nextTick();
      });

      it('hides the status line', () => {
        expect(findStatusLine().exists()).toBe(false);
      });
    });

    describe('when the counts did not load and the globe shows one item', () => {
      beforeEach(async () => {
        fetchCombinedGraphStats.mockRejectedValue(new Error('timeout'));
        await createComponent();
        await showNodeCounts({ project: 1 });
      });

      it('uses the singular form', () => {
        expect(findStatusLine().text()).toBe('Showing 1 item. Drag to rotate the globe.');
      });
    });
  });

  describe('when a newer stats load starts before an older one ends', () => {
    const OLDER_STATS = buildStats(1);
    const NEWER_STATS = buildStats(9);
    let resolveOlder;
    let resolveNewer;

    beforeEach(async () => {
      fetchCombinedGraphStats
        .mockReturnValueOnce(
          new Promise((resolve) => {
            resolveOlder = resolve;
          }),
        )
        .mockReturnValueOnce(
          new Promise((resolve) => {
            resolveNewer = resolve;
          }),
        );
      mountComponent({ enabledGroups: [buildOrbitGroup({ phase: 'READY' })] });
      providedGroups.value = [buildOrbitGroup({ phase: 'ERROR' })];
      await nextTick();

      resolveNewer(NEWER_STATS);
      await waitForPromises();
    });

    it('shows the counts of the newer load', () => {
      expect(findStatsCard().props('graphStats')).toBe(NEWER_STATS);
    });

    describe('and the older load ends late', () => {
      beforeEach(async () => {
        resolveOlder(OLDER_STATS);
        await waitForPromises();
      });

      it('keeps the counts of the newer load', () => {
        expect(findStatsCard().props('graphStats')).toBe(NEWER_STATS);
      });
    });
  });
});
