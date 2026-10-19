<script>
import { GlButton, GlCard } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import { s__, sprintf } from '~/locale';

export default {
  name: 'CreditGatedModelCard',
  components: {
    GlButton,
    GlCard,
  },
  props: {
    modelName: {
      type: String,
      required: true,
    },
    purchaseCreditsPath: {
      type: String,
      required: false,
      default: '',
    },
    canBuyAddon: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    title() {
      const template = this.canBuyAddon
        ? s__('DuoAgenticChat|Purchase credits to use %{modelName}')
        : s__("DuoAgenticChat|%{modelName} isn't included in your trial");

      return sprintf(template, { modelName: this.modelName });
    },
    description() {
      return this.canBuyAddon
        ? s__(
            "DuoAgenticChat|This model isn't included in your trial. Purchase monthly credits to continue or select another model.",
          )
        : s__(
            'DuoAgenticChat|Select another model, or contact your administrator to purchase monthly credits.',
          );
    },
    showPurchaseCta() {
      return this.canBuyAddon && Boolean(this.purchaseCreditsPath);
    },
  },
  learnMorePath: helpPagePath('subscriptions/gitlab_credits', { anchor: 'for-the-free-tier' }),
  i18n: {
    purchaseCredits: s__('DuoAgenticChat|Purchase credits'),
    learnMore: s__('DuoAgenticChat|Learn more'),
  },
};
</script>

<template>
  <gl-card data-testid="credit-gated-model-card">
    <template #header>
      <h5 class="gl-heading-5 gl-mb-0" data-testid="credit-gated-model-card-title">
        {{ title }}
      </h5>
    </template>
    <p data-testid="credit-gated-model-card-description">{{ description }}</p>
    <div class="gl-flex gl-gap-3">
      <gl-button
        v-if="showPurchaseCta"
        :href="purchaseCreditsPath"
        variant="confirm"
        category="primary"
        data-testid="purchase-credits-button"
      >
        {{ $options.i18n.purchaseCredits }}
      </gl-button>
      <gl-button :href="$options.learnMorePath" target="_blank" data-testid="learn-more-button">
        {{ $options.i18n.learnMore }}
      </gl-button>
    </div>
  </gl-card>
</template>
