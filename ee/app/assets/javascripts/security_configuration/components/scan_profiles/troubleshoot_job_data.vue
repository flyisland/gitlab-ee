<script>
import { GlIcon, GlLink } from '@gitlab/ui';
import {
  statusIcon,
  statusIconClass,
} from 'ee/security_configuration/components/scan_profiles/utils';
import { joinPaths } from '~/lib/utils/url_utility';
import { humanizeTimeInterval } from '~/lib/utils/datetime/date_format_utility';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { SCAN_PROFILE_SOURCE_LABELS } from '~/security_configuration/constants';

export default {
  name: 'TroubleshootJobData',
  components: {
    GlIcon,
    GlLink,
  },
  mixins: [timeagoMixin],
  props: {
    data: {
      type: Object,
      required: true,
    },
    isDrawer: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    getIdFromGraphQLId,
    statusIconClass,
    statusIcon,
    formattedDuration() {
      return humanizeTimeInterval(this.data.duration);
    },
    linkToJobPath() {
      return joinPaths(gon.gitlab_url || '', this.data.webPath);
    },
    linkToPipelinePath() {
      return joinPaths(gon.gitlab_url || '', this.data.pipeline.path);
    },
    getJobId() {
      const parts = this.data.webPath.split('/');
      return parts.pop();
    },
    getFinishedTime() {
      return this.timeFormatted(this.data.finishedAt);
    },
    formattedSource() {
      return SCAN_PROFILE_SOURCE_LABELS[this.data.source] || this.data.source;
    },
  },
};
</script>

<template>
  <div class="gl-m-2 gl-mt-0 !gl-pb-0">
    <div class="gl-my-2" :class="{ 'gl-my-3': isDrawer }">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Name') }}:</span>
      <span>{{ data.name }}</span>
    </div>
    <div class="gl-my-2" :class="{ 'gl-my-3': isDrawer }">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Status') }}:</span>
      <gl-icon
        data-testid="status-icon"
        :name="statusIcon(data.status)"
        :class="statusIconClass(data.status)"
        class="gl-self-start"
      />
      <span>{{ data.status }}</span>
    </div>
    <div class="gl-my-2" :class="{ 'gl-my-3': isDrawer }">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Duration') }}:</span>
      <span>{{ formattedDuration() }}</span>
    </div>
    <div class="gl-my-2" :class="{ 'gl-my-3': isDrawer }">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Source') }}:</span>
      <span>{{ formattedSource() }}</span>
    </div>
    <div v-if="isDrawer" class="gl-my-3">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Finished') }}:</span>
      <span>{{ getFinishedTime() }}</span>
    </div>
    <div class="gl-my-2" :class="{ 'gl-my-3': isDrawer }">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Pipeline') }}:</span>
      <gl-link :href="linkToPipelinePath()">#{{ getIdFromGraphQLId(data.pipeline.id) }}</gl-link>
    </div>
    <div v-if="isDrawer" class="gl-my-3">
      <span class="gl-font-bold" data-testid="scanner-title">{{ __('Job') }}:</span>
      <gl-link :href="linkToJobPath()"> #{{ getJobId() }}</gl-link>
    </div>
  </div>
</template>
