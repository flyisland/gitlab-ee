<script>
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { createAlert } from '~/alert';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import { __, s__, sprintf } from '~/locale';
import { clearDraft, getDraft, updateDraft } from '~/lib/utils/autosave';
import { queryToObject, visitUrl } from '~/lib/utils/url_utility';
import {
  AGENT_PLAN_PANEL,
  DETAIL_VIEW_QUERY_PARAM_NAME,
  I18N_WORK_ITEM_ERROR_UPDATING,
} from '~/work_items/constants';
import { findAgentPlanWidget } from 'ee/work_items/utils';
import { WIDGET_TYPE_AGENT_PLAN } from 'ee/work_items/constants';
import updateWorkItemMutation from '~/work_items/graphql/update_work_item.mutation.graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { eventHub, QUEUE_CHAT_COMMAND, SHOW_NEW_CHAT } from 'ee/ai/events/panel';
import AgentPlanInlineRow from './agent_plan_inline_row.vue';
import AgentPlanPanel from './agent_plan_panel.vue';
import { WORK_PLAN_PROMPT, WORK_PLAN_CHAT_COMMAND } from './constants';

export default {
  name: 'AgentPlan',
  components: {
    AgentPlanInlineRow,
    AgentPlanPanel,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    fullPath: { default: '' },
    hasRemoteFlowsEnabled: { from: 'duoRemoteFlowsAvailability', default: false },
  },
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
      appliedTemplateName: null,
      isEditing: false,
      isSaving: false,
      tmpContent: '',
      draftContent: '',
    };
  },
  computed: {
    workItemId() {
      return this.workItem?.id;
    },
    workItemIid() {
      return this.workItem?.iid;
    },
    workItemType() {
      return this.workItem?.workItemType?.name;
    },
    agentPlanWidget() {
      return findAgentPlanWidget(this.workItem);
    },
    content() {
      return this.agentPlanWidget?.content || '';
    },
    hasSavedContent() {
      return Boolean(this.content);
    },
    planStorageKey() {
      return this.workItemId ? `agent-plan-draft-${this.workItemId}` : null;
    },
    templateStorageKey() {
      // eslint-disable-next-line @gitlab/require-i18n-strings
      return this.planStorageKey ? `${this.planStorageKey}-template` : null;
    },
    optimisticResponse() {
      const existing = this.agentPlanWidget;
      const updatedWidget = {
        ...(existing || { type: WIDGET_TYPE_AGENT_PLAN, __typename: 'WorkItemWidgetAgentPlan' }),
        content: this.tmpContent,
      };
      const editedFeatures = this.workItem?.features
        ? {
            features: {
              ...this.workItem.features,
              agentPlan: { ...this.workItem.features.agentPlan, content: this.tmpContent },
            },
          }
        : {};
      return {
        workItemUpdate: {
          errors: [],
          workItem: {
            ...this.workItem,
            widgets: [
              ...(this.workItem.widgets || []).filter((w) => w.type !== WIDGET_TYPE_AGENT_PLAN),
              updatedWidget,
            ],
            ...editedFeatures,
          },
        },
      };
    },
  },
  created() {
    const { content: storedDraft, templateName } = this.loadFromStorage();
    if (storedDraft) {
      this.draftContent = storedDraft;
    }
    if (templateName) {
      this.appliedTemplateName = templateName;
    }
    if (!this.isInDrawer) {
      const showParam = queryToObject(window.location.search)?.[DETAIL_VIEW_QUERY_PARAM_NAME];
      if (showParam === 'work-plan') {
        this.$emit('request-panel', AGENT_PLAN_PANEL);
      }
    }
  },
  methods: {
    persistField(key, value) {
      if (!key) return;
      if (value) {
        updateDraft(key, value);
      } else {
        clearDraft(key);
      }
    },
    loadFromStorage() {
      return {
        content: this.planStorageKey ? getDraft(this.planStorageKey) : null,
        templateName: this.templateStorageKey ? getDraft(this.templateStorageKey) : null,
      };
    },
    clearStorage() {
      this.persistField(this.planStorageKey, null);
      this.persistField(this.templateStorageKey, null);
    },
    openPanel() {
      if (this.isPanelOpen) {
        this.$emit('request-panel', null);
        return;
      }
      if (this.isInDrawer && this.workItemWebUrl) {
        try {
          visitUrl(`${this.workItemWebUrl}?${DETAIL_VIEW_QUERY_PARAM_NAME}=work-plan`);
          return;
        } catch (e) {
          Sentry.captureException(e);
        }
      }
      // Open in edit mode only when there's no saved content yet — that's
      // the "Create workplan" path. "View workplan" (saved content exists)
      // always opens in view mode regardless of any leftover draft.
      if (this.canUpdate && !this.hasSavedContent) {
        this.isEditing = true;
      }
      this.$emit('request-panel', AGENT_PLAN_PANEL);
    },
    closePanel() {
      this.$emit('request-panel', null);
    },
    ensurePanelOpen() {
      if (!this.isPanelOpen) {
        this.$emit('request-panel', AGENT_PLAN_PANEL);
      }
    },
    handleDraftChange(value) {
      this.draftContent = value || '';
      this.persistField(this.planStorageKey, value);
    },
    // Duo chat is taking over — drop any in-progress edit so the panel
    // re-renders against the soon-to-be-written content rather than
    // stomping the user's stale draft on top of it.
    onAgentHandoff() {
      if (this.isEditing) {
        this.handleCancelEdit();
      }
    },
    showUpdateError(error) {
      createAlert({
        message: sprintf(I18N_WORK_ITEM_ERROR_UPDATING, {
          workItemType: this.workItemType,
        }),
      });
      Sentry.captureException(error);
    },
    async mutateAgentPlanContent() {
      const { data } = await this.$apollo.mutate({
        mutation: updateWorkItemMutation,
        variables: {
          input: {
            id: this.workItemId,
            agentPlanWidget: { content: this.tmpContent },
          },
          useWorkItemFeatures: Boolean(this.glFeatures?.workItemFeaturesField),
        },
        optimisticResponse: this.optimisticResponse,
      });
      if (data.workItemUpdate.errors.length) {
        throw new Error(data.workItemUpdate.errors.join('\n'));
      }
    },
    handleStartEdit() {
      this.isEditing = true;
    },
    handleCancelEdit() {
      this.isEditing = false;
      this.draftContent = '';
      this.persistField(this.planStorageKey, null);
    },
    async handleSave({ content, templateName }) {
      // Defence-in-depth: the panel already trims before emitting, but
      // trimming here too means any future caller (e.g. an automated
      // save from a Duo flow) can't accidentally persist whitespace-only
      // content and flip the inline-row status pill to "Ready".
      this.tmpContent = content?.trim() || '';
      this.isSaving = true;
      try {
        await this.mutateAgentPlanContent();
        this.isEditing = false;
        this.appliedTemplateName = templateName;
        this.draftContent = '';
        this.persistField(this.planStorageKey, null);
        this.persistField(this.templateStorageKey, templateName);
      } catch (error) {
        this.showUpdateError(error);
      } finally {
        this.isSaving = false;
        this.tmpContent = '';
      }
    },
    handleRegenerate() {
      if (this.isEditing) {
        this.handleCancelEdit();
      }
      eventHub.$emit(SHOW_NEW_CHAT);
      eventHub.$emit(QUEUE_CHAT_COMMAND, {
        ...WORK_PLAN_CHAT_COMMAND,
        question: WORK_PLAN_PROMPT,
        resourceId: this.workItemId,
      });
    },
    async handleDelete() {
      const confirmed = await confirmAction(
        s__(
          'AgentPlan|Are you sure you want to delete this workplan? This action cannot be undone.',
        ),
        {
          primaryBtnText: __('Delete'),
          primaryBtnVariant: 'danger',
        },
      );
      if (!confirmed) return;

      this.tmpContent = '';
      this.isSaving = true;
      this.appliedTemplateName = null;
      this.clearStorage();
      try {
        await this.mutateAgentPlanContent();
      } catch (error) {
        this.showUpdateError(error);
      } finally {
        this.isSaving = false;
      }
    },
  },
};
</script>

<template>
  <div>
    <agent-plan-inline-row
      :can-update="canUpdate"
      :is-panel-open="isPanelOpen"
      :project-path="fullPath"
      :has-content="hasSavedContent"
      :has-remote-flows-enabled="hasRemoteFlowsEnabled"
      :work-item-id="workItemId"
      :work-item-iid="workItemIid"
      :work-item-type="workItemType"
      :work-item-web-url="workItemWebUrl"
      @open="openPanel"
      @open-chat-request="ensurePanelOpen"
      @open-chat-completed="onAgentHandoff"
    />
    <agent-plan-panel
      :open="isPanelOpen"
      :saved-content="content"
      :draft-content="draftContent"
      :applied-template-name="appliedTemplateName"
      :can-update="canUpdate"
      :is-editing="isEditing"
      :is-saving="isSaving"
      @start-edit="handleStartEdit"
      @cancel-edit="handleCancelEdit"
      @save="handleSave"
      @delete="handleDelete"
      @regenerate="handleRegenerate"
      @draft-change="handleDraftChange"
      @close="closePanel"
    />
  </div>
</template>
