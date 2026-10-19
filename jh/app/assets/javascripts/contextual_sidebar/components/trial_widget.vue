<script>
import { GlProgressBar, GlLink } from '@gitlab/ui';
import { isEmpty } from 'lodash-es';
import { sprintf } from '~/locale';
import { TRIAL_WIDGET_CONTAINER_ID } from 'ee/contextual_sidebar/components/constants';
import { i18n } from './constants';

// This component overrides ee/app/assets/javascripts/contextual_sidebar/components/trial_widget.vue

export default {
  components: {
    GlProgressBar,
    GlLink,
  },
  i18n,
  TRIAL_WIDGET_CONTAINER_ID,
  computed: {
    percentageComplete() {
      return Math.round((this.trialDaysUsed / this.trialDuration) * 100);
    },
    // The following is used by upstream component, we are simply overriding it
    // eslint-disable-next-line vue/no-unused-properties
    isTrialActive() {
      return this.percentageComplete <= 100;
    },
    widgetRemainingDays() {
      return sprintf(i18n.widgetRemainingDays, {
        daysUsed: this.trialDaysUsed,
        duration: this.trialDuration,
      });
    },
    suspensionData() {
      return window.gon.jh_account_suspension || {};
    },
    trialDaysUsed() {
      return this.suspensionData?.trial_used;
    },
    trialDuration() {
      return this.suspensionData?.duration;
    },
    // eslint-disable-next-line vue/no-unused-properties
    imagePath() {
      return this.suspensionData?.logo_path;
    },
    subscriptionUrl() {
      return this.suspensionData?.billing_path;
    },
    showWidget() {
      return !isEmpty(this.suspensionData);
    },
  },
};
</script>

<template>
  <div
    v-if="showWidget"
    :id="$options.TRIAL_WIDGET_CONTAINER_ID"
    data-testid="trial-widget-menu"
    class="gl-m-2 !gl-items-start gl-rounded-tl-base gl-bg-gray-10 gl-pt-4 gl-shadow"
  >
    <div class="gl-flex gl-w-full gl-flex-col gl-items-stretch">
      <div class="gl-flex gl-w-full gl-items-center">
        <span class="nav-item-name gl-grow">
          {{ $options.i18n.widgetTitle }}
        </span>
      </div>
      <div class="gl-mt-4 gl-text-center">
        <gl-progress-bar
          :value="percentageComplete"
          class="custom-gradient-progress gl-mb-4 gl-bg-purple-50"
          aria-hidden="true"
        />
      </div>

      <div class="gl-flex gl-w-full gl-justify-between">
        <span class="gl-text-sm gl-text-neutral-700">
          {{ widgetRemainingDays }}
        </span>
        <gl-link
          :href="subscriptionUrl"
          class="gl-truncate gl-text-sm gl-font-bold gl-no-underline hover:gl-no-underline"
          size="small"
          data-testid="learn-about-features-btn"
          :title="$options.i18n.learnAboutButtonTitle"
        >
          {{ $options.i18n.upgradeLinkTitle }}
        </gl-link>
      </div>
    </div>
  </div>
</template>
