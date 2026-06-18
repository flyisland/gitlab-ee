<script>
import { GlButton } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import HandRaiseLeadButton from 'ee/hand_raise_leads/hand_raise_lead/components/hand_raise_lead_button.vue';

export default {
  name: 'CurrentPlanCard',
  components: {
    GlButton,
    HandRaiseLeadButton,
  },
  inject: {
    seatsInUse: {
      default: 0,
    },
    trialActive: {
      default: false,
    },
    manageSeatsPath: {
      default: '',
    },
    totalSeats: {
      default: 0,
    },
    trialEndsOn: {
      default: '',
    },
    upgradeSubscriptionPath: {
      default: '',
    },
    monthlyCommitmentPurchased: {
      default: 0,
    },
  },
  handRaiseLeadButtonAttributes: {
    variant: 'confirm',
    'data-testid': 'current-plan-talk-to-sales-button',
  },
  handRaiseLeadCtaTracking: {
    action: 'click_button',
    property: 'free_with_dap_monthly_commit',
  },
  computed: {
    header() {
      const planName = this.trialActive
        ? s__('BillingPlans|a trial of GitLab Ultimate')
        : s__('BillingPlans|GitLab Free');

      return sprintf(s__('BillingPlans|Your group is on %{planName}'), { planName });
    },
    seats() {
      return this.trialActive
        ? this.seatsInUse
        : `${this.seatsInUse}/${this.totalSeats || __('Unlimited')}`;
    },
    showTrialEndsOn() {
      return this.trialActive && this.trialEndsOn;
    },
    renderUpgradeSubscriptionBilling() {
      return Boolean(this.upgradeSubscriptionPath);
    },
    hasDapMonthlyCommitment() {
      return this.monthlyCommitmentPurchased > 0;
    },
  },
};
</script>

<template>
  <div
    class="gl-border gl-flex gl-flex-1 gl-flex-col gl-rounded-xl gl-bg-subtle gl-p-5 gl-text-subtle"
  >
    <h3 class="gl-heading-3 gl-mb-3">
      {{ header }}
    </h3>

    <p v-if="showTrialEndsOn">
      {{ s__('BillingPlans|This trial ends on') }}
      <span class="gl-text-default">{{ trialEndsOn }}</span>
    </p>
    <p v-else>
      {{
        s__(
          'BillingPlans|For individuals working on personal projects and open source contributions.',
        )
      }}
    </p>
    <p class="gl-mt-auto">
      <span class="gl-heading-3 gl-mr-3" data-testid="seats-in-use">
        {{ seats }}
      </span>
      <span>{{ s__('BillingPlans|Seats in use') }}</span>
    </p>

    <hand-raise-lead-button
      v-if="renderUpgradeSubscriptionBilling && hasDapMonthlyCommitment"
      class="gl-self-start"
      glm-content="billing-group"
      :button-text="s__('BillingPlans|Talk to sales')"
      :button-attributes="$options.handRaiseLeadButtonAttributes"
      :cta-tracking="$options.handRaiseLeadCtaTracking"
    />
    <gl-button
      v-else-if="renderUpgradeSubscriptionBilling"
      class="gl-self-start"
      variant="confirm"
      data-testid="upgrade-subscription-button"
      data-event-tracking="click_upgrade_subscription_cta_group_billing"
      :href="upgradeSubscriptionPath"
      >{{ s__('BillingPlans|Upgrade subscription') }}</gl-button
    >
    <gl-button
      v-else
      class="gl-self-start"
      category="secondary"
      data-testid="manage-seats-button"
      data-event-tracking="click_manage_seats_on_billing_page"
      :href="manageSeatsPath"
      >{{ s__('BillingPlans|Manage seats') }}</gl-button
    >
  </div>
</template>
