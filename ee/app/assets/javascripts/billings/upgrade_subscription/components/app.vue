<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { PROMO_URL } from '~/constants';
import { s__ } from '~/locale';
import { InternalEvents } from '~/tracking';
import {
  PLAN_PREMIUM,
  PLAN_ULTIMATE,
  STEP_STATUS_ACTIVE,
  STEP_STATUS_COMPLETE,
  STEP_STATUS_DISABLED,
  STEPS,
} from '../constants';
import CreditSelectionStep from './credit_selection_step.vue';
import PlanSelection from './plan_selection.vue';
import PlanSummary from './plan_summary.vue';
import PromoTermsLink from './promo_terms_link.vue';
import StepHeader from './step_header.vue';

export default {
  name: 'UpgradeSubscriptionApp',
  components: {
    CreditSelectionStep,
    GlButton,
    GlCard,
    PlanSelection,
    PlanSummary,
    PromoTermsLink,
    StepHeader,
  },
  mixins: [InternalEvents.mixin()],
  STEPS,
  inject: [
    'premiumPlanPurchaseLink',
    'ultimatePlanPurchaseLink',
    'premiumPricePerMonth',
    'ultimatePricePerMonth',
  ],
  data() {
    return {
      currentStep: STEPS.PLAN_SELECTION,
      selectedPlanId: PLAN_PREMIUM,
    };
  },
  computed: {
    isPlanSelectionComplete() {
      return Boolean(this.selectedPlanId) && this.currentStep === STEPS.CREDIT_SELECTION;
    },
    planSelectionStatus() {
      if (this.isPlanSelectionComplete) return STEP_STATUS_COMPLETE;
      return STEP_STATUS_ACTIVE;
    },
    creditSelectionStatus() {
      if (this.currentStep === STEPS.CREDIT_SELECTION) return STEP_STATUS_ACTIVE;
      return STEP_STATUS_DISABLED;
    },
    canContinue() {
      return Boolean(this.selectedPlanId);
    },
    plans() {
      return [
        {
          value: PLAN_PREMIUM,
          name: s__('BillingPlans|Premium'),
          pricePerMonth: Number(this.premiumPricePerMonth),
          recommended: true,
          description: s__(
            'BillingPlans|For scaling organizations seeking enhanced productivity and collaboration.',
          ),
          precedingPlanText: s__('BillingPlans|Everything from Free, plus:'),
          details: [
            `${s__('BillingPlans|$12 in GitLab Credits per user per month')}*`,
            s__('BillingPlans|Unlimited licensed users'),
            s__('BillingPlans|10,000 compute minutes per month'),
          ],
          featuresLink: `${PROMO_URL}/pricing/premium/`,
        },
        {
          value: PLAN_ULTIMATE,
          name: s__('BillingPlans|Ultimate'),
          pricePerMonth: Number(this.ultimatePricePerMonth),
          description: s__(
            'BillingPlans|For enterprises requiring advanced security and compliance capabilities.',
          ),
          precedingPlanText: s__('BillingPlans|Everything from Premium, plus:'),
          details: [
            `${s__('BillingPlans|$24 in GitLab Credits per user per month')}*`,
            s__('BillingPlans|Advanced security capabilities'),
            s__('BillingPlans|50,000 compute minutes per month'),
          ],
          featuresLink: `${PROMO_URL}/pricing/ultimate/`,
        },
      ];
    },
    selectedPlan() {
      return this.plans.find((p) => p.value === this.selectedPlanId);
    },
    selectedPlanPurchaseLink() {
      return this.selectedPlanId === PLAN_PREMIUM
        ? this.premiumPlanPurchaseLink
        : this.ultimatePlanPurchaseLink;
    },
  },
  methods: {
    onSelectPlan(plan) {
      this.selectedPlanId = plan;
    },
    onEdit(step) {
      this.currentStep = step;
    },
    onContinue() {
      this.trackEvent('click_continue_with_plan_selected', {
        property: `continue_${this.selectedPlanId}`,
      });
      this.currentStep = STEPS.CREDIT_SELECTION;
    },
  },
  PROMO_TERMS_LINK: `${PROMO_URL}/pricing/#how-can-i-purchase-gitlab-credits`,
  CONTAINER_CLASS: 'gl-border-b gl-border-subtle gl-py-6',
};
</script>

<template>
  <div class="gl-mx-auto gl-mt-8 gl-flex gl-max-w-5xl gl-flex-col">
    <div data-testid="select-plan-container" :class="['gl-border-t', $options.CONTAINER_CLASS]">
      <step-header
        :step-number="1"
        :title="s__('BillingPlans|Select your subscription')"
        :status="planSelectionStatus"
        @edit="onEdit($options.STEPS.PLAN_SELECTION)"
      />

      <div v-if="isPlanSelectionComplete" data-testid="select-plan-summary">
        <gl-card body-class="gl-p-5 gl-bg-subtle">
          <plan-summary
            :plan="selectedPlan"
            :show-pricing-borders="false"
            :show-recommended-badge="false"
          />
        </gl-card>
      </div>

      <div v-if="currentStep === $options.STEPS.PLAN_SELECTION" class="gl-mt-5">
        <plan-selection :plans="plans" :selected-plan-id="selectedPlanId" @select="onSelectPlan" />
        <promo-terms-link class="gl-text-right" :href="$options.PROMO_TERMS_LINK" />
        <gl-button
          variant="confirm"
          data-testid="plan-selection-continue"
          :disabled="!canContinue"
          @click="onContinue"
        >
          {{ __('Continue') }}
        </gl-button>
      </div>
    </div>

    <credit-selection-step
      :selected-plan="selectedPlan"
      :purchase-link="selectedPlanPurchaseLink"
      :status="creditSelectionStatus"
    />
  </div>
</template>
