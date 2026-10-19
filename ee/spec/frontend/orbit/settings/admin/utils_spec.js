import { RESOURCE_ACCESS_ERROR } from '~/graphql_shared/constants';
import {
  actionItemsFor,
  buildGroupRows,
  completeBulkProgress,
  confirmKindFor,
  filterGroupsBySearch,
  groupNote,
  groupsForAction,
  hasActiveIndexing,
  hasIndexingError,
  indexStatusLabel,
  indexStatusWarningFor,
  mapWithConcurrency,
  reportFirstRequestError,
  reportRequestError,
  requestErrorFor,
  startBulkProgress,
  statusFromResponse,
  summarizeBulkAction,
} from 'ee/orbit/settings/admin/utils';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { ENABLED_AT, buildGroup, buildOnGroup, buildRow } from './mock_data';

jest.mock('~/sentry/sentry_browser_wrapper');

describe('Orbit admin settings utils', () => {
  describe('buildGroupRows', () => {
    it('maps groups to rows with their exclusion, indexing phase, and failure', () => {
      const failure = { kind: 'rejected', message: 'Not allowed' };

      const rows = buildGroupRows({
        groups: [buildOnGroup('acme', 'SYNCING'), buildGroup({ name: 'beta' })],
        excludedPaths: new Set(['beta']),
        failures: { beta: failure },
      });

      expect(rows).toEqual([
        buildRow({ name: 'acme', isOn: true, phase: 'SYNCING', enabledAt: ENABLED_AT }),
        buildRow({ name: 'beta', isExcluded: true, failure }),
      ]);
    });
  });

  describe('groupsForAction', () => {
    const on = buildRow({ name: 'on', isOn: true });
    const off = buildRow({ name: 'off' });
    const excluded = buildRow({ name: 'excluded', isExcluded: true });

    it.each`
      action       | expected
      ${'turnOn'}  | ${[off]}
      ${'turnOff'} | ${[on]}
      ${'exclude'} | ${[on, off]}
      ${'include'} | ${[excluded]}
    `('returns the rows that $action changes', ({ action, expected }) => {
      expect(groupsForAction([on, off, excluded], action)).toEqual(expected);
    });
  });

  describe('actionItemsFor', () => {
    it('lists only the actions that change a selected row', () => {
      expect(actionItemsFor([buildRow({ isOn: true, isExcluded: true })])).toEqual([
        { value: 'turnOff', text: 'Turn off Orbit' },
        { value: 'include', text: 'Remove exclusion' },
      ]);
    });

    it('lists no action for an empty selection', () => {
      expect(actionItemsFor([])).toEqual([]);
    });
  });

  describe('indexStatusLabel', () => {
    it.each`
      row                                           | label
      ${buildRow()}                                 | ${'Not indexed'}
      ${buildRow({ isOn: true })}                   | ${'Status not available'}
      ${buildRow({ isOn: true, phase: 'READY' })}   | ${'Indexed'}
      ${buildRow({ isOn: true, phase: 'SYNCING' })} | ${'Indexing'}
      ${buildRow({ isOn: true, phase: 'NEW' })}     | ${'Status unknown'}
    `('returns "$label" for phase $row.phase', ({ row, label }) => {
      expect(indexStatusLabel(row)).toBe(label);
    });
  });

  describe('groupNote', () => {
    it.each`
      description                       | row                                                           | note
      ${'a failed action'}              | ${buildRow({ failure: { message: 'Not allowed' } })}          | ${'Not allowed'}
      ${'a failed index'}               | ${buildRow({ isOn: true, phase: 'ERROR' })}                   | ${'Orbit could not index this group. Check the Orbit indexer logs.'}
      ${'an unknown phase'}             | ${buildRow({ isOn: true, phase: 'UNKNOWN' })}                 | ${'Orbit has not reported a status for this group yet.'}
      ${'an excluded group that is on'} | ${buildRow({ isOn: true, phase: 'READY', isExcluded: true })} | ${'This group is excluded, so Orbit turns off for it within an hour.'}
      ${'an indexed group'}             | ${buildRow({ isOn: true, phase: 'READY' })}                   | ${null}
      ${'a group that is off'}          | ${buildRow({ isExcluded: true })}                             | ${null}
    `('returns the note for $description', ({ row, note }) => {
      expect(groupNote(row)).toBe(note);
    });
  });

  describe('confirmKindFor', () => {
    const on = buildRow({ name: 'on', isOn: true });
    const off = buildRow({ name: 'off' });

    it.each`
      action       | groups       | expected
      ${'turnOff'} | ${[on]}      | ${'turnOff'}
      ${'exclude'} | ${[off, on]} | ${'exclude'}
      ${'exclude'} | ${[off]}     | ${null}
      ${'turnOn'}  | ${[off]}     | ${null}
      ${'include'} | ${[on]}      | ${null}
    `('returns $expected for $action', ({ action, groups, expected }) => {
      expect(confirmKindFor(action, groups)).toBe(expected);
    });
  });

  describe('hasIndexingError', () => {
    it.each`
      row                                          | expected
      ${buildRow({ isOn: true, phase: 'ERROR' })}  | ${true}
      ${buildRow({ isOn: true, phase: 'READY' })}  | ${false}
      ${buildRow({ isOn: false, phase: 'ERROR' })} | ${false}
    `('returns $expected for on=$row.isOn and phase $row.phase', ({ row, expected }) => {
      expect(hasIndexingError(row)).toBe(expected);
    });
  });

  describe('hasActiveIndexing', () => {
    it.each`
      phase            | expected
      ${'NOT_STARTED'} | ${true}
      ${'SYNCING'}     | ${true}
      ${'READY'}       | ${false}
      ${'ERROR'}       | ${false}
    `('returns $expected for a row in phase $phase', ({ phase, expected }) => {
      expect(hasActiveIndexing([buildRow({ isOn: true, phase })])).toBe(expected);
    });
  });

  describe('filterGroupsBySearch', () => {
    const groups = [
      buildGroup({ name: 'Acme', fullPath: 'acme-platform' }),
      buildGroup({ name: 'Beta', fullPath: 'beta' }),
    ];

    it.each`
      search        | expected
      ${'acm'}      | ${['Acme']}
      ${'PLATFORM'} | ${['Acme']}
      ${''}         | ${['Acme', 'Beta']}
    `('returns $expected for the search "$search"', ({ search, expected }) => {
      expect(filterGroupsBySearch(groups, search).map(({ name }) => name)).toEqual(expected);
    });
  });

  describe('indexStatusWarningFor', () => {
    it('returns the server message', () => {
      expect(indexStatusWarningFor([], 'Knowledge graph request failed')).toBe(
        'Knowledge graph request failed',
      );
    });

    describe('with no server message', () => {
      it.each`
        description                                     | rows                                                                     | expected
        ${'a row that is on and has no status'}         | ${[buildRow({ isOn: true, phase: null })]}                               | ${'Orbit did not return the index status of some groups.'}
        ${'rows that are on with a status, or are off'} | ${[buildRow({ isOn: true, phase: 'READY' }), buildRow({ isOn: false })]} | ${null}
      `('returns $expected for $description', ({ rows, expected }) => {
        expect(indexStatusWarningFor(rows, null)).toBe(expected);
      });
    });
  });

  describe('mapWithConcurrency', () => {
    it('runs at most the limit of tasks at a time and keeps the order of the results', async () => {
      let running = 0;
      let mostRunning = 0;
      const task = async (item) => {
        running += 1;
        mostRunning = Math.max(mostRunning, running);
        await Promise.resolve();
        running -= 1;
        return item * 2;
      };

      expect(await mapWithConcurrency([1, 2, 3, 4, 5, 6, 7], 3, task)).toEqual([
        2, 4, 6, 8, 10, 12, 14,
      ]);
      expect(mostRunning).toBe(3);
    });
  });

  describe('statusFromResponse', () => {
    it('maps the system status', () => {
      const components = [{ name: 'indexer', status: 'healthy' }];

      expect(
        statusFromResponse({ system: { status: 'degraded', version: '1.0', components } }),
      ).toEqual({ overall: 'degraded', version: '1.0', components });
    });

    it('returns an unknown status for a response with no system', () => {
      expect(statusFromResponse({ system: null })).toEqual({
        overall: 'unknown',
        version: null,
        components: [],
      });
    });
  });

  describe('bulk progress', () => {
    const groups = [buildRow({ name: 'acme' }), buildRow({ name: 'beta' })];

    it('starts with every group pending', () => {
      expect(startBulkProgress('turnOn', groups)).toEqual({
        action: 'turnOn',
        done: 0,
        total: 2,
        pendingPaths: ['acme', 'beta'],
      });
    });

    it('counts a done group and removes it from the pending paths', () => {
      expect(completeBulkProgress(startBulkProgress('turnOn', groups), 'acme')).toMatchObject({
        done: 1,
        pendingPaths: ['beta'],
      });
    });
  });

  describe('summarizeBulkAction', () => {
    it('collects the failures by path and lists them in the result', () => {
      const failure = { kind: 'rejected', message: 'Not allowed' };
      const results = [
        { group: buildRow({ name: 'acme' }), failure: null },
        { group: buildRow({ name: 'beta' }), failure },
      ];

      expect(summarizeBulkAction('turnOn', results)).toEqual({
        failures: { beta: failure },
        failedPaths: ['beta'],
        result: {
          action: 'turnOn',
          total: 2,
          failed: [{ name: 'beta', fullPath: 'beta', message: 'Not allowed' }],
        },
      });
    });
  });

  describe('reportRequestError', () => {
    it('reports a server error to Sentry', () => {
      const error = { networkError: { statusCode: 500 } };

      expect(reportRequestError(error).kind).toBe('server');
      expect(Sentry.captureException).toHaveBeenCalledWith(error);
    });

    it('does not report a rejected request', () => {
      expect(reportRequestError({ graphQLErrors: [{ message: 'Nope' }] }).kind).toBe('rejected');
      expect(Sentry.captureException).not.toHaveBeenCalled();
    });
  });

  describe('reportFirstRequestError', () => {
    describe('when requests fail with server and network errors', () => {
      const serverError = new Error('Server error');

      beforeEach(() => {
        reportFirstRequestError([
          { failure: null },
          { failure: { kind: 'rejected', message: 'Not allowed' } },
          { failure: { kind: 'server' }, error: serverError },
          { failure: { kind: 'network' }, error: new Error('Network error') },
        ]);
      });

      it('reports only the first of these errors to Sentry', () => {
        expect(Sentry.captureException).toHaveBeenCalledTimes(1);
        expect(Sentry.captureException).toHaveBeenCalledWith(serverError);
      });
    });

    describe('when no request fails', () => {
      beforeEach(() => {
        reportFirstRequestError([{ failure: null }, { failure: { kind: 'noAccess' } }]);
      });

      it('reports nothing to Sentry', () => {
        expect(Sentry.captureException).not.toHaveBeenCalled();
      });
    });
  });

  describe('requestErrorFor', () => {
    const noAccess = {
      kind: 'noAccess',
      message: 'You do not have access to this. Check that admin mode is on.',
    };
    const network = {
      kind: 'network',
      message: 'The request did not reach GitLab. Check your connection and try again.',
    };
    const server = { kind: 'server', message: 'Something went wrong on the server. Try again.' };

    it.each`
      description                            | error                                                                          | expected
      ${'a GraphQL 403'}                     | ${{ networkError: { statusCode: 403 } }}                                       | ${noAccess}
      ${'an axios 401'}                      | ${{ response: { status: 401, data: { message: 'Admin mode is inactive.' } } }} | ${noAccess}
      ${'the GraphQL access error'}          | ${{ graphQLErrors: [{ message: RESOURCE_ACCESS_ERROR }] }}                     | ${noAccess}
      ${'an axios 404'}                      | ${{ response: { status: 404, data: {} } }}                                     | ${noAccess}
      ${'a GraphQL error'}                   | ${{ graphQLErrors: [{ message: 'Group not found' }] }}                         | ${{ kind: 'rejected', message: 'Group not found' }}
      ${'an axios 422 with a message'}       | ${{ response: { status: 422, data: { message: 'Bad value' } } }}               | ${{ kind: 'rejected', message: 'Bad value' }}
      ${'a GraphQL network error'}           | ${{ networkError: new Error('Failed to fetch') }}                              | ${network}
      ${'an axios request with no response'} | ${{ request: {} }}                                                             | ${network}
      ${'a GraphQL 500'}                     | ${{ networkError: { statusCode: 500 } }}                                       | ${server}
      ${'an axios 500 with a message'}       | ${{ response: { status: 500, data: { message: 'Boom' } } }}                    | ${server}
    `('maps $description', ({ error, expected }) => {
      expect(requestErrorFor(error)).toEqual(expected);
    });
  });
});
