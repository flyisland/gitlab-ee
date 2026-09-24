<script>
import { GlButton } from '@gitlab/ui';
import DuoWorkItemToMrAction from 'ee/ai/shared/widgets/duo_work_item_to_mr_action.vue';
import { WORKPLAN_GOAL_PREFIX, GENERATE_MR_BUTTON_OPTIONS } from './constants';

export default {
  name: 'ReviewWorkplanEmptyState',
  components: {
    GlButton,
    DuoWorkItemToMrAction,
  },
  props: {
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
    workItemWebUrl: {
      type: String,
      required: true,
    },
    isPanelOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['view-workplan'],
  WORKPLAN_GOAL_PREFIX,
  generateMrButtonOptions: GENERATE_MR_BUTTON_OPTIONS,
};
</script>

<template>
  <div>
    <h2 class="gl-heading-2 gl-mb-0" data-testid="workplan-header">
      {{ s__('DuoAgenticChat|Workplan found') }}
    </h2>
    <p class="gl-text-subtle" data-testid="workplan-description">
      {{ s__("DuoAgenticChat|View the workplan and implement it when you're ready.") }}
    </p>
    <div class="gl-flex gl-gap-3">
      <gl-button
        :aria-pressed="String(isPanelOpen)"
        category="secondary"
        data-testid="view-workplan-button"
        @click="$emit('view-workplan')"
      >
        {{ s__('DuoAgenticChat|View') }}
      </gl-button>
      <duo-work-item-to-mr-action
        run-duo-developer-in-chat
        :project-path="projectPath"
        :work-item-iid="workItemIid"
        :work-item-type="workItemType"
        :work-item-web-url="workItemWebUrl"
        :additional-goal-context="$options.WORKPLAN_GOAL_PREFIX"
        :generate-mr-button-options="$options.generateMrButtonOptions"
        data-testid="implement-workplan-button"
      />
    </div>
  </div>
</template>
