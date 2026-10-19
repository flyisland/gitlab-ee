import { GlBadge } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { openDuoChatWithAgent } from 'ee/ai/utils';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import OverviewQuickstart from 'ee/orbit/dashboard/overview/overview_quickstart.vue';

jest.mock('ee/ai/utils', () => ({ openDuoChatWithAgent: jest.fn() }));

describe('OverviewQuickstart', () => {
  let wrapper;

  const { bindInternalEventDocument } = useMockInternalEventsTracking();

  const mountQuickstart = (props = {}) => {
    wrapper = mountExtended(OverviewQuickstart, {
      propsData: { duoAccessible: true, orbitSettingsEnabled: true, indexing: false, ...props },
      provide: { preferencesPath: '/-/profile/preferences' },
    });
  };

  const findStepTitles = () => wrapper.findAll('h3').wrappers.map((h) => h.text());
  const findPreferences = () => wrapper.findByTestId('orbit-quickstart-preferences');
  const findAskDuo = () => wrapper.findByTestId('orbit-quickstart-ask-duo');
  const findTryText = () =>
    wrapper
      .findByTestId('orbit-quickstart-try-duo')
      .find('[data-testid="quickstart-step-description"]')
      .text();

  describe('when mounted', () => {
    beforeEach(() => mountQuickstart());

    it('shows the three steps, the CLI command, and a Documentation link', () => {
      expect(findStepTitles()).toEqual([
        'Turn on Orbit for GitLab Duo',
        'Set up the Orbit CLI',
        'Try Orbit in GitLab Duo',
      ]);
      expect(wrapper.text()).toContain('glab orbit setup');
      expect(wrapper.findByTestId('orbit-quickstart-docs').attributes('href')).toContain('/orbit/');
    });
  });

  describe('when Duo is reachable and the opt-in is on', () => {
    beforeEach(() => mountQuickstart({ orbitSettingsEnabled: true }));

    it('shows the On badge and links to the preferences page', () => {
      expect(wrapper.findComponent(GlBadge).text()).toBe('On');
      expect(findPreferences().attributes('href')).toBe('/-/profile/preferences');
    });
  });

  describe('when Duo is reachable and the opt-in is off', () => {
    beforeEach(() => mountQuickstart({ orbitSettingsEnabled: false }));

    it('shows the Preferences link and no badge', () => {
      expect(findPreferences().exists()).toBe(true);
      expect(wrapper.findComponent(GlBadge).exists()).toBe(false);
    });
  });

  describe('when Duo is not reachable', () => {
    beforeEach(() => mountQuickstart({ duoAccessible: false }));

    it('shows no Preferences link and no On badge', () => {
      expect(findPreferences().exists()).toBe(false);
      expect(wrapper.findComponent(GlBadge).exists()).toBe(false);
    });

    it('says in step 1 that GitLab Duo is not available', () => {
      expect(wrapper.findByTestId('orbit-quickstart-no-duo').text()).toBe(
        'GitLab Duo is not available for your groups.',
      );
    });
  });

  describe.each`
    duoAccessible | indexing | text                                                                                                                     | hasAskDuo
    ${true}       | ${false} | ${'Ask GitLab Duo a question that spans projects.'}                                                                      | ${true}
    ${true}       | ${true}  | ${'When indexing finishes, ask GitLab Duo a question that spans projects.'}                                              | ${true}
    ${false}      | ${false} | ${'Ask GitLab Duo a question that spans projects. GitLab Duo is not available for your groups.'}                         | ${false}
    ${false}      | ${true}  | ${'When indexing finishes, ask GitLab Duo a question that spans projects. GitLab Duo is not available for your groups.'} | ${false}
  `(
    'when duoAccessible is $duoAccessible and indexing is $indexing',
    ({ duoAccessible, indexing, text, hasAskDuo }) => {
      beforeEach(() => mountQuickstart({ duoAccessible, indexing }));

      it('shows the step 3 text and the matching Ask GitLab Duo button', () => {
        expect(findTryText()).toBe(text);
        expect(findAskDuo().exists()).toBe(hasAskDuo);
      });
    },
  );

  describe('when the user clicks Ask GitLab Duo', () => {
    let trackEventSpy;

    beforeEach(() => {
      mountQuickstart();
      ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
    });

    it('tracks the click and opens Duo Chat with the GitLab Duo agent', async () => {
      expect(openDuoChatWithAgent).not.toHaveBeenCalled();
      expect(trackEventSpy).not.toHaveBeenCalled();

      await findAskDuo().trigger('click');
      await waitForPromises();

      expect(trackEventSpy).toHaveBeenCalledWith('click_orbit_open_duo_chat', {}, undefined);
      expect(openDuoChatWithAgent).toHaveBeenCalledWith({
        agent: { name: 'GitLab Duo' },
        resourceId: 'orbit-quickstart',
      });
    });
  });

  describe('when the user copies the CLI command', () => {
    let trackEventSpy;

    beforeEach(() => {
      mountQuickstart();
      ({ trackEventSpy } = bindInternalEventDocument(wrapper.element));
    });

    it('tracks the copy with the CLI label', () => {
      expect(trackEventSpy).not.toHaveBeenCalled();

      wrapper.findComponent(ClipboardButton).vm.$emit('click');

      expect(trackEventSpy).toHaveBeenCalledWith(
        'click_orbit_copy_to_clipboard',
        { label: 'CLI' },
        undefined,
      );
    });
  });

  describe('when the user closes the panel', () => {
    beforeEach(() => mountQuickstart());

    it('emits one close event', () => {
      const closeButton = wrapper.findComponentByTestId('orbit-quickstart-close');

      expect(closeButton.attributes('aria-label')).toBe('Close Quickstart');
      expect(wrapper.emitted('close')).toBeUndefined();

      closeButton.trigger('click');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });
});
