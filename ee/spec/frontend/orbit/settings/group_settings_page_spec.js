import Vue, { nextTick } from 'vue';
import VueApollo from 'vue-apollo';
import { GlSkeletonLoader, GlToggle } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useFakeDate } from 'helpers/fake_date';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { createAlert } from '~/alert';
import groupSettingsQuery from 'ee/orbit/graphql/queries/group_settings.query.graphql';
import orbitStartTrialMutation from 'ee/orbit/graphql/mutations/orbit_start_trial.mutation.graphql';
import orbitUpdateMutation from 'ee/orbit/graphql/mutations/orbit_update.mutation.graphql';
import GroupSettingsPage from 'ee/orbit/settings/group_settings_page.vue';
import GroupSettingsAlert from 'ee/orbit/settings/group_settings_alert.vue';
import StartTrialModal from 'ee/orbit/components/trial/start_trial_modal.vue';

jest.mock('~/alert');

Vue.use(VueApollo);

describe('OrbitGroupSettingsPage', () => {
  let wrapper;
  let queryHandler;
  let startTrialHandler;
  let updateHandler;

  const access = (state, reason = null) => ({ __typename: 'OrbitAccess', state, reason });

  const buildGroup = (overrides = {}) => ({
    id: 'gid://gitlab/Group/1',
    name: 'Acme',
    fullPath: 'acme',
    knowledgeGraphEnabled: false,
    orbitAccess: access('TRIAL_ELIGIBLE'),
    orbit: { __typename: 'OrbitNamespace', enabledAt: null, indexingStatus: null },
    __typename: 'Group',
    ...overrides,
  });

  const createComponent = ({ group = {}, props = {}, queryResponse } = {}) => {
    queryHandler = jest
      .fn()
      .mockResolvedValue(queryResponse ?? { data: { group: buildGroup(group) } });
    startTrialHandler = jest.fn().mockResolvedValue({
      data: { orbitStartTrial: { __typename: 'OrbitStartTrialPayload', errors: [] } },
    });
    updateHandler = jest.fn().mockResolvedValue({
      data: {
        orbitUpdate: {
          __typename: 'OrbitUpdatePayload',
          group: { ...buildGroup(group), __typename: 'Group' },
          errors: [],
        },
      },
    });

    wrapper = shallowMountExtended(GroupSettingsPage, {
      apolloProvider: createMockApollo([
        [groupSettingsQuery, queryHandler],
        [orbitStartTrialMutation, startTrialHandler],
        [orbitUpdateMutation, updateHandler],
      ]),
      propsData: {
        groupFullPath: 'acme',
        saas: true,
        duoAvailable: true,
        orbitPath: '/-/dashboard/orbit',
        usageQuotasPath: '/acme/-/usage_quotas',
        duoSettingsPath: '/acme/-/settings/gitlab_duo',
        ...props,
      },
    });
  };

  const findSkeleton = () => wrapper.findComponent(GlSkeletonLoader);
  const findToggle = () => wrapper.findComponent(GlToggle);
  const findTrialBanner = () => wrapper.findByTestId('orbit-trial-banner');
  const findGroupAlert = () => wrapper.findComponent(GroupSettingsAlert);
  const findStartTrialModal = () => wrapper.findComponent(StartTrialModal);
  const findActionError = () => wrapper.findByTestId('orbit-action-error');
  const findStatusAlert = () => wrapper.findComponentByTestId('orbit-status-alert');
  const findDuoAlert = () => wrapper.findByTestId('orbit-duo-alert');

  describe('while loading', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows a skeleton and no content', () => {
      expect(findSkeleton().exists()).toBe(true);
      expect(findToggle().exists()).toBe(false);
    });
  });

  describe('when the group cannot load', () => {
    beforeEach(async () => {
      createComponent({
        queryResponse: { data: { group: null }, errors: [{ message: 'Internal server error' }] },
      });
      await waitForPromises();
    });

    it('shows the load error and keeps the skeleton', () => {
      expect(createAlert).toHaveBeenCalledWith(
        expect.objectContaining({ message: 'Failed to load group. Please try again.' }),
      );
      expect(findSkeleton().exists()).toBe(true);
    });
  });

  describe('when only the Orbit status cannot load', () => {
    beforeEach(async () => {
      createComponent({
        queryResponse: {
          data: {
            group: buildGroup({
              knowledgeGraphEnabled: true,
              orbitAccess: access('LICENSED'),
              orbit: {
                __typename: 'OrbitNamespace',
                enabledAt: '2026-10-15T11:59:00Z',
                indexingStatus: null,
              },
            }),
          },
          errors: [
            {
              message: 'Knowledge graph request failed',
              path: ['group', 'orbit', 'indexingStatus'],
            },
          ],
        },
      });
      await waitForPromises();
    });

    it('shows the toggle and no load error', () => {
      expect(createAlert).not.toHaveBeenCalled();
      expect(findToggle().props('value')).toBe(true);
    });

    it('says the status is not available', () => {
      expect(findStatusAlert().props('title')).toBe(
        'Orbit status is not available. Try again later.',
      );
    });
  });

  describe('when the trial flow is off', () => {
    describe('and the group is licensed', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            orbitAccess: access('LICENSED'),
          },
        });
        await waitForPromises();
      });

      it('shows the toggle and no trial UI', () => {
        expect(findToggle().exists()).toBe(true);
        expect(findGroupAlert().exists()).toBe(false);
        expect(findTrialBanner().exists()).toBe(false);
      });
    });
  });

  describe.each`
    scenario                         | accessState         | reason          | alert
    ${'the group is on Free'}        | ${'UNLICENSED'}     | ${'FREE_PLAN'}  | ${'free_plan'}
    ${'the instance has no license'} | ${'UNLICENSED'}     | ${'NO_LICENSE'} | ${'unlicensed'}
    ${'the group lost access'}       | ${'UNLICENSED'}     | ${'NO_ACCESS'}  | ${'unlicensed'}
    ${'Orbit is not set up'}         | ${'NOT_CONFIGURED'} | ${null}         | ${'unlicensed'}
  `('when $scenario', ({ accessState, reason, alert }) => {
    beforeEach(async () => {
      createComponent({ group: { orbitAccess: access(accessState, reason) } });
      await waitForPromises();
    });

    it(`shows the ${alert} alert and no toggle`, () => {
      expect(findGroupAlert().props('state')).toBe(alert);
      expect(findToggle().exists()).toBe(false);
    });
  });

  describe('when the trial flow is on', () => {
    describe.each`
      scenario                          | accessState                   | reason                 | state
      ${'CustomersDot does not answer'} | ${'TRIAL_STATUS_UNAVAILABLE'} | ${null}                | ${'cdot_unavailable'}
      ${'the group is not eligible'}    | ${'TRIAL_NOT_ELIGIBLE'}       | ${null}                | ${'not_eligible'}
      ${'the trial ran out of time'}    | ${'TRIAL_ENDED'}              | ${'TRIAL_EXPIRED'}     | ${'trial_ended'}
      ${'the trial ran out of credits'} | ${'TRIAL_ENDED'}              | ${'CREDITS_EXHAUSTED'} | ${'credits_used_up'}
    `('when $scenario', ({ accessState, reason, state }) => {
      beforeEach(async () => {
        createComponent({ group: { orbitAccess: access(accessState, reason) } });
        await waitForPromises();
      });

      it(`shows the ${state} alert`, () => {
        expect(findGroupAlert().props('state')).toBe(state);
      });
    });

    describe('when the group is eligible to start a trial', () => {
      beforeEach(async () => {
        createComponent();
        await waitForPromises();
      });

      it('shows the trial banner and the toggle turned off', () => {
        expect(findTrialBanner().text()).toContain('By turning on Orbit today, Acme');
        expect(findToggle().props('value')).toBe(false);
      });
    });

    describe('when a trial is active', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('TRIAL_ACTIVE'),
            orbit: {
              __typename: 'OrbitNamespace',
              enabledAt: null,
              indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'READY' },
            },
          },
        });
        await waitForPromises();
      });

      it('shows the trial banner and the toggle turned on', () => {
        expect(findTrialBanner().exists()).toBe(true);
        expect(findToggle().props('value')).toBe(true);
      });
    });
  });

  describe('when the group is eligible and Orbit is already on', () => {
    beforeEach(async () => {
      createComponent({ group: { knowledgeGraphEnabled: true } });
      await waitForPromises();
    });

    it('shows no trial banner', () => {
      expect(findTrialBanner().exists()).toBe(false);
      expect(findToggle().props('value')).toBe(true);
    });

    describe('and the Owner turns it off', () => {
      beforeEach(async () => {
        findToggle().vm.$emit('change', false);
        await waitForPromises();
      });

      it('turns Orbit off without asking for a trial', () => {
        expect(findStartTrialModal().props('visible')).toBe(false);
        expect(updateHandler).toHaveBeenCalledWith({
          input: { groupPath: 'acme', enabled: false },
        });
      });
    });
  });

  describe('starting a trial', () => {
    beforeEach(async () => {
      createComponent();
      await waitForPromises();
    });

    it('shows no error and no confirm modal before the user acts', () => {
      expect(findActionError().exists()).toBe(false);
      expect(findStartTrialModal().props('visible')).toBe(false);
    });

    describe('when the Owner turns on Orbit', () => {
      beforeEach(async () => {
        findToggle().vm.$emit('change', true);
        await nextTick();
      });

      it('asks to confirm the trial and does not update Orbit', () => {
        expect(findStartTrialModal().props('visible')).toBe(true);
        expect(updateHandler).not.toHaveBeenCalled();
      });

      describe('and confirms', () => {
        beforeEach(async () => {
          findStartTrialModal().vm.$emit('start-trial');
          await waitForPromises();
        });

        it('runs the mutation for the group and refetches', () => {
          expect(startTrialHandler).toHaveBeenCalledWith({ groupPath: 'acme' });
          expect(queryHandler).toHaveBeenCalledTimes(2);
        });
      });
    });

    describe('when the trial cannot start', () => {
      beforeEach(async () => {
        startTrialHandler.mockResolvedValue({
          data: {
            orbitStartTrial: { __typename: 'OrbitStartTrialPayload', errors: ['No seats left'] },
          },
        });
        findStartTrialModal().vm.$emit('start-trial');
        await waitForPromises();
      });

      it('shows the server message in an error alert', () => {
        expect(findActionError().text()).toContain('No seats left');
      });
    });

    describe('when the trial cannot start because CustomersDot stops answering', () => {
      beforeEach(async () => {
        startTrialHandler.mockResolvedValue({
          data: {
            orbitStartTrial: {
              __typename: 'OrbitStartTrialPayload',
              errors: ['GitLab Orbit is not available right now. Try again later.'],
            },
          },
        });
        queryHandler.mockResolvedValue({
          data: { group: buildGroup({ orbitAccess: access('TRIAL_STATUS_UNAVAILABLE') }) },
        });
        findStartTrialModal().vm.$emit('start-trial');
        await waitForPromises();
      });

      it('shows only the CustomersDot alert', () => {
        expect(findGroupAlert().props('state')).toBe('cdot_unavailable');
        expect(findActionError().exists()).toBe(false);
      });
    });
  });

  describe('toggling Orbit', () => {
    const { bindInternalEventDocument } = useMockInternalEventsTracking();

    describe('when Orbit is off', () => {
      beforeEach(async () => {
        createComponent({ group: { orbitAccess: access('LICENSED') } });
        await waitForPromises();
      });

      it('does not update Orbit before the toggle changes', () => {
        expect(updateHandler).not.toHaveBeenCalled();
      });

      describe('and the Owner turns it on', () => {
        beforeEach(async () => {
          findToggle().vm.$emit('change', true);
          await waitForPromises();
        });

        it('runs the update mutation and refetches', () => {
          expect(updateHandler).toHaveBeenCalledWith({
            input: { groupPath: 'acme', enabled: true },
          });
          expect(queryHandler).toHaveBeenCalledTimes(2);
        });
      });

      describe('and the update fails', () => {
        beforeEach(async () => {
          updateHandler.mockResolvedValue({
            data: {
              orbitUpdate: { __typename: 'OrbitUpdatePayload', group: null, errors: ['Blocked'] },
            },
          });
          findToggle().vm.$emit('change', true);
          await waitForPromises();
        });

        it('shows the server message in an error alert', () => {
          expect(findActionError().text()).toContain('Blocked');
        });
      });
    });

    describe('when Orbit is on', () => {
      let trackEventSpy;

      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('LICENSED'),
          },
        });
        await waitForPromises();
        ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
      });

      it('does not track a turn off before the toggle changes', () => {
        expect(trackEventSpy).not.toHaveBeenCalled();
      });

      describe('and the Owner turns it off', () => {
        beforeEach(async () => {
          findToggle().vm.$emit('change', false);
          await waitForPromises();
        });

        it('runs the update mutation and tracks the event', () => {
          expect(updateHandler).toHaveBeenCalledWith({
            input: { groupPath: 'acme', enabled: false },
          });
          expect(trackEventSpy).toHaveBeenCalledWith(
            'click_orbit_turn_off_indexing',
            {},
            undefined,
          );
        });
      });
    });
  });

  describe('when Orbit is on', () => {
    describe('and still indexing', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('LICENSED'),
            orbit: {
              __typename: 'OrbitNamespace',
              enabledAt: '2026-10-15T11:59:00Z',
              indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'SYNCING' },
            },
          },
        });
        await waitForPromises();
      });

      it('shows an info status alert', () => {
        expect(findStatusAlert().props('variant')).toBe('info');
      });
    });

    describe('and ready', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('LICENSED'),
            orbit: {
              __typename: 'OrbitNamespace',
              enabledAt: null,
              indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'READY' },
            },
          },
        });
        await waitForPromises();
      });

      it('shows a success status alert with a link to Orbit', () => {
        expect(findStatusAlert().props('variant')).toBe('success');
        expect(findStatusAlert().props('primaryButtonLink')).toBe('/-/dashboard/orbit');
      });
    });

    describe('and GitLab Duo is not available', () => {
      beforeEach(async () => {
        createComponent({
          props: { duoAvailable: false },
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('LICENSED'),
            orbit: {
              __typename: 'OrbitNamespace',
              enabledAt: null,
              indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'READY' },
            },
          },
        });
        await waitForPromises();
      });

      it('shows the Duo alert', () => {
        expect(findDuoAlert().exists()).toBe(true);
      });
    });
  });

  describe('polling', () => {
    useFakeDate(2026, 9, 15, 12, 0, 0);

    const POLL_INTERVAL = 15000;

    const createEnabledGroup = (orbit) =>
      createComponent({
        group: {
          knowledgeGraphEnabled: true,
          orbitAccess: access('LICENSED'),
          orbit: { __typename: 'OrbitNamespace', ...orbit },
        },
      });

    const waitOnePollInterval = async () => {
      jest.advanceTimersByTime(POLL_INTERVAL);
      await waitForPromises();
    };

    describe('while indexing', () => {
      beforeEach(async () => {
        createEnabledGroup({
          enabledAt: '2026-10-15T11:59:00Z',
          indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'SYNCING' },
        });
        await waitForPromises();
      });

      it('has fetched the group one time', () => {
        expect(queryHandler).toHaveBeenCalledTimes(1);
      });

      describe('and one poll interval passes', () => {
        beforeEach(async () => {
          await waitOnePollInterval();
        });

        it('fetches the group again', () => {
          expect(queryHandler).toHaveBeenCalledTimes(2);
        });
      });
    });

    describe('when ready', () => {
      beforeEach(async () => {
        createEnabledGroup({
          enabledAt: null,
          indexingStatus: { __typename: 'OrbitIndexingStatus', phase: 'READY' },
        });
        await waitForPromises();
      });

      describe('and one poll interval passes', () => {
        beforeEach(async () => {
          await waitOnePollInterval();
        });

        it('does not fetch the group again', () => {
          expect(queryHandler).toHaveBeenCalledTimes(1);
        });
      });
    });

    describe('when enabled long ago with no status (queued)', () => {
      beforeEach(async () => {
        createEnabledGroup({ enabledAt: '2026-10-15T10:00:00Z', indexingStatus: null });
        await waitForPromises();
      });

      describe('and one poll interval passes', () => {
        beforeEach(async () => {
          await waitOnePollInterval();
        });

        it('does not fetch the group again', () => {
          expect(queryHandler).toHaveBeenCalledTimes(1);
        });
      });
    });
  });

  describe('a blocked state while Orbit is still on', () => {
    describe('when Orbit is on', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: true,
            orbitAccess: access('TRIAL_ENDED', 'TRIAL_EXPIRED'),
          },
        });
        await waitForPromises();
      });

      it('shows the alert and keeps the toggle so the Owner can turn Orbit off', () => {
        expect(findGroupAlert().props('state')).toBe('trial_ended');
        expect(findToggle().exists()).toBe(true);
      });
    });

    describe('when Orbit is off', () => {
      beforeEach(async () => {
        createComponent({
          group: {
            knowledgeGraphEnabled: false,
            orbitAccess: access('TRIAL_ENDED', 'TRIAL_EXPIRED'),
          },
        });
        await waitForPromises();
      });

      it('shows the alert and no toggle', () => {
        expect(findGroupAlert().props('state')).toBe('trial_ended');
        expect(findToggle().exists()).toBe(false);
      });
    });
  });
});
