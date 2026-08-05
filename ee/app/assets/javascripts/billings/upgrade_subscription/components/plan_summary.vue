<script>
import { GlBadge } from '@gitlab/ui';

export default {
  name: 'PlanSummary',
  components: {
    GlBadge,
  },
  props: {
    plan: {
      type: Object,
      required: true,
    },
    showPricingBorders: {
      type: Boolean,
      required: false,
      default: true,
    },
    showRecommendedBadge: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  computed: {
    showBadge() {
      return this.showRecommendedBadge && this.plan.recommended;
    },
    formattedPrice() {
      return parseFloat(this.plan.pricePerMonth.toFixed(2));
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-flex gl-flex-col gl-gap-3 gl-leading-20 gl-text-subtle">
      <div class="gl-flex gl-items-center gl-justify-between">
        <h2 class="gl-heading-1-fixed gl-mb-0">{{ plan.name }}</h2>
        <gl-badge v-if="showBadge" variant="info">{{ __('Recommended') }}</gl-badge>
      </div>
      {{ plan.description }}
    </div>
    <p
      v-if="plan.pricePerMonth"
      data-testid="plan-summary-pricing"
      :class="[
        'gl-flex gl-items-center gl-text-subtle',
        showPricingBorders
          ? 'gl-border-t gl-border-b gl-my-5 gl-border-subtle gl-py-5'
          : 'gl-mb-0 gl-mt-4 gl-py-0',
      ]"
    >
      <span class="gl-mr-1 gl-mt-2 gl-self-start gl-text-sm gl-font-bold">$</span>
      <span class="gl-heading-1-fixed gl-mb-0">{{ formattedPrice }}</span>
      <span class="gl-ml-3 gl-flex gl-flex-col gl-self-center gl-text-sm">
        <span>{{ plan.pricingLabel || s__('BillingPlans|per user/month, billed annually') }}</span>
        <span v-if="plan.pricingSubLabel">{{ plan.pricingSubLabel }}</span>
      </span>
    </p>
    <hr v-else class="gl-border-t gl-my-5 gl-border-subtle" />
  </div>
</template>
