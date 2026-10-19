<script>
import { GlButton } from '@gitlab/ui';
import { PROMO_URL } from '~/constants';
import HandRaiseLeadButton from 'ee/hand_raise_leads/hand_raise_lead/components/hand_raise_lead_button.vue';

// The hand-raise lead form exists only on GitLab.com; other instances link to the sales page.
export default {
  name: 'OrbitContactSalesButton',
  components: { GlButton, HandRaiseLeadButton },
  props: {
    saas: { type: Boolean, required: true },
    glmContent: { type: String, required: true },
  },
  buttonAttributes: { category: 'secondary' },
  tracking: { action: 'click_button', label: 'orbit_contact_sales' },
  salesUrl: `${PROMO_URL}/sales/`,
};
</script>

<template>
  <hand-raise-lead-button
    v-if="saas"
    :glm-content="glmContent"
    :button-text="s__('Orbit|Contact sales')"
    :button-attributes="$options.buttonAttributes"
    :cta-tracking="$options.tracking"
    product-interaction="Requested Contact-Orbit"
    data-testid="orbit-contact-sales-button"
  />
  <gl-button
    v-else
    category="secondary"
    :href="$options.salesUrl"
    target="_blank"
    data-testid="orbit-contact-sales-button"
  >
    {{ s__('Orbit|Contact sales') }}
  </gl-button>
</template>
