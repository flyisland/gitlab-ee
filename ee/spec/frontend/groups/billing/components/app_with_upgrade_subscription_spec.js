import { shallowMount } from '@vue/test-utils';
import FreeTrialBillingWithUpgradeSubscriptionApp from 'ee/groups/billing/components/app_with_upgrade_subscription.vue';
import CurrentPlanCard from 'ee/groups/billing/components/components_with_dap_monthly_commit/current_plan_card.vue';
import DapMonthlyCreditCard from 'ee/groups/billing/components/components_with_dap_monthly_commit/dap_monthly_credit_card.vue';
import StartUltimateTrialCard from 'ee/groups/billing/components/start_ultimate_trial_card.vue';

describe('FreeTrialBillingWithUpgradeSubscriptionApp', () => {
  let wrapper;

  const findCurrentPlanCard = () => wrapper.findComponent(CurrentPlanCard);
  const findDapMonthlyCreditCard = () => wrapper.findComponent(DapMonthlyCreditCard);
  const findStartUltimateTrialCard = () => wrapper.findComponent(StartUltimateTrialCard);

  const createComponent = (provide = {}) => {
    wrapper = shallowMount(FreeTrialBillingWithUpgradeSubscriptionApp, {
      provide: {
        trialActive: false,
        eligibleForTrial: false,
        ...provide,
      },
    });
  };

  it('renders the billing heading', () => {
    createComponent();

    expect(wrapper.text()).toContain('Billing');
  });

  it('renders current plan card', () => {
    createComponent();

    expect(findCurrentPlanCard().exists()).toBe(true);
  });

  it('renders dap monthly credit card', () => {
    createComponent();

    expect(findDapMonthlyCreditCard().exists()).toBe(true);
  });

  describe('start ultimate trial card visibility', () => {
    it.each`
      trialActive | eligibleForTrial | visible  | description
      ${false}    | ${true}          | ${true}  | ${'shows when eligible for a trial'}
      ${true}     | ${false}         | ${false} | ${'hides when a trial is active'}
      ${false}    | ${false}         | ${false} | ${'hides when not eligible for a trial'}
    `('$description', ({ trialActive, eligibleForTrial, visible }) => {
      createComponent({ trialActive, eligibleForTrial });

      expect(findStartUltimateTrialCard().exists()).toBe(visible);
    });
  });
});
