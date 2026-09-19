<script>
import { GlButton, GlEmptyState, GlSkeletonLoader } from '@gitlab/ui';
import { MountingPortal } from 'portal-vue';
import emptyStateSvg from '@gitlab/svgs/dist/illustrations/empty-state/empty-activity-md.svg';
import DynamicPanel from '~/vue_shared/components/dynamic_panel.vue';
import { createAlert } from '~/alert';
import { n__, s__ } from '~/locale';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import {
  getLocationHash,
  updateHistory,
  setUrlParams,
  removeParams,
} from '~/lib/utils/url_utility';
import { DECISION_LOG_PANEL, DETAIL_VIEW_QUERY_PARAM_NAME } from '~/work_items/constants';
import { getRequestedPanel } from '~/work_items/utils';
import { DECISION_ANCHOR_PREFIX } from './constants';
import DecisionLogFormModal from './decision_log_form_modal.vue';
import DecisionLogItem from './decision_log_item.vue';
import deleteDecisionMutation from './graphql/delete_decision.mutation.graphql';
import updateDecisionMutation from './graphql/update_decision.mutation.graphql';

export default {
  name: 'DecisionLogPanel',
  components: {
    DecisionLogFormModal,
    DecisionLogItem,
    DynamicPanel,
    GlButton,
    GlEmptyState,
    GlSkeletonLoader,
    MountingPortal,
  },
  inheritAttrs: false,
  props: {
    open: {
      type: Boolean,
      required: true,
    },
    workItemId: {
      type: String,
      required: true,
    },
    decisions: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    fullPath: {
      type: String,
      required: false,
      default: '',
    },
    isGroup: {
      type: Boolean,
      required: false,
      default: false,
    },
    participants: {
      type: Array,
      required: false,
      default: () => [],
    },
    workItemWebUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  emits: ['close'],
  data() {
    return {
      isFormVisible: false,
      editedDecision: null,
      // CSS `:target` cannot carry the highlight, because the cards only arrive once this panel
      // has fetched them. The panel tracks the hash so one listener serves every card.
      targetAnchor: getLocationHash() ?? '',
    };
  },
  computed: {
    capturedHeading() {
      return n__('%d decision captured', '%d decisions captured', this.decisions.length);
    },
  },
  watch: {
    open(value) {
      if (value) {
        this.addPanelParam();
      } else {
        this.removePanelParam();
      }
    },
  },
  created() {
    if (this.open) {
      this.addPanelParam();
    }
  },
  mounted() {
    document.addEventListener('keydown', this.handleKeydown);
    window.addEventListener('hashchange', this.readTargetAnchor);
  },
  beforeDestroy() {
    document.removeEventListener('keydown', this.handleKeydown);
    window.removeEventListener('hashchange', this.readTargetAnchor);
  },
  methods: {
    readTargetAnchor() {
      this.targetAnchor = getLocationHash() ?? '';
    },
    addPanelParam() {
      if (getRequestedPanel() === DECISION_LOG_PANEL) return;

      updateHistory({
        url: setUrlParams({ [DETAIL_VIEW_QUERY_PARAM_NAME]: DECISION_LOG_PANEL }),
      });
    },
    // Only clear the param while it still points here, so closing this panel cannot wipe the deep
    // link another panel just wrote. The decision anchor goes with it, so reopening the panel does
    // not highlight whichever card the reader last arrived on.
    removePanelParam() {
      if (getRequestedPanel() !== DECISION_LOG_PANEL) return;

      const url = new URL(removeParams([DETAIL_VIEW_QUERY_PARAM_NAME]));

      if (getLocationHash()?.startsWith(DECISION_ANCHOR_PREFIX)) {
        url.hash = '';
      }

      updateHistory({ url: url.href });
    },
    hasPriorEscapeHandler() {
      const active = document.activeElement;

      return (
        document.body.classList.contains('modal-open') ||
        active?.closest('.js-editor') != null ||
        active?.closest('[contenteditable]:not([contenteditable="false"])') != null ||
        active?.tagName === 'INPUT' ||
        active?.tagName === 'TEXTAREA'
      );
    },
    handleKeydown({ key }) {
      if (key === 'Escape' && this.open && !this.hasPriorEscapeHandler()) {
        this.$emit('close');
      }
    },
    openForm(decision = null) {
      this.editedDecision = decision;
      this.isFormVisible = true;
    },
    closeForm() {
      this.isFormVisible = false;
      this.editedDecision = null;
    },
    saveDecision(fields) {
      if (!this.editedDecision) {
        this.closeForm();
        return;
      }

      this.updateDecision(fields);
    },
    async updateDecision({ title, resolvedBy, description, resolutionRationale, noteUrl }) {
      try {
        const { data } = await this.$apollo.mutate({
          mutation: updateDecisionMutation,
          variables: {
            input: {
              id: this.editedDecision.id,
              title,
              description,
              resolutionRationale,
              noteUrl,
              resolvedBy: {
                id: resolvedBy.id,
                name: resolvedBy.name,
                avatarUrl: resolvedBy.avatarUrl ?? null,
              },
            },
          },
        });

        const [error] = data?.workItemDecisionUpdate?.errors ?? [];
        if (error) throw new Error(error);

        this.closeForm();
      } catch (error) {
        createAlert({
          message: s__(
            'WorkItemDecisionLog|Something went wrong when saving the decision. Please try again.',
          ),
          captureError: true,
          error,
        });
      }
    },
    async confirmRemoval(decision) {
      const confirmed = await confirmAction(
        s__('WorkItemDecisionLog|Are you sure you want to remove this decision?'),
        {
          primaryBtnText: s__('WorkItemDecisionLog|Remove decision'),
          primaryBtnVariant: 'danger',
        },
      );

      if (!confirmed) return;

      try {
        const { data } = await this.$apollo.mutate({
          mutation: deleteDecisionMutation,
          variables: { input: { id: decision.id, workItemId: this.workItemId } },
        });

        const [error] = data?.workItemDecisionDelete?.errors ?? [];
        if (error) throw new Error(error);
      } catch (error) {
        createAlert({
          message: s__(
            'WorkItemDecisionLog|Something went wrong when removing the decision. Please try again.',
          ),
          captureError: true,
          error,
        });
      }
    },
  },
  emptyStateSvg,
};
</script>

<template>
  <mounting-portal v-if="open" mount-to="#contextual-panel-portal" append>
    <dynamic-panel
      :header="s__('WorkItemDecisionLog|Decision log')"
      data-testid="decision-log-panel"
      @close="$emit('close')"
    >
      <gl-skeleton-loader v-if="isLoading" data-testid="decision-log-loading" />
      <template v-else-if="decisions.length">
        <div class="gl-mb-5 gl-mt-4 gl-flex gl-items-center gl-justify-between gl-gap-3">
          <h2 class="gl-heading-3 gl-mb-0" data-testid="decision-log-count">
            {{ capturedHeading }}
          </h2>
          <gl-button size="small" data-testid="new-decision-button" @click="openForm()">
            {{ s__('WorkItemDecisionLog|New decision') }}
          </gl-button>
        </div>
        <ul class="gl-m-0 gl-p-0">
          <decision-log-item
            v-for="decision in decisions"
            :key="decision.id"
            :decision="decision"
            :work-item-web-url="workItemWebUrl"
            :target-anchor="targetAnchor"
            @view-comment="$emit('close')"
            @edit="openForm(decision)"
            @delete="confirmRemoval(decision)"
          />
        </ul>
      </template>
      <gl-empty-state
        v-else
        data-testid="decision-log-empty-state"
        :svg-path="$options.emptyStateSvg"
        :svg-height="144"
        content-class="!gl-px-0"
        :title="s__('WorkItemDecisionLog|No decisions yet')"
        :description="
          s__(
            'WorkItemDecisionLog|Decisions show up here once an open question gets answered or a comment is marked as a decision. Each one keeps the background behind it and a link back to where it was made.',
          )
        "
      >
        <template #actions>
          <gl-button variant="confirm" data-testid="new-decision-button" @click="openForm()">
            {{ s__('WorkItemDecisionLog|New decision') }}
          </gl-button>
        </template>
      </gl-empty-state>

      <decision-log-form-modal
        :visible="isFormVisible"
        :decision="editedDecision"
        :full-path="fullPath"
        :is-group="isGroup"
        :participants="participants"
        @save="saveDecision"
        @hide="closeForm"
      />
    </dynamic-panel>
  </mounting-portal>
</template>
