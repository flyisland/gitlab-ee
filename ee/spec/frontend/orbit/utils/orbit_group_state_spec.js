import { useFakeDate } from 'helpers/fake_date';
import {
  indexingVersion,
  isIndexing,
  isIndexingQueued,
  isOrbitReady,
  keepLastIndexingStatus,
} from 'ee/orbit/utils/orbit_group_state';
import { buildOrbitGroup } from '../mock_data';

describe('orbit_group_state', () => {
  describe('isOrbitReady', () => {
    describe('when the indexing phase is READY', () => {
      it('is ready', () => {
        expect(isOrbitReady({ orbit: { indexingStatus: { phase: 'READY' } } })).toBe(true);
      });
    });

    describe('when the indexing phase is anything else', () => {
      it('is not ready', () => {
        expect(isOrbitReady({ orbit: { indexingStatus: { phase: 'SYNCING' } } })).toBe(false);
      });
    });

    describe('when there is no status yet', () => {
      it('is not ready', () => {
        expect(isOrbitReady({ orbit: { indexingStatus: null } })).toBe(false);
      });
    });
  });

  describe('isIndexingQueued', () => {
    useFakeDate(2026, 9, 15, 12, 0, 0);

    describe('when Orbit has no status and the recently-enabled window has passed', () => {
      it('is queued', () => {
        expect(isIndexingQueued({ orbit: { enabledAt: '2026-10-15T11:40:00Z' } })).toBe(true);
      });
    });

    describe('when Orbit has no status but is still inside the window', () => {
      it('is not queued', () => {
        expect(isIndexingQueued({ orbit: { enabledAt: '2026-10-15T11:55:00Z' } })).toBe(false);
      });
    });

    describe('when the user has no Orbit access', () => {
      it('is queued', () => {
        expect(isIndexingQueued({ orbit: null })).toBe(true);
      });
    });

    describe('when Orbit already reports a status', () => {
      it('is not queued', () => {
        expect(
          isIndexingQueued({
            orbit: { enabledAt: '2026-10-15T11:40:00Z', indexingStatus: { phase: 'SYNCING' } },
          }),
        ).toBe(false);
      });
    });
  });

  describe('isIndexing', () => {
    it.each`
      scenario                       | group                                        | expected
      ${'indexing is ready'}         | ${buildOrbitGroup({ phase: 'READY' })}       | ${false}
      ${'indexing errored'}          | ${buildOrbitGroup({ phase: 'ERROR' })}       | ${false}
      ${'indexing is syncing'}       | ${buildOrbitGroup({ phase: 'SYNCING' })}     | ${true}
      ${'indexing not started'}      | ${buildOrbitGroup({ phase: 'NOT_STARTED' })} | ${true}
      ${'the phase is unknown'}      | ${buildOrbitGroup({ phase: 'UNKNOWN' })}     | ${false}
      ${'there is no status'}        | ${{ orbit: null }}                           | ${false}
      ${'the status failed to load'} | ${{ orbit: { indexingStatus: null } }}       | ${false}
    `('is $expected when $scenario', ({ group, expected }) => {
      expect(isIndexing(group)).toBe(expected);
    });
  });

  describe('keepLastIndexingStatus', () => {
    const syncing = buildOrbitGroup({ id: 1, phase: 'SYNCING' });
    const withoutStatus = { ...buildOrbitGroup({ id: 1 }), orbit: { indexingStatus: null } };

    describe('when a group comes back with no status', () => {
      it('keeps the status of the previous result', () => {
        expect(keepLastIndexingStatus([withoutStatus], [syncing])).toEqual([
          { ...withoutStatus, orbit: { indexingStatus: syncing.orbit.indexingStatus } },
        ]);
      });
    });

    describe('when a group comes back with a status', () => {
      it('uses the new status', () => {
        const ready = buildOrbitGroup({ id: 1, phase: 'READY' });

        expect(keepLastIndexingStatus([ready], [syncing])).toEqual([ready]);
      });
    });

    describe('when the group had no status before', () => {
      it('keeps the group with no status', () => {
        expect(keepLastIndexingStatus([withoutStatus], [])).toEqual([withoutStatus]);
      });
    });
  });

  describe('indexingVersion', () => {
    describe('when the group has a status with areas', () => {
      it('joins the phase and the area phases', () => {
        const group = buildOrbitGroup({
          phase: 'SYNCING',
          domains: [
            { name: 'core', phase: 'READY' },
            { name: 'ci', phase: 'SYNCING' },
          ],
        });

        expect(indexingVersion(group)).toBe('SYNCING:core=READY:ci=SYNCING');
      });
    });

    describe('when the group has no status', () => {
      it('is empty', () => {
        expect(indexingVersion({ orbit: { indexingStatus: null } })).toBe('');
      });
    });
  });
});
