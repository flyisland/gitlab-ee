<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  name: 'CreditPurchaseCard',
  components: {
    GlButton,
    GlCard,
  },
  inject: {
    purchaseCreditsPath: {
      default: '',
    },
  },
  GITLAB_CREDITS_DOCS_URL: helpPagePath('subscriptions/gitlab_credits'),
};
</script>

<template>
  <gl-card body-class="gl-p-5">
    <template #header>
      <h3>{{ s__('SuperSonics|GitLab Credits') }}</h3>
    </template>

    <div class="gl-flex gl-flex-col">
      <p>
        {{
          s__(
            'SuperSonics|Purchase monthly credits for your instance and unlock AI capabilities. Volume discounts available.',
          )
        }}
      </p>

      <p>
        <span class="gl-heading-3 gl-mr-4" data-testid="credits-count">{{ __('0') }}</span>
        <span class="gl-text-subtle">{{ s__('SuperSonics|Credits') }}</span>
      </p>

      <div class="gl-flex gl-gap-3">
        <gl-button
          v-if="purchaseCreditsPath"
          variant="confirm"
          data-testid="credit-purchase-card-cta-button"
          data-event-tracking="click_purchase_credits_cta_on_sm_credits_card"
          data-event-property="purchase_credits"
          :href="purchaseCreditsPath"
        >
          {{ s__('SuperSonics|Purchase credits') }}
        </gl-button>
        <gl-button
          category="tertiary"
          data-testid="credit-purchase-card-learn-more-button"
          data-event-tracking="click_learn_more_cta_on_sm_credits_card"
          data-event-property="learn_more"
          :href="$options.GITLAB_CREDITS_DOCS_URL"
          target="_blank"
        >
          {{ s__('SuperSonics|Learn more') }}
        </gl-button>
      </div>
    </div>
  </gl-card>
</template>
