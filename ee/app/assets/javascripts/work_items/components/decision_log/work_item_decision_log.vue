<script>
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import { visitUrl } from '~/lib/utils/url_utility';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { DECISION_LOG_PANEL, DETAIL_VIEW_QUERY_PARAM_NAME } from '~/work_items/constants';
import { findParticipantsWidget, getRequestedPanel } from '~/work_items/utils';
import workItemParticipantsQuery from '~/work_items/graphql/work_item_participants.query.graphql';
import DecisionLogHeaderButton from './decision_log_header_button.vue';
import DecisionLogPanel from './decision_log_panel.vue';
import decisionLogQuery from './graphql/decision_log.query.graphql';

export default {
  name: 'WorkItemDecisionLog',
  components: {
    DecisionLogHeaderButton,
    DecisionLogPanel,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    fullPath: {
      default: '',
    },
    isGroup: {
      default: false,
    },
  },
  props: {
    workItem: {
      type: Object,
      required: true,
    },
    workItemWebUrl: {
      type: String,
      required: false,
      default: '',
    },
    hasPanelPortal: {
      type: Boolean,
      required: true,
    },
    isPanelOpen: {
      type: Boolean,
      required: true,
    },
  },
  emits: ['request-panel'],
  data() {
    return {
      decisions: [],
      participants: [],
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.decisions.loading;
    },
    shouldHandOffToFullPage() {
      return !this.hasPanelPortal && Boolean(this.workItemWebUrl);
    },
  },
  apollo: {
    participants: {
      query: workItemParticipantsQuery,
      variables() {
        return {
          fullPath: this.fullPath,
          iid: this.workItem.iid,
          useWorkItemFeatures: Boolean(this.glFeatures?.workItemFeaturesField),
        };
      },
      skip() {
        return !this.fullPath || !this.workItem.iid;
      },
      update({ namespace }) {
        return findParticipantsWidget(namespace?.workItem)?.participants?.nodes ?? [];
      },
      error(error) {
        Sentry.captureException(error);
      },
    },
    decisions: {
      query: decisionLogQuery,
      variables() {
        return { fullPath: this.fullPath, iid: this.workItem.iid };
      },
      skip() {
        return !this.fullPath;
      },
      update({ namespace }) {
        return namespace?.workItem?.features?.decisionLog?.decisions?.nodes ?? [];
      },
      error(error) {
        createAlert({
          message: s__(
            'WorkItemDecisionLog|Something went wrong when fetching the decision log. Please try again.',
          ),
          captureError: true,
          error,
        });
      },
    },
  },
  created() {
    if (!this.hasPanelPortal) return;

    window.addEventListener('popstate', this.syncPanelFromUrl);
    if (getRequestedPanel() === DECISION_LOG_PANEL && !this.isPanelOpen) {
      this.$emit('request-panel', DECISION_LOG_PANEL);
    }
  },
  beforeDestroy() {
    window.removeEventListener('popstate', this.syncPanelFromUrl);
  },
  methods: {
    syncPanelFromUrl() {
      const requested = getRequestedPanel();

      if (requested === DECISION_LOG_PANEL && !this.isPanelOpen) {
        this.$emit('request-panel', DECISION_LOG_PANEL);
      } else if (!requested && this.isPanelOpen) {
        this.$emit('request-panel', null);
      }
    },
    handOffToFullPage() {
      try {
        visitUrl(`${this.workItemWebUrl}?${DETAIL_VIEW_QUERY_PARAM_NAME}=${DECISION_LOG_PANEL}`);
      } catch (error) {
        Sentry.captureException(error);
        this.$emit('request-panel', DECISION_LOG_PANEL);
      }
    },
    openPanel() {
      if (this.shouldHandOffToFullPage) {
        this.handOffToFullPage();
        return;
      }

      this.$emit('request-panel', DECISION_LOG_PANEL);
    },
    closePanel() {
      this.$emit('request-panel', null);
    },
  },
};
</script>

<template>
  <div class="gl-flex">
    <decision-log-header-button
      :count="decisions.length"
      :is-panel-open="isPanelOpen"
      @open="openPanel"
      @close="closePanel"
    />
    <decision-log-panel
      :open="isPanelOpen"
      :work-item-id="workItem.id"
      :decisions="decisions"
      :is-loading="isLoading"
      :full-path="fullPath"
      :is-group="isGroup"
      :participants="participants"
      :work-item-web-url="workItemWebUrl"
      @close="closePanel"
    />
  </div>
</template>
