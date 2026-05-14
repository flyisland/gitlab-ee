<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  SCAN_PROFILE_I18N,
  SCAN_PROFILE_SCANNER_HEALTH_FAILED,
  SCAN_PROFILE_SCANNER_HEALTH_WARNING,
} from '~/security_configuration/constants';
import scannerJobDetailsQuery from 'ee/security_configuration/graphql/scan_profiles/scanner_job_details.query.graphql';
import TroubleshootJobData from './troubleshoot_job_data.vue';

export default {
  name: 'JobDetailsPopover',
  components: {
    GlButton,
    GlLoadingIcon,
    TroubleshootJobData,
  },
  mixins: [timeagoMixin],
  props: {
    buildId: {
      type: String,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: true,
    },
  },
  emits: ['open-drawer'],
  data() {
    return {
      jobData: this.getDefaultData(),
      errorMessage: null,
    };
  },
  computed: {
    popoverData() {
      return { ...this.jobData, fullPath: this.projectFullPath };
    },
    isLoading() {
      return this.$apollo.queries.jobData.loading;
    },
    redirectToJobPath() {
      return this.jobData?.webPath ? `${this.jobData.webPath}` : '#';
    },
    configurationButtonTitle() {
      if (this.isFailedOrWarningStatus())
        return this.$options.SCAN_PROFILE_I18N.troubleshootFailure;
      return `${s__('SecurityProfiles|View job #')}${getIdFromGraphQLId(this.buildId)}`;
    },
  },
  SCAN_PROFILE_I18N,
  apollo: {
    jobData: {
      query: scannerJobDetailsQuery,
      variables() {
        return { fullPath: this.projectFullPath, id: this.buildId };
      },
      update: (data) => {
        return data?.project?.job;
      },
      result({ data }) {
        if (!data?.project?.job) this.getMockData();
      },
      error() {
        this.errorMessage = SCAN_PROFILE_I18N.errorLoadingJobData;
      },
    },
  },
  methods: {
    isFailedOrWarningStatus() {
      return [SCAN_PROFILE_SCANNER_HEALTH_WARNING, SCAN_PROFILE_SCANNER_HEALTH_FAILED].includes(
        this.jobData.status,
      );
    },
    getDefaultData() {
      return {
        name: 'dependency-scanner-name',
        status: SCAN_PROFILE_SCANNER_HEALTH_FAILED,
        failureMessage: null,
        // eslint-disable-next-line @gitlab/no-hardcoded-urls
        webPath: '/group/project/-/jobs/123',
        duration: 21,
        finishedAt: '2026-03-27T12:22:00Z',
        source: 'merge_request_event',
        trace: {
          htmlSummary:
            '<span class="term-fg-l-green term-bold">Fetching changes with git depth set to 20...</span><span><br/>Initialized empty Git repository in /builds/gitlab-org/gitlab/.git/<br/></span><span class="term-fg-l-green term-bold">Created fresh repository.</span><span><br/>fatal: remote error: GitLab is currently unable to handle this request due to load (ID 01KMQKWZNG4YE7W05NGFPHF08C).<br/></span><div class="section-start" data-timestamp="1774614118" data-section="cleanup-file-variables" role="button"></div><span class="term-fg-l-cyan term-bold section section-header js-s-cleanup-file-variables">Cleaning up project directory and file based variables</span><span class="section section-header js-s-cleanup-file-variables"><br/></span><div class="section-end" data-section="cleanup-file-variables"></div><span><br/></span><span class="term-fg-l-red term-bold">ERROR: Job failed: exit code 1</span><span><br/></span>',
        },
        pipeline: {
          id: 'gid://gitlab/Ci::Pipeline/456',
          path: '/gitlab-org/gitlab/-/pipelines/456',
        },
      };
    },
    getMockData() {
      this.jobData = this.getDefaultData();
      return this.jobData;
    },
    handleButtonClick() {
      if (this.isFailedOrWarningStatus()) {
        this.$emit('open-drawer', this.jobData);
      }
    },
  },
};
</script>

<template>
  <div>
    <div v-if="isLoading">
      <gl-loading-icon size="md" />
    </div>
    <div v-else-if="errorMessage">{{ errorMessage }}</div>
    <div v-else-if="jobData">
      <troubleshoot-job-data :data="popoverData" />

      <gl-button
        :category="isFailedOrWarningStatus() ? 'primary' : 'secondary'"
        :variant="isFailedOrWarningStatus() ? 'confirm' : 'default'"
        class="gl-my-3 gl-w-full"
        size="small"
        :href="isFailedOrWarningStatus() ? undefined : redirectToJobPath"
        @click="handleButtonClick"
        >{{ configurationButtonTitle }}</gl-button
      >
    </div>
  </div>
</template>
