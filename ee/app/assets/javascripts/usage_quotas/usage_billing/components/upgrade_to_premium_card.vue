<script>
import { GlButton, GlCard } from '@gitlab/ui';

export default {
  name: 'UpgradeToPremiumCard',
  components: {
    GlButton,
    GlCard,
  },
  inject: {
    upgradeButtonPath: { default: null },
  },
};
</script>
<template>
  <gl-card class="gl-flex-1" header-class="gl-heading-scale-400">
    <template #header>
      {{ s__('AiPowered|Unlock more credits with Premium') }}
    </template>
    <div class="gl-flex gl-h-full gl-flex-col gl-justify-between">
      <div>
        {{
          s__(
            'AiPowered|Upgrade to keep using GitLab Duo Agent Platform and access a broad credit allocation.',
          )
        }}
      </div>
      <div class="gl-pt-5">
        <gl-button
          :href="upgradeButtonPath"
          data-event-tracking="click_cta_upgrade_to_premium"
          data-event-property="upgrade_to_premium_card"
        >
          {{ __('Upgrade to Premium') }}
        </gl-button>
      </div>
    </div>
  </gl-card>
</template>
