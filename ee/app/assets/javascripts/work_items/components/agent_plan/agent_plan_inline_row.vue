<script>
import { GlButton, GlButtonGroup, GlDisclosureDropdown } from '@gitlab/ui';
import { s__ } from '~/locale';
import DuoChatQuickAction from 'ee/ai/shared/widgets/duo_chat_quick_action.vue';
import DuoWorkItemToMrAction from 'ee/ai/shared/widgets/duo_work_item_to_mr_action.vue';
import { WORK_PLAN_CHAT_COMMAND } from './constants';

// Extra goal context passed to the "Generate MR with Duo" action so the
// agent treats the saved workplan as the primary spec instead of starting
// from the work-item description. Copied verbatim from the inline widget
// version that lived in the orchestrator pre-side-panel.
const WORKPLAN_GOAL_PREFIX =
  'The work item has an agent_plan widget containing a workplan authored for you. Treat that plan as the primary specification: define your tasks and approach from it, and only fall back to the description or comments for additional context when the plan is unclear.';

export default {
  name: 'AgentPlanInlineRow',
  components: {
    GlButton,
    GlButtonGroup,
    GlDisclosureDropdown,
    DuoChatQuickAction,
    DuoWorkItemToMrAction,
  },
  props: {
    hasContent: {
      type: Boolean,
      required: false,
      default: false,
    },
    canUpdate: {
      type: Boolean,
      required: false,
      default: false,
    },
    isPanelOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
    workItemId: {
      type: String,
      required: false,
      default: null,
    },
    workItemIid: {
      type: String,
      required: false,
      default: null,
    },
    workItemType: {
      type: String,
      required: false,
      default: null,
    },
    workItemWebUrl: {
      type: String,
      required: false,
      default: '',
    },
    hasRemoteFlowsEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    projectPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['open', 'open-chat-request', 'open-chat-completed'],
  computed: {
    statusLabel() {
      if (!this.hasContent) {
        return this.canUpdate ? s__('AgentPlan|Not yet created') : s__('AgentPlan|No workplan');
      }
      return s__('AgentPlan|Ready to view');
    },
    showCreateAction() {
      return !this.hasContent && this.canUpdate;
    },
    showWorkplanToggle() {
      return this.hasContent;
    },
    showCreateWorkPlanAction() {
      return !this.hasContent && this.canUpdate && Boolean(this.workItemId);
    },
    showGenerateMrAction() {
      return this.hasRemoteFlowsEnabled && this.hasContent;
    },
    showActionsDivider() {
      return this.showWorkplanToggle && this.showGenerateMrAction;
    },
  },
  createWorkplanDropdownItems: [
    {
      text: s__('AgentPlan|Create manually'),
      extraAttrs: {
        'data-testid': 'create-workplan-dropdown-item',
      },
    },
  ],
  duoQuickAction: {
    command: WORK_PLAN_CHAT_COMMAND,
    tracking: { label: 'create_work_plan' },
    buttonOptions: { size: 'small' },
  },
  WORKPLAN_GOAL_PREFIX,
  generateMrButtonOptions: { size: 'small', variant: 'confirm', category: 'primary' },
};
</script>

<template>
  <div
    data-testid="agent-plan-inline-row"
    class="gl-border gl-relative gl-flex gl-w-fit gl-flex-wrap gl-items-center gl-justify-between gl-gap-x-6 gl-gap-y-4 gl-rounded-2xl gl-border-subtle gl-p-5"
  >
    <div class="gl-flex-row">
      <span
        class="gl-relative gl-mb-2 gl-block gl-h-2 gl-w-5 gl-rounded-sm"
        :style="{
          backgroundColor: hasContent
            ? 'var(--gl-icon-color-success)'
            : 'var(--gl-status-neutral-background-color)',
        }"
        role="status"
        :aria-label="statusLabel"
      ></span>
      <div class="gl-flex gl-items-center gl-gap-2 gl-text-sm">
        <span class="gl-font-bold gl-text-default">{{ s__('AgentPlan|Workplan:') }}</span>
        <span class="gl-text-subtle">{{ statusLabel }}</span>
      </div>
    </div>
    <div class="gl-flex gl-flex-wrap gl-items-center gl-gap-5">
      <gl-button
        v-if="showCreateAction && !showCreateWorkPlanAction"
        category="primary"
        variant="default"
        size="small"
        data-testid="open-agent-plan-button"
        @click="$emit('open')"
      >
        {{ s__('AgentPlan|Create workplan') }}
      </gl-button>
      <gl-button
        v-else-if="showWorkplanToggle"
        :aria-pressed="String(isPanelOpen)"
        size="small"
        category="secondary"
        data-testid="open-agent-plan-button"
        @click="$emit('open')"
      >
        {{ s__('AgentPlan|View workplan') }}
      </gl-button>
      <div
        v-if="showActionsDivider"
        data-testid="duo-divider"
        class="gl-border-l gl-h-6 gl-border-subtle"
      ></div>
      <gl-button-group v-if="showCreateWorkPlanAction">
        <duo-chat-quick-action
          :resource-id="workItemId"
          :button-text="s__('AgentPlan|Generate workplan')"
          :command="$options.duoQuickAction.command"
          :tracking-info="$options.duoQuickAction.tracking"
          :button-options="$options.duoQuickAction.buttonOptions"
          data-testid="inline-generate-with-duo-button"
          @click="$emit('open-chat-request')"
          @chat-opened="$emit('open-chat-completed')"
        />
        <gl-disclosure-dropdown
          :items="$options.createWorkplanDropdownItems"
          :toggle-text="s__('AgentPlan|More options')"
          text-sr-only
          size="small"
          placement="bottom-end"
          data-testid="create-workplan-dropdown"
          @action="$emit('open')"
        />
      </gl-button-group>
      <duo-work-item-to-mr-action
        v-if="showGenerateMrAction"
        run-duo-developer-in-chat
        :project-path="projectPath"
        :work-item-iid="workItemIid"
        :work-item-type="workItemType"
        :work-item-web-url="workItemWebUrl"
        :additional-goal-context="$options.WORKPLAN_GOAL_PREFIX"
        :generate-mr-button-options="$options.generateMrButtonOptions"
        data-testid="generate-mr-with-duo"
      />
    </div>
  </div>
</template>
