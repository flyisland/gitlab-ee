<script>
import { GlDisclosureDropdownGroup, GlDisclosureDropdownItem, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { createAlert } from '~/alert';
import { PROMO_URL } from '~/constants';
import { USER_MENU_TRACKING_DEFAULTS } from '~/super_sidebar/constants';
import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';

export default {
  name: 'UserMenuUpgradeSubscription',
  components: {
    GlDisclosureDropdownGroup,
    GlDisclosureDropdownItem,
    GlIcon,
  },
  props: {
    upgradeLink: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      disabled: false,
    };
  },
  computed: {
    upgradeSubscriptionItem() {
      return {
        text: this.upgradeLink.text,
        extraAttrs: {
          ...USER_MENU_TRACKING_DEFAULTS,
          'data-track-label': 'upgrade_subscription',
          disabled: this.disabled,
        },
      };
    },
    alertParams() {
      return {
        title: this.$options.i18n.title,
        message: this.$options.i18n.message,
        messageLinks: { link: { href: this.$options.pricingLink, target: '_blank' } },
        primaryButton: {
          text: this.$options.i18n.primaryButtonText,
          clickHandler: this.transferPersonalProject,
        },
      };
    },
  },
  methods: {
    async transferPersonalProject() {
      try {
        this.disabled = true;

        const { data } = await axios.put(this.upgradeLink.url);

        visitUrl(data.redirect_to);
      } catch (error) {
        createAlert(this.alertParams);
      } finally {
        this.disabled = false;
      }
    },
    onClick() {
      if (this.upgradeLink.is_personal_project) {
        this.transferPersonalProject();
      } else {
        visitUrl(this.upgradeLink.url);
      }
    },
  },
  i18n: {
    title: s__('UpgradeSubscription|Billing page is not available'),
    message: s__(
      'UpgradeSubscription|An error occurred while assigning your project to a group for billing. Try again or %{linkStart}learn more about pricing%{linkEnd}.',
    ),
    primaryButtonText: s__('UpgradeSubscription|Try again'),
  },
  pricingLink: `${PROMO_URL}/pricing`,
};
</script>

<template>
  <gl-disclosure-dropdown-group bordered>
    <gl-disclosure-dropdown-item
      :item="upgradeSubscriptionItem"
      data-testid="upgrade-subscription-item"
      @action="onClick"
    >
      <template #list-item>
        <span class="hotspot-pulse gl-flex gl-items-center gl-gap-2">
          <gl-icon name="license" variant="subtle" class="gl-mr-2" />
          {{ upgradeSubscriptionItem.text }}
        </span>
      </template>
    </gl-disclosure-dropdown-item>
  </gl-disclosure-dropdown-group>
</template>
