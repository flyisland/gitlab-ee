<script>
import {
  GlModal,
  GlFormCharacterCount,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
} from '@gitlab/ui';
import { isEqual } from 'lodash-es';
import { __, n__, s__ } from '~/locale';
import { getCurrentUser } from '~/lib/utils/common_utils';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import { isAbsolute, isValidURL } from '~/lib/utils/url_utility';
import {
  DECISION_TITLE_LENGTH_MAX,
  DECISION_DESCRIPTION_LENGTH_MAX,
  DECISION_RATIONALE_LENGTH_MAX,
  DECISION_REMAINING_COUNT_THRESHOLD,
} from './constants';
import DecisionLogDeciderSelect from './decision_log_decider_select.vue';

const emptyFields = () => ({
  title: '',
  resolvedBy: null,
  description: '',
  resolutionRationale: '',
  noteUrl: '',
});

const DISMISS_TRIGGERS = ['cancel', 'headerclose', 'esc', 'backdrop'];

const HOSTNAME_WITH_TLD = /\.[a-z]{2,}$/i;

export default {
  name: 'DecisionLogFormModal',
  components: {
    GlModal,
    GlFormCharacterCount,
    GlFormGroup,
    GlFormInput,
    DecisionLogDeciderSelect,
    GlFormTextarea,
  },
  props: {
    visible: {
      type: Boolean,
      required: false,
      default: false,
    },
    decision: {
      type: Object,
      required: false,
      default: null,
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
  },
  emits: ['hide', 'save'],
  data() {
    return {
      fields: emptyFields(),
      initialFields: emptyFields(),
      selectedDecider: null,
      submitted: false,
    };
  },
  computed: {
    isEditing() {
      return Boolean(this.decision);
    },
    modalTitle() {
      return this.isEditing
        ? s__('WorkItemDecisionLog|Edit decision')
        : s__('WorkItemDecisionLog|New decision');
    },
    actionPrimary() {
      return {
        text: this.isEditing ? __('Save changes') : s__('WorkItemDecisionLog|Create decision'),
        attributes: { variant: 'confirm' },
      };
    },
    currentUser() {
      return getCurrentUser({ useGlobalId: true });
    },
    defaultResolvedBy() {
      return this.currentUser?.id ?? null;
    },
    editedDecider() {
      const { resolvedBy } = this.decision ?? {};

      return typeof resolvedBy === 'object' ? resolvedBy : null;
    },
    seededDecider() {
      return this.isEditing ? this.editedDecider : this.currentUser;
    },
    isNoteUrlReadOnly() {
      return Boolean(this.decision?.noteUrl);
    },
    noteUrlDescription() {
      return this.isNoteUrlReadOnly
        ? s__('WorkItemDecisionLog|Captured automatically from the source and cannot be changed.')
        : s__('WorkItemDecisionLog|Slack, Google Docs, GitLab, or anywhere the discussion lives.');
    },
    isTitleValid() {
      return this.fields.title.trim().length > 0 && !this.isTitleOverLimit;
    },
    isResolvedByValid() {
      return Boolean(this.fields.resolvedBy);
    },
    isDescriptionValid() {
      return this.fields.description.trim().length > 0 && !this.isDescriptionOverLimit;
    },
    isRationaleValid() {
      return !this.isRationaleOverLimit;
    },
    isTitleOverLimit() {
      return this.fields.title.length > DECISION_TITLE_LENGTH_MAX;
    },
    isDescriptionOverLimit() {
      return this.fields.description.length > DECISION_DESCRIPTION_LENGTH_MAX;
    },
    isRationaleOverLimit() {
      return this.fields.resolutionRationale.length > DECISION_RATIONALE_LENGTH_MAX;
    },
    titleInvalidFeedback() {
      return this.isTitleOverLimit
        ? ''
        : s__('WorkItemDecisionLog|Enter a summary of the decision');
    },
    descriptionInvalidFeedback() {
      return this.isDescriptionOverLimit
        ? ''
        : s__('WorkItemDecisionLog|Describe the context for this decision');
    },
    isNoteUrlValid() {
      const noteUrl = this.fields.noteUrl.trim();

      if (!noteUrl) return true;
      if (!isAbsolute(noteUrl) || !isValidURL(noteUrl)) return false;

      return HOSTNAME_WITH_TLD.test(new URL(noteUrl).hostname);
    },
    isValid() {
      return (
        this.isTitleValid &&
        this.isResolvedByValid &&
        this.isDescriptionValid &&
        this.isRationaleValid &&
        this.isNoteUrlValid
      );
    },
    isDirty() {
      return !isEqual(this.fields, this.initialFields);
    },
    discardConfirmMessage() {
      return this.isEditing
        ? s__('WorkItemDecisionLog|Are you sure you want to cancel editing this decision?')
        : s__('WorkItemDecisionLog|Are you sure you want to cancel creating this decision?');
    },
  },
  watch: {
    visible: {
      immediate: true,
      handler(visible) {
        if (visible) {
          this.resetForm();
        }
      },
    },
    decision() {
      this.resetForm();
    },
  },
  methods: {
    resetForm() {
      const { title, resolvedBy, description, resolutionRationale, noteUrl } =
        this.decision ?? emptyFields();

      this.submitted = false;
      this.fields = {
        title: title ?? '',
        resolvedBy: resolvedBy?.id ?? resolvedBy ?? this.defaultResolvedBy,
        description: description ?? '',
        resolutionRationale: resolutionRationale ?? '',
        noteUrl: noteUrl ?? '',
      };
      this.initialFields = { ...this.fields };
      this.selectedDecider = this.seededDecider;
    },
    stateFor(isFieldValid) {
      return this.submitted && !isFieldValid ? false : null;
    },
    overLimitText(count) {
      return n__('%d character over limit.', '%d characters over limit.', count);
    },
    remainingCountText(count) {
      if (count > DECISION_REMAINING_COUNT_THRESHOLD) return '';

      return n__('%d character remaining.', '%d characters remaining.', count);
    },
    onPrimary(event) {
      event.preventDefault();
      this.submitted = true;

      if (!this.isValid) return;

      this.$emit('save', { ...this.fields, resolvedBy: this.selectedDecider });
    },
    async onHide(event) {
      if (!DISMISS_TRIGGERS.includes(event.trigger) || !this.isDirty) return;

      event.preventDefault();

      const confirmed = await confirmAction(this.discardConfirmMessage, {
        primaryBtnText: __('Discard changes'),
        primaryBtnVariant: 'danger',
        cancelBtnText: s__('WorkItemDecisionLog|Continue editing'),
      });

      if (confirmed) {
        this.$emit('hide');
      }
    },
  },
  actionCancel: { text: __('Cancel') },
  modalId: 'decision-log-form-modal',
  noteUrlPlaceholder: 'https://example.com',
  DECISION_TITLE_LENGTH_MAX,
  DECISION_DESCRIPTION_LENGTH_MAX,
  DECISION_RATIONALE_LENGTH_MAX,
};
</script>

<template>
  <gl-modal
    :modal-id="$options.modalId"
    :visible="visible"
    :title="modalTitle"
    :aria-label="modalTitle"
    :action-primary="actionPrimary"
    :action-cancel="$options.actionCancel"
    size="sm"
    @primary="onPrimary"
    @hide="onHide"
    @hidden="$emit('hide')"
  >
    <gl-form-group
      :label="s__('WorkItemDecisionLog|Decision (required)')"
      :state="stateFor(isTitleValid)"
      :invalid-feedback="titleInvalidFeedback"
      label-for="decision-log-summary"
    >
      <gl-form-input
        id="decision-log-summary"
        v-model="fields.title"
        :state="stateFor(isTitleValid)"
        aria-describedby="decision-log-summary-character-count"
        data-testid="decision-summary-input"
      />
      <template #description>
        <gl-form-character-count
          :value="fields.title"
          :limit="$options.DECISION_TITLE_LENGTH_MAX"
          count-text-id="decision-log-summary-character-count"
        >
          <template #remaining-count-text="{ count }">{{ remainingCountText(count) }}</template>
          <template #over-limit-text="{ count }">{{ overLimitText(count) }}</template>
        </gl-form-character-count>
      </template>
    </gl-form-group>

    <gl-form-group
      :label="s__('WorkItemDecisionLog|Decided by (required)')"
      :state="stateFor(isResolvedByValid)"
      :invalid-feedback="s__('WorkItemDecisionLog|Select who made this decision')"
      label-for="decision-log-decided-by"
    >
      <decision-log-decider-select
        id="decision-log-decided-by"
        v-model="fields.resolvedBy"
        :full-path="fullPath"
        :is-group="isGroup"
        :participants="participants"
        :selected-user="seededDecider"
        :is-invalid="stateFor(isResolvedByValid) === false"
        @select-user="selectedDecider = $event"
      />
    </gl-form-group>

    <gl-form-group
      :label="s__('WorkItemDecisionLog|Context (required)')"
      :label-description="
        s__('WorkItemDecisionLog|Background on the decision and any other options considered.')
      "
      :state="stateFor(isDescriptionValid)"
      :invalid-feedback="descriptionInvalidFeedback"
      label-for="decision-log-context"
    >
      <gl-form-textarea
        id="decision-log-context"
        v-model="fields.description"
        :state="stateFor(isDescriptionValid)"
        aria-describedby="decision-log-context-character-count"
        data-testid="decision-context-input"
      />
      <template #description>
        <gl-form-character-count
          :value="fields.description"
          :limit="$options.DECISION_DESCRIPTION_LENGTH_MAX"
          count-text-id="decision-log-context-character-count"
        >
          <template #remaining-count-text="{ count }">{{ remainingCountText(count) }}</template>
          <template #over-limit-text="{ count }">{{ overLimitText(count) }}</template>
        </gl-form-character-count>
      </template>
    </gl-form-group>

    <gl-form-group
      :label="s__('WorkItemDecisionLog|Why')"
      :label-description="
        s__('WorkItemDecisionLog|Rationale for choosing this option over others.')
      "
      :state="stateFor(isRationaleValid)"
      label-for="decision-log-why"
    >
      <gl-form-textarea
        id="decision-log-why"
        v-model="fields.resolutionRationale"
        :state="stateFor(isRationaleValid)"
        aria-describedby="decision-log-why-character-count"
        data-testid="decision-why-input"
      />
      <template #description>
        <gl-form-character-count
          :value="fields.resolutionRationale"
          :limit="$options.DECISION_RATIONALE_LENGTH_MAX"
          count-text-id="decision-log-why-character-count"
        >
          <template #remaining-count-text="{ count }">{{ remainingCountText(count) }}</template>
          <template #over-limit-text="{ count }">{{ overLimitText(count) }}</template>
        </gl-form-character-count>
      </template>
    </gl-form-group>

    <gl-form-group
      class="gl-mb-0"
      :label="s__('WorkItemDecisionLog|Source link')"
      :label-description="noteUrlDescription"
      :state="stateFor(isNoteUrlValid)"
      :invalid-feedback="s__('WorkItemDecisionLog|Enter a full URL, like https://example.com')"
      label-for="decision-log-source-link"
    >
      <gl-form-input
        id="decision-log-source-link"
        v-model="fields.noteUrl"
        type="url"
        :disabled="isNoteUrlReadOnly"
        :state="stateFor(isNoteUrlValid)"
        :placeholder="$options.noteUrlPlaceholder"
        data-testid="decision-source-link-input"
      />
    </gl-form-group>
  </gl-modal>
</template>
