import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import DuoAgenticChatBlockedStateView from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat_blocked_state_view.vue';
import DuoAgenticChatView from 'ee/ai/duo_agentic_chat/components/duo_agentic_chat_view.vue';
import AgenticModeToggle from 'ee/ai/duo_agentic_chat/components/agentic_mode_toggle.vue';
import DuoDisabledEmptyState from 'ee/ai/duo_agentic_chat/components/duo_disabled_empty_state.vue';
import TrialExpiredEmptyState from 'ee/ai/duo_agentic_chat/components/trial_expired_empty_state.vue';
import DuoDisabledNonAdminEmptyState from 'ee/ai/duo_agentic_chat/components/duo_disabled_non_admin_empty_state.vue';
import SubscriptionExpiredEmptyState from 'ee/ai/duo_agentic_chat/components/subscription_expired_empty_state.vue';

const DEFAULT_PROPS = {
  isDuoDisabled: false,
  isDuoDisabledNonAdmin: false,
  containerType: 'group',
  isTrialExpired: false,
  buyAddonPath: '/buy/addon/path',
  canBuyAddon: false,
  isClassicAvailable: false,
  forceAgenticModeForCoreDuoUsers: true,
  duoSettingsPath: '/settings',
  trustedUrls: [],
};

const emptyStateComponents = [
  DuoDisabledEmptyState,
  DuoDisabledNonAdminEmptyState,
  TrialExpiredEmptyState,
  SubscriptionExpiredEmptyState,
];

