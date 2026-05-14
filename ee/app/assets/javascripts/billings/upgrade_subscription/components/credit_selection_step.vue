<script>
import { GlAlert, GlButton, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { PROMO_URL } from '~/constants';
import { s__, sprintf } from '~/locale';
import { InternalEvents } from '~/tracking';
import {
  CREDIT_OPTION_INCLUDED,
  CREDIT_OPTION_MONTHLY,
  STEP_STATUS_ACTIVE,
  PLAN_CREDIT_DETAILS,
} from '../constants';
import PlanSelection from './plan_selection.vue';
import StepHeader from './step_header.vue';

export default {
  name: 'CreditSelectionStep',
  components: {
    GlAlert,
    GlButton,
    GlFormGroup,
    GlFormInput,
    PlanSelection,
    StepHeader,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    selectedPlan: {
      type: Object,
      required: true,
    },
    purchaseLink: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      selectedCreditsOption: CREDIT_OPTION_INCLUDED,
      monthlyCreditsAmount: 20,
      creditsInputError: null,
    };
  },
  computed: {
    isActive() {
      return this.status === STEP_STATUS_ACTIVE;
    },
    canContinue() {
      if (!this.selectedCreditsOption) return false;
      if (this.selectedCreditsOption === CREDIT_OPTION_MONTHLY) {
        return !this.creditsInputError;
      }
      return true;
    },
    creditOptions() {
      const { creditsPerUser, maxCodeSuggestions, maxCodeReviews } =
        PLAN_CREDIT_DETAILS[this.selectedPlan?.value];

      return [
        {
          value: CREDIT_OPTION_INCLUDED,
          name: s__('BillingPlans|Included credits'),
          description: sprintf(
            s__(
              'BillingPlans|Best for teams just getting started with AI. Included in the cost of your %{planName} subscription.*',
            ),
            { planName: this.selectedPlan?.name },
          ),
          recommended: false,
          precedingPlanText: sprintf(
            s__('BillingPlans|%{creditsPerUser} credits/user/month included in plan for:'),
            { creditsPerUser },
          ),
          details: [
            sprintf(s__('BillingPlans|Up to %{maxCodeSuggestions} code suggestions'), {
              maxCodeSuggestions,
            }),
            sprintf(s__('BillingPlans|Up to %{maxCodeReviews} code reviews'), { maxCodeReviews }),
          ],
          promoTermsLink: this.$options.PROMO_TERMS_LINK,
        },
        {
          value: CREDIT_OPTION_MONTHLY,
          name: s__('BillingPlans|Monthly commitment'),
          description: s__(
            'BillingPlans|Discounted bulk credits shared across your group, this is best for teams looking to scale their AI usage. Billed annually.',
          ),
          recommended: false,
          pricePerMonth: 0.95,
          pricingLabel: s__('BillingPlans|per GitLab Credit'),
          pricingSubLabel: s__('BillingPlans|Volume discounts available'),
          precedingPlanText: s__('BillingPlans|All included credits, plus shared credits for:'),
          details: [
            s__('BillingPlans|Up to 50 additional code suggestions per credit'),
            s__('BillingPlans|Up to 4 additional code reviews per credit'),
          ],
        },
      ];
    },
    creditsInputDescription() {
      if (this.creditsInputError) return null;
      return this.$options.i18n.creditsDescription;
    },
    redirectUrl() {
      const url = new URL(this.purchaseLink);
      if (this.selectedCreditsOption === CREDIT_OPTION_MONTHLY && this.monthlyCreditsAmount) {
        url.searchParams.set('add_on_plan_type', 'gitlab_credits');
        url.searchParams.set('add_on_quantity', this.monthlyCreditsAmount);
        url.searchParams.set('entry_point', 'com_daisy_chain');
      }
      return url.toString();
    },
  },
  created() {
    this.lastTrackedErrorType = null;
  },
  methods: {
    onSelectCreditsOption(option) {
      this.selectedCreditsOption = option;
    },
    onCreditsInput(value) {
      const result = this.validateCreditsInput(value);
      this.creditsInputError = result?.message || null;
      this.monthlyCreditsAmount = result ? this.monthlyCreditsAmount : Number(value);

      const errorType = result?.type || null;
      if (errorType !== this.lastTrackedErrorType) {
        if (errorType) {
          this.trackEvent('error_input_quantity', { property: errorType });
        }
        this.lastTrackedErrorType = errorType;
      }
    },
    validateCreditsInput(value) {
      const num = Number(value);
      if (Number.isNaN(num)) {
        return {
          message: s__('BillingPlans|Must be a valid number'),
          type: 'error_invalid_characters',
        };
      }
      if (!value || num < 5) {
        return { message: s__('BillingPlans|Minimum 5 credits'), type: 'error_below_minimum' };
      }
      if (num > 999999) {
        return {
          message: s__('BillingPlans|Cannot exceed 999,999 credits'),
          type: 'error_exceeds_maximum',
        };
      }
      return null;
    },
    onContinue() {
      this.trackEvent('click_continue_to_checkout', {
        property: `continue_to_checkout_${this.selectedCreditsOption}`,
        value:
          this.selectedCreditsOption === CREDIT_OPTION_MONTHLY
            ? Number(this.monthlyCreditsAmount)
            : undefined,
      });
      window.location.assign(this.redirectUrl);
    },
  },
  i18n: {
    creditsDescription: s__('BillingPlans|We recommend starting with 20 credits per month.'),
    monthlyOptionAlert: s__(
      "BillingPlans|After purchasing your subscription, you'll complete a separate checkout for credits.",
    ),
  },
  CREDIT_OPTION_MONTHLY,
  PROMO_TERMS_LINK: `${PROMO_URL}/pricing/#how-can-i-purchase-gitlab-credits`,
  CONTAINER_CLASS: 'gl-border-b gl-border-subtle gl-py-6',
};
</script>

<template>
  <div data-testid="select-credit-container" :class="$options.CONTAINER_CLASS">
    <step-header
      :step-number="2"
      :title="s__('BillingPlans|Select your credits')"
      :status="status"
    />

    <div v-if="isActive">
      <gl-alert
        v-if="selectedCreditsOption === $options.CREDIT_OPTION_MONTHLY"
        variant="info"
        :dismissible="false"
        class="gl-mb-6"
      >
        {{ $options.i18n.monthlyOptionAlert }}
      </gl-alert>

      <plan-selection
        :plans="creditOptions"
        :selected-plan-id="selectedCreditsOption"
        @select="onSelectCreditsOption"
      >
        <template #card-content="{ plan }">
          <gl-form-group
            v-if="plan && plan.value === $options.CREDIT_OPTION_MONTHLY"
            class="gl-mb-5"
            :label="__('Credits per month')"
            :description="creditsInputDescription"
            :state="!creditsInputError"
            :invalid-feedback="creditsInputError"
          >
            <gl-form-input
              :value="monthlyCreditsAmount"
              type="text"
              :state="!creditsInputError"
              @input="onCreditsInput"
              @focus="onSelectCreditsOption($options.CREDIT_OPTION_MONTHLY)"
            />
          </gl-form-group>
        </template>
      </plan-selection>

      <gl-button
        class="gl-mt-6"
        variant="confirm"
        data-testid="credit-selection-continue"
        :disabled="!canContinue"
        @click="onContinue"
      >
        {{ s__('BillingPlans|Continue to checkout') }}
      </gl-button>
    </div>
  </div>
</template>
