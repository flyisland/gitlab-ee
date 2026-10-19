<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import ContactSalesButton from '../components/trial/contact_sales_button.vue';
import { PAGE_STATE } from './constants';

export default {
  name: 'OrbitGroupSettingsAlert',
  components: { GlAlert, GlLink, GlSprintf, ContactSalesButton },
  props: {
    state: {
      type: String,
      required: true,
      validator: (value) => Object.values(PAGE_STATE).includes(value),
    },
    groupName: { type: String, required: true },
    saas: { type: Boolean, required: true },
    usageQuotasPath: { type: String, required: true },
  },
  computed: {
    notEligibleTitle() {
      return sprintf(s__('Orbit|%{groupName} is not eligible for a free Orbit trial'), {
        groupName: this.groupName,
      });
    },
    creditsUsedUpTitle() {
      return sprintf(s__('Orbit|%{groupName} is out of GitLab credits'), {
        groupName: this.groupName,
      });
    },
  },
  orbitDocsPath: helpPagePath('integration/orbit'),
  orbitPricingPath: helpPagePath('integration/orbit', { anchor: 'start-a-free-trial' }),
  PAGE_STATE,
};
</script>

<template>
  <gl-alert
    v-if="state === $options.PAGE_STATE.FREE_PLAN"
    variant="info"
    :title="s__('Orbit|Orbit is available on Premium and Ultimate')"
    :dismissible="false"
    data-testid="orbit-free-plan-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|%{groupName} is on the Free plan. Contact sales to upgrade and get Orbit for this group. %{linkStart}Learn more about Orbit%{linkEnd}',
        )
      "
    >
      <template #groupName>{{ groupName }}</template>
      <template #link="{ content }">
        <gl-link :href="$options.orbitDocsPath">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-free-plan" />
    </div>
  </gl-alert>

  <gl-alert
    v-else-if="state === $options.PAGE_STATE.UNLICENSED"
    variant="info"
    :title="s__('Orbit|Orbit is not available for this group')"
    :dismissible="false"
    data-testid="orbit-unlicensed-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|Talk to sales to get Orbit for %{groupName}. %{linkStart}Learn more about Orbit%{linkEnd}',
        )
      "
    >
      <template #groupName>{{ groupName }}</template>
      <template #link="{ content }">
        <gl-link :href="$options.orbitDocsPath">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-unlicensed" />
    </div>
  </gl-alert>

  <gl-alert
    v-else-if="state === $options.PAGE_STATE.CDOT_UNAVAILABLE"
    variant="warning"
    :title="s__('Orbit|Orbit trials are unavailable right now')"
    :dismissible="false"
    data-testid="orbit-unavailable-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|We could not check whether %{groupName} can start a free trial. Try again later, or contact sales if this keeps happening.',
        )
      "
    >
      <template #groupName>{{ groupName }}</template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-unavailable" />
    </div>
  </gl-alert>

  <gl-alert
    v-else-if="state === $options.PAGE_STATE.NOT_ELIGIBLE"
    variant="info"
    :title="notEligibleTitle"
    :dismissible="false"
    data-testid="orbit-not-eligible-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|Free trials are for selected Premium and Ultimate groups. Contact sales to get Orbit for this group. %{linkStart}Learn about Orbit pricing%{linkEnd}',
        )
      "
    >
      <template #link="{ content }">
        <gl-link :href="$options.orbitPricingPath">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-not-eligible" />
    </div>
  </gl-alert>

  <gl-alert
    v-else-if="state === $options.PAGE_STATE.TRIAL_ENDED"
    variant="warning"
    :title="s__('Orbit|Your free Orbit trial has ended')"
    :dismissible="false"
    data-testid="orbit-trial-ended-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|Orbit is paused for %{groupName}. Contact sales to buy GitLab credits and keep using Orbit. %{linkStart}Learn about Orbit pricing%{linkEnd}',
        )
      "
    >
      <template #groupName>{{ groupName }}</template>
      <template #link="{ content }">
        <gl-link :href="$options.orbitPricingPath">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-trial-ended" />
    </div>
  </gl-alert>

  <gl-alert
    v-else-if="state === $options.PAGE_STATE.CREDITS_USED_UP"
    variant="warning"
    :title="creditsUsedUpTitle"
    :dismissible="false"
    data-testid="orbit-no-credits-alert"
  >
    <gl-sprintf
      :message="
        s__(
          'Orbit|Orbit is paused for this group. Contact sales to buy more GitLab credits and keep using Orbit. %{linkStart}View usage quotas%{linkEnd}',
        )
      "
    >
      <template #link="{ content }">
        <gl-link :href="usageQuotasPath">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
    <div class="gl-mt-3">
      <contact-sales-button :saas="saas" glm-content="orbit-credits-used-up" />
    </div>
  </gl-alert>
</template>
