<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'HelpCenterUpgradeSubscription',
  components: {
    GlButton,
  },
  i18n: {
    upgradeSubscription: __('Upgrade subscription'),
  },
  inject: ['isIconOnly'],
  props: {
    upgradeLink: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.right="isIconOnly ? $options.i18n.upgradeSubscription : ''"
    class="application-chrome-nav-item super-sidebar-nav-item gl-w-full !gl-justify-start gl-gap-3 !gl-px-2-5"
    category="tertiary"
    icon="license"
    data-testid="sidebar-upgrade-button"
    data-track-action="click_button"
    data-track-label="upgrade_subscription"
    data-track-property="nav_upgrade_subscription"
    :aria-label="$options.i18n.upgradeSubscription"
    :button-text-classes="{
      'gl-w-full gl-flex gl-items-center gl-justify-between !gl-text-default': !isIconOnly,
      'gl-hidden': isIconOnly,
    }"
    :href="upgradeLink"
  >
    {{ $options.i18n.upgradeSubscription }}
  </gl-button>
</template>
