<script>
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { findWorkplanWidget } from 'ee/work_items/utils';
import workItemAgentPlanQuery from 'ee/work_items/graphql/work_item_agent_plan.query.graphql';
import workItemAgentPlanUpdatedSubscription from 'ee/work_items/graphql/work_item_agent_plan.subscription.graphql';
import WorkItemReadinessScore from './work_item_readiness_score.vue';
import WorkItemWorkplan from './work_item_workplan.vue';
import { ACTIVE_RUN_POLL_INTERVAL_MS, GENERATION_STATUSES_ACTIVE } from './constants';

export default {
  name: 'ImplementationWidget',
  components: {
    WorkItemReadinessScore,
    WorkItemWorkplan,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    workItem: {
      type: Object,
      required: true,
    },
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    workItemWebUrl: {
      type: String,
      required: false,
      default: '',
    },
    isInDrawer: {
      type: Boolean,
      required: false,
      default: false,
    },
    isPanelOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['request-panel'],
  data() {
    return {
      workplan: null,
      isRunActive: false,
    };
  },
  apollo: {
    workplan: {
      query: workItemAgentPlanQuery,
      variables() {
        return this.workplanVariables;
      },
      skip() {
        return !this.workItemId;
      },
      update(data) {
        return findWorkplanWidget(data?.workItem) || null;
      },
      error(error) {
        Sentry.captureException(error);
      },
      subscribeToMore: {
        document: workItemAgentPlanUpdatedSubscription,
        variables() {
          return this.workplanVariables;
        },
        skip() {
          return !this.workItemId;
        },
      },
      pollInterval() {
        return this.shouldPollPlan ? ACTIVE_RUN_POLL_INTERVAL_MS : 0;
      },
      // A refetch overwrites by default, which drops every other widget the work item has
      // cached and refetches the whole work item. Merging keeps them, as polling already does.
      refetchWritePolicy: 'merge',
    },
  },
  computed: {
    workItemId() {
      return this.workItem.id;
    },
    useWorkItemFeatures() {
      return Boolean(this.glFeatures?.workItemFeaturesField);
    },
    workplanVariables() {
      return {
        id: this.workItemId,
        useWorkItemFeatures: this.useWorkItemFeatures,
        // Skip resolving readinessScore while workplan_score is disabled.
        includeReadinessScore: this.useScore,
      };
    },
    shouldPollPlan() {
      return (
        this.isRunActive || GENERATION_STATUSES_ACTIVE.includes(this.workplan?.generationStatus)
      );
    },
    isLoadingPlan() {
      return this.$apollo.queries.workplan.loading && !this.workplan;
    },
    useScore() {
      return Boolean(this.glFeatures?.workplanScore);
    },
    readinessScore() {
      return this.workplan?.readinessScore ?? null;
    },
    // The score is only produced after a workplan is generated, so there is nothing to
    // show until then. `useScore` stays flag-only because it also gates the query field.
    showScore() {
      return this.useScore && Number.isFinite(this.readinessScore);
    },
  },
  methods: {
    refetchWorkplan() {
      this.$apollo.queries.workplan.refetch();
    },
  },
};
</script>

<template>
  <div
    class="gl-flex gl-flex-col gl-gap-6 gl-py-6 md:gl-flex-row md:gl-flex-wrap md:gl-items-center md:gl-gap-8"
  >
    <work-item-workplan
      class="gl-shrink-0"
      :work-item="workItem"
      :workplan="workplan"
      :is-loading="isLoadingPlan"
      :can-update="canUpdate"
      :work-item-web-url="workItemWebUrl"
      :is-in-drawer="isInDrawer"
      :is-panel-open="isPanelOpen"
      @request-panel="$emit('request-panel', $event)"
      @refetch-plan="refetchWorkplan"
      @run-active="isRunActive = $event"
    />
    <work-item-readiness-score v-if="showScore && !isLoadingPlan" :score="readinessScore" />
  </div>
</template>
