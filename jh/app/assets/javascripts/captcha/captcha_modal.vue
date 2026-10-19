<script>
import { GlModal } from '@gitlab/ui';
import { uniqueId } from 'lodash-es';
import { __ } from '~/locale';
import TencentCaptchaButton from './tencent/captcha_button.vue';
import GeetestCaptchaButton from './geetest/captcha_button.vue';

export default {
  components: {
    GlModal,
    TencentCaptchaButton,
    GeetestCaptchaButton,
  },
  props: {
    needsCaptchaResponse: {
      type: Boolean,
      required: false,
      default: false,
    },
    captchaSiteKey: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      modalId: uniqueId('captcha-modal-'),
    };
  },
  computed: {
    actionCancel() {
      return { text: __('Cancel') };
    },
    tencentCaptchaReplacementEnabled() {
      return gon.tencent_captcha_replacement_enabled;
    },
    geetestCaptchaReplacementEnabled() {
      return gon.geetest_captcha_replacement_enabled;
    },
  },
  watch: {
    needsCaptchaResponse(val) {
      // If this is true, we need to present the captcha modal to the user.
      // When the modal is shown we will also initialize and render the form.
      if (val) {
        this.toggleModal(true);
      }
    },
  },
  mounted() {
    // If this is true, we need to present the captcha modal to the user.
    // When the modal is shown we will also initialize and render the form.
    if (this.needsCaptchaResponse) {
      this.toggleModal(true);
    }
  },
  methods: {
    toggleModal(visibility = false) {
      if (visibility) {
        this.$refs.modal.show();
      } else {
        this.$refs.modal.hide();
      }
    },
    emitReceivedCaptchaResponse(captchaResponse) {
      this.toggleModal(false);
      this.$emit('receivedCaptchaResponse', captchaResponse);
    },
    emitNullReceivedCaptchaResponse() {
      this.emitReceivedCaptchaResponse(null);
    },
    /**
     * handler for when modal is shown
     */
    loadErrorHandler() {
      this.emitNullReceivedCaptchaResponse();
      this.toggleModal(false);
    },
    /**
     * handler for when modal is about to hide
     */
    hide(bvModalEvent) {
      // If hide() was called without any argument, the value of trigger will be null.
      // See https://bootstrap-vue.org/docs/components/modal#prevent-closing
      if (bvModalEvent.trigger) {
        this.emitNullReceivedCaptchaResponse();
      }
    },
  },
};
</script>
<template>
  <!-- Note: The action-cancel button isn't necessary for the functionality of the modal, but   -->
  <!-- there must be at least one button or focusable element, or the gl-modal fails to render. -->
  <!-- We could modify gl-model to remove this requirement.                                     -->
  <gl-modal
    ref="modal"
    :modal-id="modalId"
    :title="__('Please solve the captcha')"
    :action-cancel="actionCancel"
    @hide="hide"
    @hidden="$emit('hidden')"
  >
    <geetest-captcha-button
      v-if="geetestCaptchaReplacementEnabled"
      :captcha-site-key="captchaSiteKey"
      @loadError="loadErrorHandler"
      @receivedCaptchaResponse="emitReceivedCaptchaResponse"
    />
    <tencent-captcha-button
      v-else-if="tencentCaptchaReplacementEnabled"
      :captcha-site-key="captchaSiteKey"
      @loadError="loadErrorHandler"
      @receivedCaptchaResponse="emitReceivedCaptchaResponse"
    />
    <p>{{ __('We want to be sure it is you, please confirm you are not a robot.') }}</p>
  </gl-modal>
</template>
