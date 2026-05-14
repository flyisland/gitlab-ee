<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';

export default {
  name: 'FreeTierPurchaseCommitmentCard',
  components: {
    GlButton,
    GlCard,
  },
  inject: {
    gitlabComPurchaseCreditsPath: {},
  },
  GITLAB_CREDITS_DOCS_URL: helpPagePath('subscriptions/gitlab_credits'),
};
</script>
<template>
  <gl-card class="gl-flex-1" header-class="gl-heading-scale-400">
    <template #header>
      {{ s__('AiPowered|Save on GitLab Credits with monthly commitments') }}
    </template>
    <div class="gl-flex gl-h-full gl-flex-col gl-justify-between">
      <div>
        {{
          s__(
            'AiPowered|Monthly commitments offer significant discounts off list price. Pool GitLab Credits across your namespace for flexibility and predictable monthly costs.',
          )
        }}
      </div>
      <div class="gl-pt-5">
        <gl-button
          :href="gitlabComPurchaseCreditsPath"
          variant="confirm"
          data-event-tracking="click_purchase_credits_cta_active_trial"
        >
          {{ s__('AiPowered|Purchase credits') }}
        </gl-button>
        <gl-button
          :href="$options.GITLAB_CREDITS_DOCS_URL"
          category="tertiary"
          variant="confirm"
          data-event-tracking="click_learn_more_link_free_tier_purchase_commitment"
        >
          {{ __('Learn more') }}
        </gl-button>
      </div>
    </div>
  </gl-card>
</template>
