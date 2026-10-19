import { RECENTLY_ENABLED_MS } from '../constants';

const PHASE_READY = 'READY';
const INDEXING_PHASES = ['NOT_STARTED', 'SYNCING'];

export const isOrbitReady = (group) => group.orbit?.indexingStatus?.phase === PHASE_READY;

// Orbit has no status for a group until the indexer picks it up (CDC lag). Past this window, stop polling.
export const isIndexingQueued = (group) => {
  if (group.orbit?.indexingStatus) return false;

  const enabledAt = group.orbit?.enabledAt;
  return !enabledAt || Date.now() - new Date(enabledAt).getTime() > RECENTLY_ENABLED_MS;
};

/**
 * No status (just enabled, or the Orbit service failed) and UNKNOWN are not indexing, so an
 * outage cannot keep the globe under the indexing overlay or the page polling.
 */
export const isIndexing = (group) => INDEXING_PHASES.includes(group.orbit?.indexingStatus?.phase);

// A throttled or failed Orbit call returns a null status. Keep the last known one, so the
// indexing overlay and the poll do not stop for good after one failed poll.
export const keepLastIndexingStatus = (groups, previousGroups) => {
  const previousStatuses = new Map(
    previousGroups.map((group) => [group.id, group.orbit?.indexingStatus]),
  );

  return groups.map((group) => {
    const previousStatus = previousStatuses.get(group.id);
    if (group.orbit?.indexingStatus || !previousStatus) return group;

    return { ...group, orbit: { ...group.orbit, indexingStatus: previousStatus } };
  });
};

export const indexingVersion = (group) => {
  const status = group.orbit?.indexingStatus;
  const areaPhases = (status?.domains ?? []).map(({ name, phase }) => `${name}=${phase}`);

  return [status?.phase, ...areaPhases].join(':');
};
