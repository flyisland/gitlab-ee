import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import HandRaiseLeadButton from 'ee/hand_raise_leads/hand_raise_lead/components/hand_raise_lead_button.vue';
import CurrentPlanCard from 'ee/groups/billing/components/components_with_dap_monthly_commit/current_plan_card.vue';

describe('CurrentPlanCard', () => {
  let wrapper;

  const defaultProvide = {
    seatsInUse: 5,
    trialActive: false,
    manageSeatsPath: '/groups/test/-/seat_usage',
    totalSeats: 10,
    trialEndsOn: '2026-03-15',
    upgradeSubscriptionPath: '',
  };

  const createComponent = (provide = {}) => {
    wrapper = shallowMountExtended(CurrentPlanCard, {
      provide: {
        ...defaultProvide,
        ...provide,
      },
    });
  };

  const findSeatsInUse = () => wrapper.findByTestId('seats-in-use');
  const findUpgradeButton = () => wrapper.findByTestId('upgrade-subscription-button');
  const findManageSeatsButton = () => wrapper.findByTestId('manage-seats-button');
  const findHandRaiseLeadButton = () => wrapper.findComponent(HandRaiseLeadButton);

  describe('when trial is not active', () => {
    beforeEach(() => {
      createComponent();
    });

    it('displays the free plan header', () => {
      expect(wrapper.text()).toContain('Your group is on GitLab Free');
    });

    it('displays seats as used/total', () => {
      expect(findSeatsInUse().text()).toBe('5/10');
    });

    it('displays the free plan description', () => {
      expect(wrapper.text()).toContain(
        'For individuals working on personal projects and open source contributions.',
      );
    });

    it('does not display trial end date', () => {
      expect(wrapper.text()).not.toContain('This trial ends on');
    });
  });

  describe('when trial is active', () => {
    beforeEach(() => {
      createComponent({ trialActive: true });
    });

    it('displays the trial header', () => {
      expect(wrapper.text()).toContain('Your group is on a trial of GitLab Ultimate');
    });

    it('displays only seats in use without total', () => {
      expect(findSeatsInUse().text()).toBe('5');
    });

    it('displays trial end date', () => {
      expect(wrapper.text()).toContain('This trial ends on');
      expect(wrapper.text()).toContain('2026-03-15');
    });

    it('does not display the free plan description', () => {
      expect(wrapper.text()).not.toContain(
        'For individuals working on personal projects and open source contributions.',
      );
    });
  });

  describe('when totalSeats is 0', () => {
    it('displays Unlimited', () => {
      createComponent({ totalSeats: 0 });

      expect(findSeatsInUse().text()).toBe('5/Unlimited');
    });
  });

  describe('when upgradeSubscriptionPath is not provided', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders manage seats button with correct href', () => {
      expect(findManageSeatsButton().attributes('href')).toBe(defaultProvide.manageSeatsPath);
    });

    it('does not render upgrade subscription button', () => {
      expect(findUpgradeButton().exists()).toBe(false);
    });
  });

  describe('when upgradeSubscriptionPath is provided', () => {
    const upgradeSubscriptionPath = '/groups/upgrade-subscription';

    beforeEach(() => {
      createComponent({ upgradeSubscriptionPath });
    });

    it('correctly renders upgrade subscription button', () => {
      expect(findUpgradeButton().attributes('href')).toBe(upgradeSubscriptionPath);
      expect(findUpgradeButton().attributes('variant')).toBe('confirm');
      expect(findUpgradeButton().attributes('data-event-tracking')).toBe(
        'click_upgrade_subscription_cta_group_billing',
      );
    });

    it('does not render manage seats button', () => {
      expect(findManageSeatsButton().exists()).toBe(false);
    });

    it('does not render HandRaiseLeadButton', () => {
      expect(findHandRaiseLeadButton().exists()).toBe(false);
    });
  });

  describe('when upgradeSubscriptionPath is provided and monthlyCommitmentPurchased is greater than 0', () => {
    beforeEach(() => {
      createComponent({
        upgradeSubscriptionPath: '/groups/upgrade-subscription',
        monthlyCommitmentPurchased: 100,
      });
    });

    it('renders HandRaiseLeadButton', () => {
      expect(findHandRaiseLeadButton().exists()).toBe(true);
      expect(findHandRaiseLeadButton().props('buttonText')).toBe('Talk to sales');
      expect(findHandRaiseLeadButton().props('glmContent')).toBe('billing-group');
      expect(findHandRaiseLeadButton().props('ctaTracking')).toEqual({
        action: 'click_button',
        property: 'free_with_dap_monthly_commit',
      });
    });

    it('does not render upgrade subscription button', () => {
      expect(findUpgradeButton().exists()).toBe(false);
    });

    it('does not render manage seats button', () => {
      expect(findManageSeatsButton().exists()).toBe(false);
    });
  });
});
