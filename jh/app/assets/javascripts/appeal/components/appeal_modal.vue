<script>
import { GlButton, GlFormTextarea, GlModal } from '@gitlab/ui';
import { createAlert, VARIANT_SUCCESS } from '~/alert';
import { createAppeal } from 'jh/rest_api';
import { APPEAL_MODAL_ID, SUCCESS_MESSAGE, ERROR_MESSAGE } from '../constants';

export default {
  name: 'AppealModal',
  modalId: APPEAL_MODAL_ID,
  components: {
    GlButton,
    GlFormTextarea,
    GlModal,
  },
  data() {
    return {
      id: '',
      projectFullPath: '',
      path: '',
      description: '',
      visible: false,
    };
  },
  computed: {
    submitDisabled() {
      return this.description === '';
    },
  },
  methods: {
    hideModal() {
      this.visible = false;
    },
    submitAppeal() {
      return createAppeal(this.id, { description: this.description })
        .then(() => {
          this.hideModal();
          createAlert({
            variant: VARIANT_SUCCESS,
            message: SUCCESS_MESSAGE,
          });
        })
        .catch(() =>
          createAlert({
            message: ERROR_MESSAGE,
          }),
        );
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    v-model="visible"
    data-qa-selector="appeal_modal"
    :modal-id="$options.modalId"
    :title="s__('JH|ContentValidation|Appeal')"
    size="sm"
  >
    <div class="gl-pb-3">
      <div>{{ s__('JH|ContentValidation|Repository') }} : {{ projectFullPath }}</div>
      <div>{{ s__('JH|ContentValidation|Appealing Target') }}：{{ path }}</div>
    </div>
    <form>
      <gl-form-textarea
        id="appeal-text"
        ref="valueField"
        v-model="description"
        rows="10"
        data-qa-selector="appeal_text_field"
        class="gl-h-32 gl-font-monospace"
        :placeholder="s__('JH|ContentValidation|Write your appeal text here, can be empty')"
        :no-resize="false"
        :style="{ height: '100px' }"
      />
    </form>
    <template #modal-footer>
      <gl-button data-qa-selector="appeal_cancel_button" @click="hideModal">{{
        __('Cancel')
      }}</gl-button>
      <gl-button
        ref="submitAppeal"
        :disabled="submitDisabled"
        variant="confirm"
        category="primary"
        data-qa-selector="appeal_submit_button"
        @click="submitAppeal"
        >{{ s__('JH|ContentValidation|Submit Appeal') }}
      </gl-button>
    </template>
  </gl-modal>
</template>
