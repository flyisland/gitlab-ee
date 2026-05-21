<script>
import { GlButton, GlCard, GlFormRadio, GlFormRadioGroup, GlIcon } from '@gitlab/ui';
import { InternalEvents } from '~/tracking';
import PlanSummary from './plan_summary.vue';
import PromoTermsLink from './promo_terms_link.vue';

export default {
  name: 'PlanSelection',
  components: {
    GlButton,
    GlCard,
    GlFormRadio,
    GlFormRadioGroup,
    GlIcon,
    PlanSummary,
    PromoTermsLink,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    plans: {
      type: Array,
      required: true,
    },
    selectedPlanId: {
      type: String,
      required: false,
      default: null,
    },
    showRecommendedBadge: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  emits: ['select'],
  methods: {
    onFeaturesLinkClick(planValue) {
      this.trackEvent('click_see_all_features_upgrade_subscription_plan_card', {
        property: `see_all_features_${planValue}`,
      });
    },
  },
};
</script>

<template>
  <gl-form-radio-group
    :checked="selectedPlanId"
    class="plan-selection gl-flex gl-flex-col gl-gap-5 md:gl-flex-row"
    @change="$emit('select', $event)"
  >
    <gl-card
      v-for="plan in plans"
      :key="plan.value"
      class="gl-flex-1"
      body-class="gl-p-5 gl-bg-subtle gl-flex gl-flex-col gl-justify-between"
    >
      <div>
        <gl-form-radio :value="plan.value">
          <plan-summary :plan="plan" :show-recommended-badge="showRecommendedBadge" />
          <slot name="card-content" :plan="plan"></slot>
          <p v-if="plan.precedingPlanText" class="gl-mb-0 gl-text-lg gl-leading-24 gl-text-subtle">
            {{ plan.precedingPlanText }}
          </p>
          <ul
            class="gl-mb-0 gl-flex gl-list-none gl-flex-col gl-gap-5 gl-py-5 gl-pl-0 gl-leading-20 gl-text-subtle"
          >
            <li v-for="detail in plan.details" :key="detail" class="gl-flex gl-items-center">
              <gl-icon name="check" variant="info" class="gl-mr-2" />
              <span>{{ detail }}</span>
            </li>
          </ul>
        </gl-form-radio>
        <gl-button
          v-if="plan.featuresLink"
          class="gl-ml-6"
          :href="plan.featuresLink"
          variant="link"
          icon="external-link"
          target="_blank"
          rel="noopener noreferrer"
          @click="onFeaturesLinkClick(plan.value)"
        >
          {{ s__('BillingPlans|See all features') }}
        </gl-button>
      </div>
      <promo-terms-link v-if="plan.promoTermsLink" :href="plan.promoTermsLink" />
    </gl-card>
  </gl-form-radio-group>
</template>
