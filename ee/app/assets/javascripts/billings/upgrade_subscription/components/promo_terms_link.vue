<script>
import { GlLink, GlSprintf } from '@gitlab/ui';

export default {
  name: 'PromoTermsLink',
  components: {
    GlLink,
    GlSprintf,
  },
  props: {
    href: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <p class="gl-mb-0 gl-mt-2 gl-text-sm gl-text-subtle">
    <gl-sprintf
      :message="
        s__('BillingPlans|*Limited time offer. %{linkStart}See details and promo terms.%{linkEnd}')
      "
    >
      <template #link="{ content }">
        <gl-link :href="href" variant="inline" target="_blank">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </p>
</template>
