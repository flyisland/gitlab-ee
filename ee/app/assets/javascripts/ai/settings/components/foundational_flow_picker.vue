<script>
import { s__, __ } from '~/locale';
import { confirmAction } from '~/lib/utils/confirm_via_gl_modal/confirm_via_gl_modal';
import DuoCodeReviewConsentMessage from './duo_code_review_consent_message.vue';
import FoundationalFlowSelector from './foundational_flow_selector.vue';

const CODE_REVIEW_FLOW_REFERENCE = 'code_review/v1';

export default {
  name: 'FoundationalFlowPicker',
  i18n: {
    codeReviewConfirmationMessage: s__(
      "DuoCodeReview|When you enable Code Review Flow for this namespace, all reviews will consume GitLab Credits, regardless of the user's seat. You can disable Code Review Flow at any time.",
    ),
    codeReviewConfirmationTitle: s__('DuoCodeReview|Enable Code Review Flow for this namespace?'),
    codeReviewConfirmationButton: s__('DuoCodeReview|Enable Code Review Flow'),
  },
  components: {
    DuoCodeReviewConsentMessage,
    FoundationalFlowSelector,
  },
  inject: ['duoEnterpriseActive', 'initialCodeReviewFlowConsentGiven'],
  props: {
    value: {
      type: Array,
      required: true,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['input', 'consent-given'],
  data() {
    return {
      codeReviewFlowConsentGiven: this.initialCodeReviewFlowConsentGiven,
      selectorKey: 0,
    };
  },
  computed: {
    codeReviewFlowSelected() {
      return this.value.includes(CODE_REVIEW_FLOW_REFERENCE);
    },
  },
  methods: {
    async onFlowSelectionChanged(flowIds) {
      const addingCodeReview =
        flowIds.includes(CODE_REVIEW_FLOW_REFERENCE) && !this.codeReviewFlowSelected;

      if (addingCodeReview && this.duoEnterpriseActive && !this.codeReviewFlowConsentGiven) {
        const confirmed = await confirmAction(this.$options.i18n.codeReviewConfirmationMessage, {
          title: this.$options.i18n.codeReviewConfirmationTitle,
          primaryBtnText: this.$options.i18n.codeReviewConfirmationButton,
          primaryBtnVariant: 'confirm',
          cancelBtnText: __('Cancel'),
        });

        if (!confirmed) {
          // Increment the key to remount FoundationalFlowSelector with fresh
          // native DOM state. Vue would otherwise skip the DOM update because
          // :checked on GlFormCheckbox was never seen as false→true→false.
          this.selectorKey += 1;
          return;
        }

        this.codeReviewFlowConsentGiven = true;
        this.$emit('consent-given');
      }

      this.$emit('input', flowIds);
    },
  },
  codeReviewFlowReference: CODE_REVIEW_FLOW_REFERENCE,
};
</script>
<template>
  <foundational-flow-selector
    :key="selectorKey"
    :value="value"
    :disabled="disabled"
    @input="onFlowSelectionChanged"
  >
    <template #after-flow="{ reference }">
      <duo-code-review-consent-message
        v-if="reference === $options.codeReviewFlowReference"
        :code-review-flow-selected="codeReviewFlowSelected"
        :code-review-flow-consent-given="codeReviewFlowConsentGiven"
      />
    </template>
  </foundational-flow-selector>
</template>
