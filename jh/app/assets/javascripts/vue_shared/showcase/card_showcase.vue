<script>
import { GlButton, GlCard, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlCard,
    GlIcon,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    // The following is used by upstream component, we are simply overriding it
    /* eslint-disable vue/no-unused-properties */
    primaryAction: {
      type: String,
      required: false,
      default: '',
    },
    primaryLink: {
      type: String,
      required: false,
      default: '',
    },
    primaryLinkIcon: {
      type: String,
      required: false,
      default: '',
    },
    primaryTrackingLabel: {
      type: String,
      required: false,
      default: '',
    },
    primaryTrackingProperty: {
      type: String,
      required: false,
      default: '',
    },
    /* eslint-enable vue/no-unused-properties */
    secondaryAction: {
      type: String,
      required: false,
      default: '',
    },
    secondaryLink: {
      type: String,
      required: false,
      default: '',
    },
    secondaryLinkIcon: {
      type: String,
      required: false,
      default: '',
    },
    secondaryTrackingLabel: {
      type: String,
      required: false,
      default: '',
    },
    secondaryTrackingProperty: {
      type: String,
      required: false,
      default: '',
    },
  },
};
</script>

<template>
  <div class="col-xs-12 col-md-5 col-lg-3 showcase-box-container gl-mb-5 gl-mr-5 gl-p-0">
    <gl-card class="showcase-box">
      <div class="gl-flex-row">
        <div class="gl-mb-3">
          <strong class="gl-mb-2 gl-text-gray-800">
            {{ title }}
          </strong>
        </div>
        <p class="gl-text-sm">
          {{ description }}
        </p>
      </div>

      <div class="gl-bottom-0 gl-flex">
        <!-- This button is for "Start a free trial" action -->
        <!-- This is commented on purpose since JiHu does not need the trial button -->
        <!-- <gl-button
          v-if="primaryAction"
          class="gl-mr-2 gl-mb-2"
          category="primary"
          variant="confirm"
          :href="primaryLink"
          target="_blank"
          data-testid="primary-button"
          data-track-="showcase_free_security_features"
          data-track-experiment="showcase_free_security_features"
          data-track-action="click_button"
          :data-track-label="primaryTrackingLabel"
          :data-track-property="primaryTrackingProperty"
        >
          {{ primaryAction }}
          <gl-icon v-if="primaryLinkIcon" :name="primaryLinkIcon" />
        </gl-button> -->

        <gl-button
          v-if="secondaryAction"
          class="gl-mb-2 gl-mr-2"
          category="secondary"
          variant="confirm"
          :href="secondaryLink"
          target="_blank"
          data-testid="secondary-button"
          data-track-experiment="showcase_free_security_features"
          data-track-action="click_button"
          :data-track-label="secondaryTrackingLabel"
          :data-track-property="secondaryTrackingProperty"
        >
          {{ secondaryAction }}
          <gl-icon v-if="secondaryLinkIcon" :name="secondaryLinkIcon" />
        </gl-button>
      </div>
    </gl-card>
  </div>
</template>
