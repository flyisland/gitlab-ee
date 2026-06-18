<script>
import { GlButton } from '@gitlab/ui';
import { marked } from 'marked';
import { sanitize } from '~/lib/dompurify';
import { strictMarkdownConfig } from '~/lib/utils/text_utility';
import { mergeUrlParams } from '~/lib/utils/url_utility';
import SafeHtml from '~/vue_shared/directives/safe_html';
import { InternalEvents } from '~/tracking';
import { s__ } from '~/locale';

const DEFAULT_PLAN_ID = 'ultimate';
const TRACKING_EVENT_UPGRADE = 'click_upgrade_subscription_duo_chat_tier_access_denied';
const TRACKING_EVENT_LEARN_MORE = 'click_learn_more_duo_chat_tier_access_denied';
const UNKNOWN_PLAN_LABEL = 'unknown_plan';
const PLAN_LABELS = {
  premium: 'premium_plan',
  ultimate: 'ultimate_plan',
};

export default {
  name: 'MessageTierAccessDenied',
  i18n: {
    upgrade: s__('DuoAgenticChat|Upgrade subscription'),
  },
  components: {
    GlButton,
  },
  directives: {
    SafeHtml,
  },
  mixins: [InternalEvents.mixin()],
  inject: {
    canBuyAddon: { default: false },
    tierUpgradePath: { default: '' },
  },
  props: {
    message: {
      required: true,
      type: Object,
    },
  },
  computed: {
    parsedContent() {
      const { content } = this.message;
      if (!content) return '';
      // When upgrade button shows, collapse paragraph breaks so a trailing link
      // (e.g. "Learn more") renders inline with the message instead of below it.
      const source = this.canBuyAddon ? content.replace(/\n+/g, ' ').trim() : content;
      return sanitize(marked.parse(source), strictMarkdownConfig);
    },
    rawRequiredPlan() {
      return this.message.required_plan ?? null;
    },
    purchasePlanId() {
      return this.rawRequiredPlan ?? DEFAULT_PLAN_ID;
    },
    upgradeTrackingLabel() {
      return PLAN_LABELS[this.rawRequiredPlan] ?? UNKNOWN_PLAN_LABEL;
    },
    purchasePath() {
      return mergeUrlParams({ plan_id: this.purchasePlanId }, this.tierUpgradePath);
    },
  },
  methods: {
    onUpgradeClick() {
      this.trackEvent(TRACKING_EVENT_UPGRADE, { label: this.upgradeTrackingLabel });
    },
    onContentClick(event) {
      if (event.target.closest('a')) {
        this.trackEvent(TRACKING_EVENT_LEARN_MORE);
      }
    },
  },
};
</script>

<template>
  <div data-testid="tier-access-denied-message">
    <div v-if="parsedContent" v-safe-html="parsedContent" @click="onContentClick"></div>
    <gl-button v-if="canBuyAddon" :href="purchasePath" target="_blank" @click="onUpgradeClick">
      {{ $options.i18n.upgrade }}
    </gl-button>
  </div>
</template>