describe('DuoAgenticChatBlockedStateView', () => {
  let wrapper;

  const findAgenticModeToggle = () => wrapper.findComponent(AgenticModeToggle);
  const findDuoAgenticChatView = () => wrapper.findComponent(DuoAgenticChatView);
  const findDuoDisabledEmptyState = () => wrapper.findComponent(DuoDisabledEmptyState);

  const expectSingleEmptyState = (expectedComponent, before = () => {}) => {
    it('renders the correct empty state', () => {
      before();
      emptyStateComponents
        .filter((component) => component !== expectedComponent)
        .forEach((component) => {
          expect(wrapper.findComponent(component).exists()).toBe(false);
        });
      expect(wrapper.findComponent(expectedComponent).exists()).toBe(true);
    });
  };

  const createComponent = (props = {}, provide = {}) => {
    wrapper = shallowMountExtended(DuoAgenticChatBlockedStateView, {
      propsData: { ...DEFAULT_PROPS, ...props },
      provide: {
        badgeType: 'beta',
        chatConfiguration: { defaultProps: { isEmbedded: true } },
        ...provide,
      },
    });
  };

  it('passes correct props to DuoAgenticChatView', () => {
    createComponent();

    expect(findDuoAgenticChatView().props()).toEqual(
      expect.objectContaining({
        title: 'GitLab Duo Agentic Chat',
        isMultithreaded: true,
        multiThreadedView: 'chat',
        chatState: {
          isEnabled: false,
          reason: 'GitLab Duo is disabled',
        },
        badgeType: 'beta',
        messages: [],
        showStudioHeader: true,
      }),
    );
  });

  it.each`
    isClassicAvailable | forceAgenticModeForCoreDuoUsers | rendered
    ${true}            | ${true}                         | ${false}
    ${true}            | ${false}                        | ${true}
    ${false}           | ${true}                         | ${false}
    ${false}           | ${false}                        | ${false}
  `(
    'when isClassicAvailable is $isClassicAvailable and $forceAgenticModeForCoreDuoUsers, agentic toggle rendering is $rendered',
    ({ isClassicAvailable, forceAgenticModeForCoreDuoUsers, rendered }) => {
      createComponent({ isClassicAvailable, forceAgenticModeForCoreDuoUsers });

      expect(findAgenticModeToggle().exists()).toBe(rendered);
    },
  );

  it('emits the `return-to-classic` event when Agentic mode is toggled off', () => {
    createComponent({ isClassicAvailable: true, forceAgenticModeForCoreDuoUsers: false });

    expect(wrapper.emitted('return-to-classic')).toBeUndefined();

    findAgenticModeToggle().vm.$emit('change');

    expect(wrapper.emitted('return-to-classic')).toHaveLength(1);
  });

  describe('when Duo is disabled in the namespace', () => {
    expectSingleEmptyState(DuoDisabledEmptyState, () => {
      createComponent({ isDuoDisabled: true });
    });

    it('passes the correct props to DuoDisabledEmptyState', () => {
      createComponent({ isDuoDisabled: true });
      const state = findDuoDisabledEmptyState();

      expect(state.props('duoSettingsPath')).toBe('/settings');
      expect(state.props('namespaceType')).toBe('group');
    });

    it('passes the namespace type down', () => {
      createComponent({ isDuoDisabled: true, containerType: 'project' });

      expect(findDuoDisabledEmptyState().props('namespaceType')).toBe('project');
    });

    it('does not render SubscriptionExpiredEmptyState', () => {
      createComponent({ isDuoDisabled: true });
      expect(wrapper.findComponent(SubscriptionExpiredEmptyState).exists()).toBe(false);
    });
  });

  describe('when the trial has expired', () => {
    beforeEach(() => {
      createComponent({
        isTrialExpired: true,
      });
    });

    expectSingleEmptyState(TrialExpiredEmptyState);

    it('passes the correct props to TrialExpiredEmptyState', () => {
      const state = wrapper.findComponent(TrialExpiredEmptyState);

      expect(state.props()).toEqual({
        buyAddonPath: DEFAULT_PROPS.buyAddonPath,
        canBuyAddon: DEFAULT_PROPS.canBuyAddon,
      });
    });
  });

  describe('when isSubscriptionExpired', () => {
    beforeEach(() =>
      createComponent({
        isSubscriptionExpired: true,
        buyAddonPath: 'https://customers.gitlab.com/subscriptions',
        canBuyAddon: true,
      }),
    );

    expectSingleEmptyState(SubscriptionExpiredEmptyState);

    it('passes the correct props to SubscriptionExpiredEmptyState', () => {
      const state = wrapper.findComponent(SubscriptionExpiredEmptyState);
      expect(state.props('buyAddonPath')).toBe('https://customers.gitlab.com/subscriptions');
      expect(state.props('canBuyAddon')).toBe(true);
    });

    it('sets chat-state reason to the subscription-ended message', () => {
      expect(wrapper.findComponent(DuoAgenticChatView).props('chatState')).toEqual({
        isEnabled: false,
        reason: 'Your subscription has ended',
      });
    });
  });

  describe('when isDuoDisabledNonAdmin', () => {
    beforeEach(() => createComponent({ isDuoDisabledNonAdmin: true }));

    expectSingleEmptyState(DuoDisabledNonAdminEmptyState);

    it('renders DuoDisabledNonAdminEmptyState with correct props', () => {
      const state = wrapper.findComponent(DuoDisabledNonAdminEmptyState);
      expect(state.exists()).toBe(true);
      expect(state.props('containerType')).toBe('group');
    });

    describe('when containerType is project', () => {
      beforeEach(() => createComponent({ isDuoDisabledNonAdmin: true, containerType: 'project' }));

      it('renders DuoDisabledNonAdminEmptyState with containerType project', () => {
        const state = wrapper.findComponent(DuoDisabledNonAdminEmptyState);
        expect(state.exists()).toBe(true);
        expect(state.props('containerType')).toBe('project');
      });
    });
  });

  describe('when both isSubscriptionExpired and isDuoDisabled are true', () => {
    it('prefers the SubscriptionExpiredEmptyState', () => {
      createComponent({ isDuoDisabled: true, isSubscriptionExpired: true });

      expect(wrapper.findComponent(SubscriptionExpiredEmptyState).exists()).toBe(true);
      expect(wrapper.findComponent(DuoDisabledEmptyState).exists()).toBe(false);
    });
  });
});
