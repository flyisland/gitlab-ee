<script>
import { GlButton, GlIcon, GlSprintf, GlSkeletonLoader } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { __ } from '~/locale';
import MrWidgetAuthorTime from '~/vue_merge_request_widget/components/mr_widget_author_time.vue';
import StatusIcon from '~/vue_merge_request_widget/components/widget/status_icon.vue';
import eventHub from '~/vue_merge_request_widget/event_hub';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import { getMonorepoMergeRequests, mergeMonorepoMergeRequests } from 'jh/rest_api';
import {
  monorepoI18n,
  CAN_MERGE,
  CANNOT_MERGE,
  MERGING,
  MERGED,
  CLOSED,
  MONOREPO_MR_LIST_QUERY_POLLING_INTERVAL_DEFAULT,
} from '../constants';
import MonorepoMrItem from './monorepo_mr_item.vue';
import MonorepoMrPipeline from './monorepo_mr_pipeline.vue';

let pollingIntervalHandle;

export default {
  name: 'MonorepoMr',
  components: {
    GlButton,
    MonorepoMrItem,
    MonorepoMrPipeline,
    MrWidgetAuthorTime,
    StatusIcon,
    GlIcon,
    GlSprintf,
    GlSkeletonLoader,
  },
  mixins: [timeagoMixin],
  data() {
    return {
      loading: true,
      sendingRequestToMerge: false,
      collapsed: false,
      monorepoMr: {}, // TODO: implement monorepo MR request
    };
  },
  computed: {
    canMerge() {
      return this.monorepoMr.merge_requests_list_status === CAN_MERGE;
    },
    cannotMerge() {
      return this.monorepoMr.merge_requests_list_status === CANNOT_MERGE;
    },
    isMerged() {
      return this.monorepoMr.merge_requests_list_status === MERGED;
    },
    isMerging() {
      return this.monorepoMr.merge_requests_list_status === MERGING;
    },
    isClosed() {
      return this.monorepoMr.merge_requests_list_status === CLOSED;
    },
    isMergeTrainInUse() {
      return Boolean(this.monorepoMr.other_merging_topic_label_name);
    },
    mergeDisabled() {
      return (
        this.isMergeTrainInUse || this.cannotMerge || this.sendingRequestToMerge || this.isMerging
      );
    },
    hasAnyError() {
      return this.monorepoMr.merge_requests?.some((mr) => mr.merge_error !== null);
    },
    statusIconName() {
      if (this.canMerge) {
        return 'success';
      }

      if (this.hasAnyError) {
        return 'failed';
      }

      if (this.isMergeTrainInUse) {
        return 'loading';
      }

      return '';
    },
    toggleButtonAriaLabel() {
      return this.collapsed ? __('Expand') : __('Collapse');
    },
  },
  async mounted() {
    this.loading = true;
    await this.fetchMergeRequests();
    this.loading = false;

    if (!this.isMerged) {
      pollingIntervalHandle = setInterval(
        this.fetchMergeRequests,
        MONOREPO_MR_LIST_QUERY_POLLING_INTERVAL_DEFAULT,
      );
    }
  },
  beforeUnmount() {
    if (pollingIntervalHandle) {
      clearInterval(pollingIntervalHandle);
    }
  },
  methods: {
    async fetchMergeRequests() {
      const { source_project_full_path: projectPath, iid } = gl.mrWidgetData;
      try {
        const { data } = await getMonorepoMergeRequests(projectPath, iid);
        this.monorepoMr = data;
        if (this.isMerged && pollingIntervalHandle) {
          clearInterval(pollingIntervalHandle);
        }
      } catch (e) {
        createAlert({
          message: __('Error fetching data. Please try again.'),
        });
      }
    },
    async dispatchMerge() {
      const { source_project_full_path: projectPath, iid } = gl.mrWidgetData;

      try {
        this.sendingRequestToMerge = true;
        await mergeMonorepoMergeRequests(projectPath, iid);
        await this.fetchMergeRequests();
        eventHub.$emit('MRWidgetUpdateRequested');
      } catch {
        createAlert({
          message: monorepoI18n.dispatchMergeError,
        });
      } finally {
        this.sendingRequestToMerge = false;
      }
    },
  },
  i18n: monorepoI18n,
};
</script>

