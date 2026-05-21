<script>
import { GlButton } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { s__ } from '~/locale';
import axios from '~/lib/utils/axios_utils';

export default {
  name: 'DapMonthlyCreditCard',
  components: {
    GlButton,
  },
  inject: {
    trialActive: {
      default: false,
    },
    purchaseCreditsPath: {
      default: '',
    },
    monthlyCommitmentPurchased: {
      default: 0,
    },
    upgradeSubscriptionPath: {
      default: '',
    },
    purchaseCreditsTrackingUrl: {
      default: '',
    },
  },
  GITLAB_CREDITS_DOCS_URL: helpPagePath('subscriptions/gitlab_credits'),
  computed: {
    renderUpgradeSubscriptionBilling() {
      return Boolean(this.upgradeSubscriptionPath);
    },
    hasDapMonthlyCommitment() {
      return this.monthlyCommitmentPurchased > 0;
    },
    cardBackgroundColor() {
      if (this.renderUpgradeSubscriptionBilling) {
        return 'gl-bg-subtle';
      }

      return this.hasDapMonthlyCommitment ? 'gl-bg-feedback-brand' : 'gl-bg-subtle';
    },
    ctaVariant() {
      if (this.renderUpgradeSubscriptionBilling) {
        return 'default';
      }

      return this.hasDapMonthlyCommitment ? 'confirm' : 'default';
    },
    showTrialIncludedCredit() {
      return this.trialActive && !this.hasDapMonthlyCommitment;
    },
    cardContent() {
      if (this.hasDapMonthlyCommitment) {
        return {
          header: s__('BillingPlans|GitLab Credits - Monthly committed pool'),
          description: s__(
            'BillingPlans|Your monthly credit commitment is shared across all members of the group. Credits reset at the start of each billing cycle.',
          ),
          ctaText: s__('BillingPlans|Increase credits'),
          ctaTrackingProperty: 'increase_credits',
        };
      }

      if (this.showTrialIncludedCredit) {
        return {
          header: s__('BillingPlans|GitLab Credits'),
          description: s__(
            'BillingPlans|These credits are included in your trial, and provide access to AI features. To maintain access after your trial, purchase monthly credits for your group, starting at $0.95, with volume discounts available.',
          ),
          ctaText: s__('BillingPlans|Purchase credits'),
          ctaTrackingProperty: 'purchase_credits',
        };
      }

      return {
        header: s__('BillingPlans|GitLab Credits'),
        description: s__(
          'BillingPlans|Purchase monthly credits for your group and unlock AI capabilities. Credits start at $0.95, with volume discounts available.',
        ),
        ctaText: s__('BillingPlans|Purchase credits'),
        ctaTrackingProperty: 'purchase_credits',
      };
    },
  },
  methods: {
    handleClick() {
      axios.post(this.purchaseCreditsTrackingUrl).catch(() => {});
    },
  },
  TRIAL_INCLUDED_CREDITS: '24',
};
</script>

<template>
  <div class="gl-border gl-flex-1 gl-rounded-xl gl-p-5 gl-text-subtle" :class="cardBackgroundColor">
    <h3 class="gl-heading-3 gl-mb-3">
      {{ cardContent.header }}
    </h3>

    <p>
      {{ cardContent.description }}
    </p>

    <template v-if="showTrialIncludedCredit">
      <p class="gl-mt-5">
        <span class="gl-heading-3 gl-mr-3" data-testid="trial-included-credits">
          {{ $options.TRIAL_INCLUDED_CREDITS }}
        </span>
        <span>{{ s__('BillingPlans|Credits/user') }}</span>
      </p>
    </template>
    <template v-else>
      <p class="gl-mt-5">
        <span class="gl-heading-3 gl-mr-3" data-testid="subscription-credits">
          {{ monthlyCommitmentPurchased }}
        </span>
        <span>{{ s__('BillingPlans|Credits') }}</span>
      </p>
    </template>

    <div class="gl-flex gl-items-center gl-gap-3">
      <gl-button
        :variant="ctaVariant"
        data-testid="dap-monthly-credit-card-cta-button"
        data-event-tracking="click_cta_on_dap_monthly_credit_card"
        :data-event-property="cardContent.ctaTrackingProperty"
        :href="purchaseCreditsPath"
        @click="handleClick"
        >{{ cardContent.ctaText }}</gl-button
      >
      <gl-button
        category="tertiary"
        data-testid="dap-monthly-credit-card-secondary-button"
        data-event-tracking="click_secondary_link_on_dap_monthly_credit_card"
        data-event-property="learn_more"
        :href="$options.GITLAB_CREDITS_DOCS_URL"
        target="_blank"
        >{{ s__('BillingPlans|Learn more') }}</gl-button
      >
    </div>
  </div>
</template>
