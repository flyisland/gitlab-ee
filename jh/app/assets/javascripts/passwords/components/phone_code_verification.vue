<script>
import { GlForm, GlFormGroup } from '@gitlab/ui';
import { captchaCheck, TENCENT_CAPTCHA_RET_USER_CANCELLED } from 'jh/captcha';
import { s__, sprintf } from '~/locale';
import { getResetPasswordToken, getVerificationCode } from 'jh/rest_api';
import { i18n } from '../constants';

export default {
  name: 'PhoneCodeVerification',
  components: {
    GlForm,
    GlFormGroup,
  },
  i18n,
  inject: ['phoneFormAction'],
  props: {
    postForm: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      codeInputValues: new Array(6).fill(''),
      sendingCode: false,
      checkingCode: false,
      resetToken: '',
      resendCounter: undefined,
      error: undefined,
    };
  },
  computed: {
    errorMessage() {
      return this.error?.message;
    },
    canResend() {
      return !(this.resendCounter || this.sendingCode);
    },
    resendBtnText() {
      if (this.resendCounter)
        return sprintf(s__('JH|RealName|Resend in %{wait}s'), {
          wait: this.resendCounter,
        });
      if (this.sendingCode) return s__('JH|ResetPassword|Resending code...');
      return s__('JH|ResetPassword|Resend code');
    },
  },
  watch: {
    codeInputValues() {
      if (!this.codeInputValues.includes('')) this.submitCode(this.codeInputValues.join(''));
    },
  },
  methods: {
    focusCodeInputAt(index) {
      this.$refs.inputs[index].focus();
    },
    clearError() {
      this.error = undefined;
    },
    reset() {
      setTimeout(() => {
        this.codeInputValues = new Array(6).fill('');
        this.focusCodeInputAt(0);
      }, 500);
    },
    codeInputHandler(event, index) {
      this.clearError();
      if (event.inputType === 'deleteContentBackward') return;
      let codeInputValue = '';

      // User may paste a long sting at once, here filter non-number characters
      for (let i = 0; i < this.codeInputValues[index].length; i += 1) {
        const str = this.codeInputValues[index][i];
        if (str >= '0' && str <= '9') codeInputValue += str;
      }

      // Fill numbers one by one into the inputs
      let inputPosition = index;
      while (codeInputValue.length > 0 && inputPosition < this.codeInputValues.length) {
        [this.codeInputValues[inputPosition]] = codeInputValue;
        codeInputValue = codeInputValue.slice(1);
        inputPosition += 1;
      }

      if (inputPosition >= this.codeInputValues.length) return;
      this.focusCodeInputAt(inputPosition);
    },
    codeBackspaceHandler(event, index) {
      this.clearError();
      if (this.codeInputValues[index] === '' && index > 0) this.focusCodeInputAt(index - 1);
      else this.codeInputValues[index] = '';
    },
    async resendCode() {
      if (!this.canResend) return;
      this.sendingCode = true;
      const captchaParam = await captchaCheck().catch((res) => {
        if (res.ret !== TENCENT_CAPTCHA_RET_USER_CANCELLED) this.error = res;
      });
      if (captchaParam) {
        await getVerificationCode({ ...this.postForm, ...captchaParam })
          .then(this.startCountDown)
          .catch((e) => {
            this.error = e;
          });
      }
      this.sendingCode = false;
    },
    startCountDown() {
      this.resendCounter = 59;
      const timer = setInterval(() => {
        if (this.resendCounter === 0) {
          clearInterval(timer);
          this.resendCounter = undefined;
          return;
        }
        this.resendCounter -= 1;
      }, 1000);
    },
    async submitCode(code) {
      this.checkingCode = true;

      const token = await getResetPasswordToken({
        phone: this.postForm.phone,
        verification_code: code,
      })
        .then((response) => response.data.token)
        .catch((error) => {
          this.error = new Error(error.response.data.message || i18n.CHECK_CODE_ERROR);
        });

      if (!token) {
        if (!this.error) this.error = new Error(i18n.CHECK_CODE_ERROR);
        this.reset();
        this.checkingCode = false;
      } else {
        this.resetToken = token;
        this.$nextTick(() => this.$refs.formRef.$el.submit());
      }
    },
  },
};
</script>

<template>
  <gl-form ref="formRef" method="GET" :action="phoneFormAction" class="gl-show-field-errors">
    <a class="gl-cursor-pointer hover:!gl-no-underline" @click="$emit('back')"
      >&lt; {{ $options.i18n.BACK }}</a
    >
    <gl-form-group
      :label="$options.i18n.SMS_CODE"
      label-for="input-phone"
      class="form-group gl-px-5 gl-pt-5"
    >
      <p class="form-text gl-my-2 gl-text-gray-500">
        {{ $options.i18n.CODE_FORM_DESCRIPTION }}
      </p>
      <div
        id="root-input-container"
        :class="{ invalid: error }"
        class="gl-w-100p justify-content-around gl-relative gl-flex gl-items-center gl-py-2 gl-font-monospace"
      >
        <input
          v-for="(_, index) in 6"
          ref="inputs"
          :key="index"
          v-model="codeInputValues[index]"
          class="gl-form-input gl-no-spin gl-h-9 gl-w-9 gl-text-center gl-text-size-h1"
          :disabled="checkingCode"
          type="number"
          data-testid="code-inputs"
          @keydown.delete="codeBackspaceHandler($event, index)"
          @input="codeInputHandler($event, index)"
        />
      </div>
      <p class="gl-my-2 gl-text-red-500" data-testid="error-text">{{ errorMessage }} &nbsp;</p>
      <a
        :class="{ 'gl-cursor-not-allowed !gl-text-gray-400 !gl-no-underline': canResend }"
        class="gl-cursor-pointer"
        data-testid="resend-link"
        @click="resendCode"
        >{{ resendBtnText }}</a
      >
    </gl-form-group>
    <input
      :value="resetToken"
      name="reset_password_token"
      hidden="hidden"
      data-testid="reset_password_token"
    />
  </gl-form>
</template>
