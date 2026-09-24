<script>
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { findAgentPlanWidget } from 'ee/work_items/utils';
import workItemAgentPlanQuery from 'ee/work_items/graphql/work_item_agent_plan.query.graphql';
import workItemAgentPlanUpdatedSubscription from 'ee/work_items/graphql/work_item_agent_plan.subscription.graphql';
import WorkItemConfidenceScore from './work_item_confidence_score.vue';
import WorkPlan from './work_plan.vue';

export default {
  name: 'WorkItemAiWidget',
  components: {
    WorkItemConfidenceScore,
    WorkPlan,
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
      agentPlan: null,
    };
  },
  apollo: {
    agentPlan: {
      query: workItemAgentPlanQuery,
      variables() {
        return this.agentPlanVariables;
      },
      skip() {
        return !this.workItemId;
      },
      update(data) {
        return findAgentPlanWidget(data?.workItem) || null;
      },
      error(error) {
        Sentry.captureException(error);
      },
      subscribeToMore: {
        document: workItemAgentPlanUpdatedSubscription,
        variables() {
          return this.agentPlanVariables;
        },
        skip() {
          return !this.workItemId;
        },
      },
    },
  },
  computed: {
    workItemId() {
      return this.workItem.id;
    },
    useWorkItemFeatures() {
      return Boolean(this.glFeatures?.workItemFeaturesField);
    },
    agentPlanVariables() {
      return {
        id: this.workItemId,
        useWorkItemFeatures: this.useWorkItemFeatures,
        // Skip resolving readinessScore while workplan_score is disabled.
        includeReadinessScore: this.showScore,
      };
    },
    isLoadingPlan() {
      return this.$apollo.queries.agentPlan.loading && !this.agentPlan;
    },
    showScore() {
      return Boolean(this.glFeatures?.workplanScore);
    },
    readinessScore() {
      return this.agentPlan?.readinessScore ?? null;
    },
  },
  methods: {
    refetchAgentPlan() {
      this.$apollo.queries.agentPlan.refetch();
    },
  },
};
</script>

<template>
  <div
    class="gl-flex gl-flex-col gl-gap-6 gl-py-6 md:gl-flex-row md:gl-flex-wrap md:gl-items-center md:gl-gap-8"
  >
    <work-plan
      class="gl-shrink-0"
      :work-item="workItem"
      :agent-plan="agentPlan"
      :is-loading="isLoadingPlan"
      :can-update="canUpdate"
      :work-item-web-url="workItemWebUrl"
      :is-in-drawer="isInDrawer"
      :is-panel-open="isPanelOpen"
      @request-panel="$emit('request-panel', $event)"
      @refetch-plan="refetchAgentPlan"
    />
    <work-item-confidence-score v-if="showScore && !isLoadingPlan" :score="readinessScore" />
  </div>
</template>
