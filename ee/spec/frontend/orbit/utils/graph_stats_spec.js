import { fetchGraphStatus } from 'ee/orbit/api/orbit_api';
import { readCache, FIVE_MINUTES_MS } from 'ee/orbit/utils/orbit_cache';
import { fetchCombinedGraphStats, fetchGraphStats, GraphStats } from 'ee/orbit/utils/graph_stats';
import { buildOrbitGroup } from '../mock_data';

jest.mock('ee/orbit/api/orbit_api', () => ({
  fetchGraphStatus: jest.fn(),
}));

const frontend = buildOrbitGroup({ id: 1, name: 'frontend' });
const gitlabOrg = buildOrbitGroup({ id: 2, name: 'gitlab-org' });

describe('GraphStats', () => {
  beforeEach(() => {
    localStorage.clear();
    jest.spyOn(Date, 'now').mockReturnValue(1_000_000);
  });

  afterEach(() => {
    Date.now.mockRestore();
  });

  it('normalizes malformed graph status domains', () => {
    const stats = GraphStats.fromGraphStatus({
      projects: { indexed: '2', total_known: 3 },
      domains: [
        {
          name: 'core',
          items: [
            { name: 'Group', count: '4' },
            { name: null, count: 10 },
          ],
        },
        { name: 'plan', items: null },
        { name: null, items: [{ name: 'Issue', count: 1 }] },
      ],
    });

    expect(stats.getDomains()).toEqual([{ name: 'core', items: [{ name: 'Group', count: 4 }] }]);
    expect(stats.getProjects()).toEqual({ indexed: 2, totalKnown: 3 });
    expect(stats.getEntityCounts()).toEqual({ group: 4 });
    expect(stats.getDomainTotals()).toEqual({ core: 4 });
    expect(stats.getTotalIndexedNodes()).toBe(4);
  });

  it('fetches graph status through the five minute cache', async () => {
    fetchGraphStatus.mockResolvedValue({
      data: { domains: [{ name: 'core', items: [{ name: 'Project', count: 5 }] }] },
    });

    const first = await fetchGraphStats('gitlab-org');
    const second = await fetchGraphStats('gitlab-org');

    expect(first.getEntityCounts()).toEqual({ project: 5 });
    expect(second.getEntityCounts()).toEqual({ project: 5 });
    expect(fetchGraphStatus).toHaveBeenCalledTimes(1);
    expect(readCache('graph-status:gitlab-org')).toEqual({
      domains: [{ name: 'core', items: [{ name: 'Project', count: 5 }] }],
    });

    Date.now.mockReturnValue(1_000_000 + FIVE_MINUTES_MS + 1);
    await fetchGraphStats('gitlab-org');

    expect(fetchGraphStatus).toHaveBeenCalledTimes(2);
  });

  it('combines graph status counts across namespaces', async () => {
    fetchGraphStatus.mockImplementation((fullPath) => {
      if (fullPath === 'frontend') {
        return Promise.resolve({
          data: { domains: [{ name: 'core', items: [{ name: 'Project', count: 3 }] }] },
        });
      }

      return Promise.resolve({
        data: {
          domains: [
            {
              name: 'core',
              items: [
                { name: 'Project', count: 2 },
                { name: 'MergeRequest', count: 4 },
              ],
            },
          ],
        },
      });
    });

    const stats = await fetchCombinedGraphStats([frontend, gitlabOrg, frontend]);

    expect(fetchGraphStatus).toHaveBeenCalledTimes(2);
    expect(stats.getEntityCounts()).toEqual({ project: 5, mergerequest: 4 });
    expect(stats.getTotalIndexedNodes()).toBe(9);
  });

  describe('when the counts of the same groups load again', () => {
    beforeEach(async () => {
      fetchGraphStatus.mockResolvedValue({ data: {} });
      await fetchCombinedGraphStats([frontend, gitlabOrg]);
    });

    it('reads every group from the cache', async () => {
      await fetchCombinedGraphStats([frontend, gitlabOrg], { strict: true });

      expect(fetchGraphStatus).toHaveBeenCalledTimes(2);
    });

    describe('and one group indexes again', () => {
      beforeEach(() =>
        fetchCombinedGraphStats([
          frontend,
          buildOrbitGroup({ id: 2, name: 'gitlab-org', phase: 'SYNCING' }),
        ]),
      );

      it('fetches only that group', () => {
        expect(fetchGraphStatus).toHaveBeenCalledTimes(3);
        expect(fetchGraphStatus).toHaveBeenLastCalledWith('gitlab-org');
      });
    });
  });

  describe('when one of the requests fails', () => {
    beforeEach(() => {
      fetchGraphStatus.mockImplementation((fullPath) =>
        fullPath === 'frontend'
          ? Promise.reject(new Error('timeout'))
          : Promise.resolve({
              data: { domains: [{ name: 'core', items: [{ name: 'Project', count: 5 }] }] },
            }),
      );
    });

    describe('and strict is off', () => {
      it('returns the counts that loaded', async () => {
        const stats = await fetchCombinedGraphStats([frontend, gitlabOrg]);

        expect(stats.getEntityCounts()).toEqual({ project: 5 });
      });
    });

    describe('and strict is on', () => {
      it('rejects', async () => {
        await expect(
          fetchCombinedGraphStats([frontend, gitlabOrg], { strict: true }),
        ).rejects.toThrow('timeout');
      });
    });
  });
});
