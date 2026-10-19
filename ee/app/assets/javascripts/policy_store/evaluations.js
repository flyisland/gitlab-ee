export const WINDOW_DAYS = 7;

// The count documents cap the count at this and the server answers limit + 1
// past it: a group's evaluations are reached through its policies, one index
// scan per policy, so an exact count would grow with the group. The tile
// renders anything past the cap as "1,000+".
export const EVALUATIONS_COUNT_LIMIT = 1000;

/**
 * Start of the reporting window the evaluation stats cover.
 *
 * The window is WINDOW_DAYS calendar days in UTC, inclusive of today, so the
 * boundary is UTC midnight (WINDOW_DAYS - 1) days back and today counts as a
 * partial day.
 *
 * The boundary is pinned to UTC midnight rather than the current instant so
 * everyone reading the same organization on the same day sees the same number,
 * and so the value is a stable Apollo cache key instead of a fresh one on
 * every mount.
 *
 * @returns {String} ISO 8601 timestamp
 */
export const startOfReportingWindow = () => {
  const start = new Date();

  start.setUTCHours(0, 0, 0, 0);
  start.setUTCDate(start.getUTCDate() - (WINDOW_DAYS - 1));

  return start.toISOString();
};

/**
 * Reads the total from a `policyEvaluations` connection: the exact count up to
 * EVALUATIONS_COUNT_LIMIT, one past it beyond.
 *
 * A null connection is a viewer who cannot read the container's policies, or
 * a container whose policy store experiment is off. Neither is a zero, so it
 * reads as unknown and the caller renders a placeholder rather than a number
 * nobody verified.
 *
 * For a group the count covers only that group's own policies, never an
 * ancestor's, which matches the list the stat sits above.
 *
 * @param {Object|null} connection
 * @returns {Number|null}
 */
export const toEvaluationsCount = (connection) => connection?.count ?? null;
