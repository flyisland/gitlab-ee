<script>
import { GlAlert, GlLink } from '@gitlab/ui';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  AI_CATALOG_TYPE_AGENT,
  AI_CATALOG_TYPE_FLOW,
  AI_CATALOG_TYPE_THIRD_PARTY_FLOW,
  AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS,
} from '../constants';

export default {
  name: 'AiCatalogItemConsumerWarning',
  docsUrl: helpPagePath('user/duo_agent_platform/composite_identity'),
  components: {
    GlAlert,
    GlLink,
  },
  props: {
    itemType: {
      type: String,
      required: true,
      validator: (value) =>
        [AI_CATALOG_TYPE_AGENT, AI_CATALOG_TYPE_FLOW, AI_CATALOG_TYPE_THIRD_PARTY_FLOW].includes(
          value,
        ),
    },
    canEnable: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    warningTexts() {
      return AI_CATALOG_ITEM_CONSUMER_WARNING_TEXTS[this.itemType];
    },
    showFullWarning() {
      return this.canEnable;
    },
    isAgent() {
      return this.itemType === AI_CATALOG_TYPE_AGENT;
    },
  },
};
</script>

<template>
  <gl-alert variant="warning" :dismissible="false">
    <template v-if="showFullWarning">
      <!-- Agent warning: simple list format -->
      <template v-if="isAgent">
        <ul class="gl-pl-5">
          <li>{{ warningTexts.fullWarningIntro }}</li>
          <li>{{ warningTexts.fullWarningAccess }}</li>
          <li>
            {{ warningTexts.fullWarningCaution }}
            <gl-link :href="$options.docsUrl">{{
              s__('AICatalog|Learn more about composite identity.')
            }}</gl-link
            >.
          </li>
        </ul>
      </template>

      <!-- Flow and Third-party flow warning: detailed format with composite identity -->
      <template v-else>
        <div>
          <p class="gl-mb-0">{{ warningTexts.fullWarningIntro }}</p>
          <ul class="gl-pl-5">
            <li>{{ warningTexts.fullWarningBullet1 }}</li>
            <li>{{ warningTexts.fullWarningBullet2 }}</li>
          </ul>
        </div>
        <p>{{ warningTexts.fullWarningCompositeIdentity }}</p>
        <div>
          <p class="gl-mb-0">{{ warningTexts.fullWarningAccessIntro }}</p>
          <ul class="gl-pl-5">
            <li>{{ warningTexts.fullWarningAccessBullet1 }}</li>
            <li>{{ warningTexts.fullWarningAccessBullet2 }}</li>
          </ul>
        </div>

        <p class="gl-mb-0">
          {{ warningTexts.fullWarningCaution }}
          <gl-link :href="$options.docsUrl">{{
            s__('AICatalog|Learn more about composite identity.')
          }}</gl-link
          >.
        </p>
      </template>
    </template>

    <!-- Restricted warning when user doesn't have permission -->
    <div v-else>
      <p>{{ warningTexts.restrictedWarning }}</p>
    </div>
  </gl-alert>
</template>
