<script>
import { GlCard, GlButton } from '@gitlab/ui';
import CloudTanukiSvg from '@gitlab/svgs/dist/illustrations/cloud-tanuki-sm.svg';

export default {
  components: {
    GlCard,
    GlButton,
  },
  props: {
    trialPath: {
      type: String,
      required: true,
    },
    exploreOptionsPath: {
      type: String,
      required: true,
    },
  },
  tanukiSvgPath: CloudTanukiSvg,
};
</script>

<template>
  <gl-card class="gl-banner gl-mt-6 gl-py-6 gl-pl-6 gl-pr-8" body-class="gl-flex !gl-p-0">
    <div class="gl-banner-illustration">
      <!-- eslint-disable-next-line @gitlab/vue-require-i18n-attribute-strings -->
      <img :src="$options.tanukiSvgPath" alt="" />
    </div>

    <div class="gl-banner-content">
      <h2 class="gl-banner-title">{{ __('Start a Free Ultimate Trial') }}</h2>
      <p>
        {{
          s__(
            'JH|Trials|This group and its projects under the namespace is using the basic version. Want to increase team productivity and use more advanced features? Try out JiHu GitLab Ultimate for free for 30 days.',
          )
        }}
      </p>
      <gl-button variant="info" category="primary" rel="noreferer noopener" :href="trialPath">
        {{ __('Start free trial') }}
      </gl-button>
      <gl-button variant="default" rel="noreferer noopener" :href="exploreOptionsPath">
        {{ s__('TierBadgePopover|Explore paid plans') }}
      </gl-button>
    </div>
  </gl-card>
</template>
