import { RESOURCE_ACCESS_ERROR } from '~/graphql_shared/constants';
import {
  HTTP_STATUS_FORBIDDEN,
  HTTP_STATUS_NOT_FOUND,
  HTTP_STATUS_UNAUTHORIZED,
} from '~/lib/utils/http_status';
import { s__ } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { STATUS_UNKNOWN } from '../../constants';
import {
  ACTION_ERROR_KIND,
  ACTION_EXCLUDE,
  ACTION_INCLUDE,
  ACTION_LABELS,
  ACTION_TURN_OFF,
  ACTION_TURN_ON,
  ACTIVE_INDEXING_PHASES,
  CONFIRM_EXCLUDE,
  CONFIRM_TURN_OFF,
  INDEXING_PHASE,
  INDEXING_PHASE_LABELS,
} from './constants';

const REPORTED_ERROR_KINDS = [ACTION_ERROR_KIND.SERVER, ACTION_ERROR_KIND.NETWORK];
const NO_ACCESS_STATUSES = [HTTP_STATUS_UNAUTHORIZED, HTTP_STATUS_FORBIDDEN, HTTP_STATUS_NOT_FOUND];

const ACTION_APPLIES_TO = {
  // The hourly AutoIndexWorker turns off every excluded group, so Turn on needs the exclusion removed first.
  [ACTION_TURN_ON]: (group) => !group.isOn && !group.isExcluded,
  [ACTION_TURN_OFF]: (group) => group.isOn,
  [ACTION_EXCLUDE]: (group) => !group.isExcluded,
  [ACTION_INCLUDE]: (group) => group.isExcluded,
};

/**
 * Maps GraphQL groups to the rows of the admin groups table.
 * @param {Object} options
 * @param {Array} options.groups Group nodes from the admin groups query
 * @param {Set<string>} options.excludedPaths Full paths of the excluded groups
 * @param {Object} options.failures Last bulk action error for each full path
 */
export function buildGroupRows({ groups, excludedPaths, failures }) {
  return groups.map((group) => ({
    id: group.id,
    name: group.name,
    fullPath: group.fullPath,
    webPath: group.webPath,
    avatarUrl: group.avatarUrl,
    isOn: group.knowledgeGraphEnabled,
    isExcluded: excludedPaths.has(group.fullPath),
    phase: group.orbit?.indexingStatus?.phase ?? null,
    enabledAt: group.orbit?.enabledAt ?? null,
    failure: failures[group.fullPath] ?? null,
  }));
}

/** Returns the groups whose name or full path contains the search, ignoring case. */
export function filterGroupsBySearch(groups, search) {
  const term = search.toLowerCase();
  return groups.filter(
    (group) =>
      group.name.toLowerCase().includes(term) || group.fullPath.toLowerCase().includes(term),
  );
}

/** Returns the rows that an action changes, for example only the rows that are off for turn on. */
export function groupsForAction(groups, action) {
  return groups.filter(ACTION_APPLIES_TO[action]);
}

/** Returns the Actions menu items for the selected rows, with only the actions that change a row. */
export function actionItemsFor(groups) {
  return Object.keys(ACTION_APPLIES_TO)
    .filter((action) => groupsForAction(groups, action).length > 0)
    .map((action) => ({ value: action, text: ACTION_LABELS[action] }));
}

/** Returns the Index status text of a row. */
export function indexStatusLabel(group) {
  if (!group.isOn) return s__('Orbit|Not indexed');
  if (!group.phase) return s__('Orbit|Status not available');

  return INDEXING_PHASE_LABELS[group.phase] ?? INDEXING_PHASE_LABELS[INDEXING_PHASE.UNKNOWN];
}

/** True when a row is on and its index failed. */
export function hasIndexingError(group) {
  return group.isOn && group.phase === INDEXING_PHASE.ERROR;
}

/** Returns the note that the info icon of a row shows, or null when the row needs none. */
export function groupNote(group) {
  if (group.failure) return group.failure.message;
  if (hasIndexingError(group)) {
    return s__('Orbit|Orbit could not index this group. Check the Orbit indexer logs.');
  }
  if (!group.isOn) return null;
  if (group.phase === INDEXING_PHASE.UNKNOWN) {
    return s__('Orbit|Orbit has not reported a status for this group yet.');
  }
  if (group.isExcluded) {
    return s__('Orbit|This group is excluded, so Orbit turns off for it within an hour.');
  }

  return null;
}

/**
 * Returns the index status warning: the server message, or a generic message when a row that is on
 * has no status. Cached query results do not keep their GraphQL errors, so the rows are the fallback.
 */
