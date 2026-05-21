<script>
import { GlBadge } from '@gitlab/ui';
import DuoWorkflowAction from 'ee_component/ai/shared/widgets/duo_workflow_action.vue';

export default {
  name: 'ResolveWithDuoButton',
  components: {
    DuoWorkflowAction,
    GlBadge,
  },
  props: {
    mr: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    category: {
      type: String,
      required: false,
      default: 'primary',
    },
    variant: {
      type: String,
      required: false,
      default: 'default',
    },
    size: {
      type: String,
      required: false,
      default: 'medium',
    },
  },
  computed: {
    goal() {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return `
        Resolve the merge conflicts in merge request '${this.mr.targetProjectFullPath}!${this.mr.iid}'.

        Your role is to reconcile the two branches' existing changes — not to introduce new behavior. When the branches disagree on the same thing, pick the MR's intent as described in its title, description, and commits.

        When one branch's changes are purely cosmetic (whitespace, quote style, idiomatic refactoring), preserve those alongside the other branch's semantic changes — that's not a behavior change.

        If a resolution is genuinely ambiguous — delete/modify, incompatible add/add — keep the MR mergeable and begin the summary with "⚠️ Needs review:" plus a one-line explanation.

        Directly commit and push. Post a summary comment when done.
      `;
    },
  },
};
</script>

<template>
  <duo-workflow-action
    v-if="mr.canResolveWithAi"
    :project-path="mr.targetProjectFullPath"
    :goal="goal"
    :hover-message="
      s__('MergeConflict|Use GitLab Duo to automatically analyze and resolve merge conflicts')
    "
    :source-branch="mr.sourceBranch"
    workflow-definition="developer/v1"
    :size="size"
    :category="category"
    :variant="variant"
  >
    <span class="gl-hidden @md/panel:gl-inline-flex">{{
      s__('MergeConflict|Resolve with GitLab Duo')
    }}</span>
    <gl-badge variant="neutral">{{ __('Beta') }}</gl-badge>
  </duo-workflow-action>
</template>
