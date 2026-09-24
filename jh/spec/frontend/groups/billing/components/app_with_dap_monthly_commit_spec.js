import { shallowMount } from '@vue/test-utils';
import ReTrialCard from 'ee/groups/billing/components/components_with_dap_monthly_commit/re_trial_card.vue';
import FreeTrialBillingWithDapMonthlyCommitApp from 'jh/groups/billing/components/app_with_dap_monthly_commit.vue';
import CurrentPlanCard from 'jh/groups/billing/components/components_with_dap_monthly_commit/current_plan_card.vue';
import TeamPlanCard from 'jh/groups/billing/components/components_with_dap_monthly_commit/team_plan_card.vue';

describe('FreeTrialBillingWithDapMonthlyCommitApp', () => {
  it('renders the re-trial card above the plans while preserving the Team plan', () => {
    const wrapper = shallowMount(FreeTrialBillingWithDapMonthlyCommitApp);
    const reTrialCard = wrapper.findComponent(ReTrialCard);
    const currentPlanCard = wrapper.findComponent(CurrentPlanCard);

    expect(reTrialCard.exists()).toBe(true);
    expect(currentPlanCard.exists()).toBe(true);
    expect(wrapper.findComponent(TeamPlanCard).exists()).toBe(true);

    const inDocumentOrder = Array.from(wrapper.element.querySelectorAll('*'));

    expect(inDocumentOrder.indexOf(reTrialCard.element)).toBeLessThan(
      inDocumentOrder.indexOf(currentPlanCard.element),
    );
  });
});