export function indexStatusWarningFor(groups, serverMessage) {
  if (serverMessage) return serverMessage;
  if (groups.some((group) => group.isOn && !group.phase)) {
    return s__('Orbit|Orbit did not return the index status of some groups.');
  }

  return null;
}

/** True when at least one row is waiting for or running its index. */
export function hasActiveIndexing(groups) {
  return groups.some((group) => group.isOn && ACTIVE_INDEXING_PHASES.includes(group.phase));
}

/**
 * Maps an Apollo or axios error to an error kind and a message for the user.
 * 401, 403, 404, and the GraphQL resource access error mean no access, other 4xx show the server
 * message, and 5xx and network errors show a generic message.
 */
export function requestErrorFor(error) {
  const status = error.networkError?.statusCode ?? error.response?.status;
  const serverMessage = error.graphQLErrors?.[0]?.message ?? error.response?.data?.message;

  if (NO_ACCESS_STATUSES.includes(status) || serverMessage === RESOURCE_ACCESS_ERROR) {
    return {
      kind: ACTION_ERROR_KIND.NO_ACCESS,
      message: s__('Orbit|You do not have access to this. Check that admin mode is on.'),
    };
  }

  const isServerError = status >= 500;

  if (serverMessage && !isServerError) {
    return { kind: ACTION_ERROR_KIND.REJECTED, message: serverMessage };
  }

  if (!status && (error.networkError || error.request)) {
    return {
      kind: ACTION_ERROR_KIND.NETWORK,
      message: s__('Orbit|The request did not reach GitLab. Check your connection and try again.'),
    };
  }

  return {
    kind: ACTION_ERROR_KIND.SERVER,
    message: s__('Orbit|Something went wrong on the server. Try again.'),
  };
}

/** Maps an error like `requestErrorFor`, and reports server and network errors to Sentry. */
export function reportRequestError(error) {
  const failure = requestErrorFor(error);
  if (REPORTED_ERROR_KINDS.includes(failure.kind)) Sentry.captureException(error);
  return failure;
}

/** Reports the first server or network error of a bulk action to Sentry, once for the whole action. */
export function reportFirstRequestError(results) {
  const reported = results.find(({ failure }) => REPORTED_ERROR_KINDS.includes(failure?.kind));
  if (reported) Sentry.captureException(reported.error);
}

/** Returns the confirmation an action needs before it runs, or null when it runs at once. */
export function confirmKindFor(action, groups) {
  if (action === ACTION_TURN_OFF) return CONFIRM_TURN_OFF;
  if (action === ACTION_EXCLUDE && groups.some((group) => group.isOn)) return CONFIRM_EXCLUDE;

  return null;
}

/** Maps the Orbit status API response to the health card status. */
export function statusFromResponse(data) {
  const system = data.system ?? {};
  return {
    overall: system.status ?? STATUS_UNKNOWN,
    version: system.version ?? null,
    components: system.components ?? [],
  };
}

/** Returns the progress of a bulk action before any group is done. */
export function startBulkProgress(action, groups) {
  return {
    action,
    done: 0,
    total: groups.length,
    pendingPaths: groups.map((group) => group.fullPath),
  };
}

/** Returns the progress of a bulk action after one more group is done. */
export function completeBulkProgress(progress, fullPath) {
  return {
    ...progress,
    done: progress.done + 1,
    pendingPaths: progress.pendingPaths.filter((path) => path !== fullPath),
  };
}

/**
 * Summarizes the results of a bulk action.
 * @param {string} action The bulk action
 * @param {Array<{ group: Object, failure: Object|null }>} results One result for each group
 */
export function summarizeBulkAction(action, results) {
  const failed = results.filter(({ failure }) => failure);

  return {
    failures: Object.fromEntries(failed.map(({ group, failure }) => [group.fullPath, failure])),
    failedPaths: failed.map(({ group }) => group.fullPath),
    result: {
      action,
      total: results.length,
      failed: failed.map(({ group, failure }) => ({
        name: group.name,
        fullPath: group.fullPath,
        message: failure.message,
      })),
    },
  };
}

/** Runs `task` for each item with at most `limit` tasks at a time, and returns the results in order. */
export async function mapWithConcurrency(items, limit, task) {
  const results = [];
  let nextIndex = 0;

  const runNext = async () => {
    if (nextIndex >= items.length) return;

    const index = nextIndex;
    nextIndex += 1;
    results[index] = await task(items[index]);
    await runNext();
  };

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, runNext));
  return results;
}
