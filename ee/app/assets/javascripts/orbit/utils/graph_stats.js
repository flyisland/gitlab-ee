import { fetchGraphStatus } from '../api/orbit_api';
import { withCache } from './orbit_cache';
import { indexingVersion } from './orbit_group_state';

const GRAPH_STATUS_CACHE_PREFIX = 'graph-status';

const normalizeCount = (value) => {
  const count = Number(value);
  return Number.isFinite(count) && count > 0 ? count : 0;
};

const normalizeName = (value) => (typeof value === 'string' ? value : '');

const normalizeItems = (items) =>
  (Array.isArray(items) ? items : [])
    .map((item = {}) => ({
      name: normalizeName(item.name),
      count: normalizeCount(item.count),
    }))
    .filter(({ name }) => name);

const normalizeDomains = (domains) =>
  (Array.isArray(domains) ? domains : [])
    .map((domain = {}) => ({
      name: normalizeName(domain.name),
      items: normalizeItems(domain.items),
    }))
    .filter(({ name, items }) => name && items.length);

const normalizeProjects = (projects = {}) => {
  const value = projects ?? {};

  return {
    indexed: normalizeCount(value.indexed),
    totalKnown: normalizeCount(value.total_known),
  };
};

const uniqueGroups = (groups = []) => [
  ...new Map(
    (Array.isArray(groups) ? groups : [])
      .filter((group) => typeof group?.fullPath === 'string' && group.fullPath.length > 0)
      .map((group) => [group.fullPath, group]),
  ).values(),
];

const graphStatusCacheKey = (fullPath) => `${GRAPH_STATUS_CACHE_PREFIX}:${fullPath}`;

export class GraphStats {
  constructor(response = {}) {
    const { domains = [], projects = {}, indexing = null } = response ?? {};

    this.domains = normalizeDomains(domains);
    this.projects = normalizeProjects(projects);
    this.indexing = indexing;
  }

  static fromGraphStatus(response = {}) {
    return new GraphStats(response);
  }

  static merge(stats = []) {
    const domainItems = new Map();
    const projects = { indexed: 0, total_known: 0 };

    stats.forEach((graphStats) => {
      graphStats.getDomains().forEach((domain) => {
        const items = domainItems.get(domain.name) ?? new Map();

        domain.items.forEach((item) => {
          const key = item.name.toLowerCase();
          const existing = items.get(key) ?? { name: item.name, count: 0 };
          items.set(key, { ...existing, count: existing.count + item.count });
        });

        domainItems.set(domain.name, items);
      });

      const graphProjects = graphStats.getProjects();
      projects.indexed += graphProjects.indexed;
      projects.total_known += graphProjects.totalKnown;
    });

    return new GraphStats({
      domains: [...domainItems.entries()].map(([name, items]) => ({
        name,
        items: [...items.values()],
      })),
      projects,
    });
  }

  getDomains() {
    return this.domains;
  }

  getProjects() {
    return this.projects;
  }

  getDomainTotals() {
    return Object.fromEntries(
      this.getDomains().map((domain) => [
        domain.name,
        domain.items.reduce((sum, item) => sum + item.count, 0),
      ]),
    );
  }

  getEntityCounts() {
    return this.getDomains()
      .flatMap((domain) => domain.items)
      .reduce((counts, item) => {
        const key = item.name.toLowerCase();
        return { ...counts, [key]: (counts[key] ?? 0) + item.count };
      }, {});
  }

  getTotalIndexedNodes() {
    return Object.values(this.getEntityCounts()).reduce((total, count) => total + count, 0);
  }
}

export async function fetchGraphStats(fullPath, cacheVersion = null) {
  if (typeof fullPath !== 'string' || fullPath.length === 0) {
    throw new TypeError('fullPath must be a non-empty string');
  }

  const data = await withCache(
    graphStatusCacheKey(fullPath),
    async () => {
      const response = await fetchGraphStatus(fullPath);
      return response.data ?? {};
    },
    { version: cacheVersion },
  );

  return GraphStats.fromGraphStatus(data);
}

// Orbit allows 10 graph_status calls per group per minute. Each group's cache entry follows
// only that group's indexing, so tab switches and other groups' progress reuse it.
export async function fetchCombinedGraphStats(groups, { strict = false } = {}) {
  const results = await Promise.allSettled(
    uniqueGroups(groups).map((group) => fetchGraphStats(group.fullPath, indexingVersion(group))),
  );
  const failed = results.find((result) => result.status === 'rejected');
  if (strict && failed) throw failed.reason;

  const stats = results
    .filter((result) => result.status === 'fulfilled')
    .map((result) => result.value);

  return GraphStats.merge(stats);
}