<template>
  <div class="mr-widget-workflow monorepo-mr-widget mr-section-container">
    <div v-if="loading">
      <div class="mr-ready-to-merge-loader mr-widget-body gl-w-full">
        <gl-skeleton-loader :width="418" :height="86">
          <rect x="0" y="0" width="144" height="20" rx="4" />
          <rect x="0" y="26" width="100" height="16" rx="4" />
          <rect x="108" y="26" width="100" height="16" rx="4" />
          <rect x="0" y="48" width="130" height="16" rx="4" />
          <rect x="0" y="70" width="80" height="16" rx="4" />
          <rect x="88" y="70" width="90" height="16" rx="4" />
        </gl-skeleton-loader>
      </div>
    </div>
    <div v-else class="mr-widget-section">
      <div
        class="metadata-wrapper gl-flex gl-items-center gl-justify-between gl-pr-5"
        :class="{
          'gl-bg-blue-50': isMerged,
          'gl-bg-red-50': isClosed,
        }"
      >
        <div v-if="!isMerged" class="mr-widget-content gl-flex gl-flex-1 gl-items-center">
          <gl-button
            v-if="!isClosed && monorepoMr.has_permission_to_merge"
            variant="confirm"
            class="gl-mr-3"
            data-testid="dispatch-merge-btn"
            :disabled="mergeDisabled"
            :loading="isMerging"
            @click="dispatchMerge"
          >
            {{ $options.i18n.mergeAll }}
          </gl-button>
          <template v-if="isClosed">
            <div
              class="gl-mr-3 gl-flex gl-h-6 gl-w-6 gl-self-center"
              data-testid="merge-request-closed"
            >
              <div class="gl-m-auto gl-flex">
                <gl-icon class="gl-text-red-500" name="merge-request-close" />
              </div>
            </div>
            <strong>
              {{ __('Closed') }}
            </strong>
          </template>
          <div class="gl-ml-3 gl-flex gl-items-center">
            <status-icon
              v-if="statusIconName"
              :level="1"
              :icon-name="statusIconName"
              :size="16"
              class="align-self-center gl-mr-3"
            />
            <strong v-if="hasAnyError">{{ $options.i18n.lastMergeFailed }}</strong>
            <strong v-if="canMerge && !isMergeTrainInUse">{{ $options.i18n.readyToMerge }}</strong>
            <span v-if="canMerge && isMergeTrainInUse">
              <gl-sprintf :message="$options.i18n.mergeInQueue">
                <template #branch_name>
                  <strong>
                    <gl-icon name="merge" />
                    {{ monorepoMr.other_merging_topic_label_name }}
                  </strong>
                </template>
              </gl-sprintf>
            </span>
          </div>
        </div>
        <div v-else class="mr-widget-body gl-flex gl-items-center gl-p-5 gl-leading-normal">
          <gl-icon class="gl-mr-3 gl-text-blue-500" name="merge" />
          <mr-widget-author-time
            class="gl-text-sm"
            :action-text="$options.i18n.mergedByUser"
            :author="monorepoMr.merge_user"
            :date-title="tooltipTitle(monorepoMr.merged_at)"
            :date-readable="timeFormatted(monorepoMr.merged_at)"
          />
        </div>

        <div class="gl-ml-3 gl-h-6 gl-border-l-1 gl-border-gray-100 gl-pl-3 gl-border-l-solid">
          <gl-button
            :aria-label="toggleButtonAriaLabel"
            :icon="collapsed ? 'chevron-lg-down' : 'chevron-lg-up'"
            category="tertiary"
            class="gl-align-top"
            data-testid="toggle-merge-requests-btn"
            size="small"
            @click="collapsed = !collapsed"
          />
        </div>
      </div>
      <template v-if="!collapsed">
        <div
          v-for="mr in monorepoMr.merge_requests"
          :key="mr.path"
          class="gl-border-t-1 gl-border-t-gray-100 gl-bg-gray-10 gl-border-t-solid"
        >
          <monorepo-mr-item :mr="mr" />
        </div>
      </template>
      <monorepo-mr-pipeline :pipeline="monorepoMr.central_pipeline" />
    </div>
  </div>
</template>
