<script>
import { eventHub, OPEN_AGENT_PLAN_PANEL, GENERATE_AGENT_PLAN } from 'ee/ai/events/panel';
import ReviewWorkplanEmptyState from './review_workplan_empty_state.vue';
import GenerateWorkplanEmptyState from './generate_workplan_empty_state.vue';

export default {
  name: 'WorkplanEmptyStateHeader',
  components: {
    ReviewWorkplanEmptyState,
    GenerateWorkplanEmptyState,
  },
  props: {
    hasExistingWorkplan: {
      type: Boolean,
      required: false,
      default: false,
    },
    resourceId: {
      type: String,
      required: false,
      default: null,
    },
    workItemWebUrl: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    workItemIid: {
      type: [String, Number],
      required: true,
    },
    workItemType: {
      type: String,
      required: true,
    },
    isPanelOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    onViewWorkplan() {
      eventHub.$emit(OPEN_AGENT_PLAN_PANEL);
    },
    onGenerateWorkplan() {
      eventHub.$emit(GENERATE_AGENT_PLAN);
    },
  },
};
</script>

<template>
  <review-workplan-empty-state
    v-if="hasExistingWorkplan"
    :project-path="projectPath"
    :work-item-iid="workItemIid"
    :work-item-type="workItemType"
    :work-item-web-url="workItemWebUrl"
    :is-panel-open="isPanelOpen"
    @view-workplan="onViewWorkplan"
  />
  <generate-workplan-empty-state
    v-else
    :resource-id="resourceId"
    :work-item-web-url="workItemWebUrl"
    @generate-workplan="onGenerateWorkplan"
  />
</template>
