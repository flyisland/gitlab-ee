<script>
import { GlFormGroup, GlFormInputGroup, GlFormSelect } from '@gitlab/ui';
import { phoneNumberRegex } from 'jh/pages/sessions/new/constants';
import { captchaCheck, TENCENT_CAPTCHA_RET_USER_CANCELLED } from 'jh/captcha';
import { checkPhoneAvailability, getVerificationCode } from 'jh/rest_api';
import { i18n, noUserMatchPhoneError, phoneInvalidError } from '../constants';

export default {
  name: 'PhoneForm',
  components: {
    GlFormGroup,
    GlFormSelect,
    GlFormInputGroup,
  },
  i18n,
  data() {
    return {
      phoneNumber: '',
      areaCode: '+86',
      sendingCode: false,
      error: undefined,
    };
  },
  computed: {
    errorMessage() {
      return this.phoneNumber && this.error ? this.error.message : undefined;
    },
    isValidPhone() {
      return phoneNumberRegex[this.areaCode].test(this.phoneNumber);
    },
    submitBtnDisabled() {
      return !this.isValidPhone || this.sendingCode;
    },
    submitBtnText() {
      return this.sendingCode ? i18n.SENDING_CODE : i18n.SEND_CODE;
    },
    completePhoneNumber() {
      return this.areaCode + this.phoneNumber;
    },
  },
  watch: {
    completePhoneNumber() {
      // clear error after user change any part of input
      this.error = this.isValidPhone ? undefined : phoneInvalidError;
    },
  },
  methods: {
    async submitPhone() {
      if (!this.isValidPhone) return;
      this.sendingCode = true;
      let captchaParam;
      try {
        captchaParam = await captchaCheck();
      } catch (res) {
        // there might be some descriptions here for errors
        // other captcha solutions?
        if (res.ret !== TENCENT_CAPTCHA_RET_USER_CANCELLED) this.error = res;
        this.sendingCode = false;
        return;
      }

      try {
        const response = await checkPhoneAvailability(this.completePhoneNumber, () => {});
        if (!response) throw noUserMatchPhoneError;
        this.postForm = {
          phone: this.completePhoneNumber,
        };
      } catch (e) {
        this.error = e;
        this.sendingCode = false;
        return;
      }

      try {
        await getVerificationCode({ ...this.postForm, ...captchaParam });
        this.$emit('sent-code', this.postForm);
      } catch (e) {
        this.error = e;
      }
      this.sendingCode = false;
    },
  },
  areaCodes: Object.keys(phoneNumberRegex).map((code) => {
    return {
      text: code,
      value: code,
    };
  }),
};
</script>

<template>
  <gl-form-group
    :label="$options.i18n.PHONE_NUMBER"
    label-for="input-phone"
    class="form-group gl-px-5 gl-pt-5"
  >
    <gl-form-input-group
      id="input-phone"
      v-model="phoneNumber"
      :placeholder="$options.i18n.REQUIRE_PHONE_NUMBER"
      type="number"
      name="phone"
      required="required"
      autofocus="autofocus"
      input-class="gl-no-spin"
    >
      <template #prepend>
        <gl-form-select
          v-model="areaCode"
          data-testid="form-phone-area-select"
          name="area_code"
          class="gl-rounded-br-none gl-rounded-tr-none"
          :options="$options.areaCodes"
        />
      </template>
    </gl-form-input-group>
    <p v-if="errorMessage" class="form-text gl-my-2 gl-text-red-500" data-testid="error-text">
      {{ errorMessage }}
    </p>
    <p v-else class="form-text gl-my-2 gl-text-gray-500">
      {{ $options.i18n.ENTER_PHONE_NUMBER }}
    </p>
    <button
      class="gl-button btn-confirm btn mt-5 mb-2 gl-mb-0 gl-block gl-w-full"
      :disabled="submitBtnDisabled"
      data-testid="form-phone-submit"
      @click="submitPhone"
    >
      {{ submitBtnText }}
    </button>
  </gl-form-group>
</template>
