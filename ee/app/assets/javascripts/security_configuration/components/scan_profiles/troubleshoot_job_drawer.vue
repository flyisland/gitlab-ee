<script>
import { GlButton, GlDrawer } from '@gitlab/ui';
import GlSafeHtmlDirective from '~/vue_shared/directives/safe_html';
import { SCAN_PROFILE_CATEGORIES } from '~/security_configuration/constants';
import { s__ } from '~/locale';
import TroubleshootJobData from 'ee/security_configuration/components/scan_profiles/troubleshoot_job_data.vue';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { joinPaths } from '~/lib/utils/url_utility';

export default {
  name: 'TroubleshootJobDrawer',
  components: {
    TroubleshootJobData,
    GlDrawer,
    GlButton,
  },
  directives: {
    SafeHtml: GlSafeHtmlDirective,
  },
  props: {
    openDrawer: {
      type: Boolean,
      required: false,
      default: false,
    },
    drawerData: {
      type: Object,
      required: true,
    },
  },
  emits: ['close-drawer'],
  computed: {
    drawerTitle() {
      return `${this.getScannerMetadata(this.drawerData.scanType).displayName} ${s__('SecurityProfiles|failure')}`;
    },
    redirectButton() {
      return joinPaths(gon.gitlab_url || '', this.drawerData.webPath);
    },
  },
  methods: {
    traceSummary() {
      return this.drawerData.trace?.htmlSummary || s__('SecurityProfiles|No job log');
    },
    getScannerMetadata(scanType) {
      return SCAN_PROFILE_CATEGORIES[scanType] || {};
    },
    viewJobButtonTitle() {
      return `${s__('SecurityProfiles|View job #')}${getIdFromGraphQLId(this.drawerData.buildId)}`;
    },
  },
  allowedConfig: {
    ALLOWED_TAGS: ['span', 'br', 'div'],
  },
};
</script>

<template>
  <gl-drawer
    v-if="drawerData"
    :open="openDrawer"
    :header-sticky="true"
    @close="$emit('close-drawer')"
  >
    <template #title>
      <span class="gl-font-bold">{{ drawerTitle }}</span>
    </template>
    <h3 class="gl-m-2 !gl-pb-0 gl-text-lg">
      {{ s__('SecurityProfiles|Job details') }}
    </h3>
    <troubleshoot-job-data :data="drawerData" :is-drawer="true" />
    <h3 v-if="drawerData.failureMessage" class="gl-m-2 !gl-pb-0 gl-text-lg">
      {{ s__('SecurityProfiles|Failure summary') }}
    </h3>
    <div v-if="drawerData.failureMessage" class="gl-m-2 !gl-pb-0" data-testid="failure-message">
      {{ drawerData.failureMessage }}
    </div>
    <h3 v-if="drawerData.trace?.htmlSummary" class="gl-m-2 !gl-pb-0 gl-text-lg">
      {{ s__('SecurityProfiles|Root cause') }}
    </h3>
    <pre
      v-if="drawerData.trace?.htmlSummary"
      class="gl-m-2 gl-w-full gl-border-none !gl-pb-0 gl-text-left"
    >
        <code
          v-safe-html:[$options.allowedConfig]="traceSummary()" class="gl-bg-inherit gl-p-0"
              data-testid="job-trace-summary">
        </code>
      </pre>
    <h3 v-if="false" class="gl-m-2 !gl-pb-0 gl-text-lg">
      {{ s__('SecurityProfiles|Recommended solution') }}
    </h3>
    <div v-if="false" class="gl-m-2 !gl-pb-0">{{ __('TODO') }}</div>
    <div class="gl-m-2 gl-my-3 !gl-pb-0">
      <gl-button
        category="primary"
        variant="confirm"
        size="small"
        :block="true"
        :href="redirectButton"
        >{{ viewJobButtonTitle() }}</gl-button
      >
    </div>
  </gl-drawer>
</template>
