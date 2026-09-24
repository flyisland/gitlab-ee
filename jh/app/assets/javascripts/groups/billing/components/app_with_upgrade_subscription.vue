<script>
import DapMonthlyCreditCard from './components_with_dap_monthly_commit/dap_monthly_credit_card.vue';
import CurrentPlanCard from './components_with_dap_monthly_commit/current_plan_card.vue';
import StartUltimateTrialCard from './start_ultimate_trial_card.vue';

export default {
  name: 'FreeTrialBillingWithUpgradeSubscriptionApp',
  components: {
    CurrentPlanCard,
    DapMonthlyCreditCard,
    StartUltimateTrialCard,
  },
  inject: {
    trialActive: {
      default: false,
    },
    trialExpired: {
      default: false,
    },
  },
  computed: {
    showStartTrial() {
      return !this.trialExpired && !this.trialActive;
    },
  },
};
</script>
<template>
  <div class="gl-mx-auto gl-mt-8 gl-max-w-limited">
    <h2 class="gl-heading-2">{{ s__('BillingPlans|Billing') }}</h2>

    <div class="gl-mt-6 gl-flex gl-flex-col gl-gap-5">
      <current-plan-card />

      <dap-monthly-credit-card />

      <start-ultimate-trial-card v-if="showStartTrial" />
    </div>
  </div>
</template>
