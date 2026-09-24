<script>
import {
  GlButton,
  GlForm,
  GlFormGroup,
  GlFormInputGroup,
  GlFormSelect,
  GlFormCheckbox,
  GlSprintf,
  GlLink,
} from '@gitlab/ui';
import { checkPhoneAvailability, getVerificationCode } from 'jh/rest_api';
import { phoneNumberRegex } from 'jh/pages/sessions/new/constants';
import { captchaCheck } from 'jh/captcha';
import { createAlert } from '~/alert';
import { s__, sprintf } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import csrf from '~/lib/utils/csrf';

export default {
  components: {
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInputGroup,
    GlFormSelect,
    GlFormCheckbox,
    GlSprintf,
    GlLink,
  },
  inject: ['paths', 'oauthUser', 'termsPath'],
  csrf,
  data() {
    return {
      phoneNumber: '',
      phoneAvailabilityMsg: '',
      verificationCode: '',
      verifyingPhone: false,
      errorMsg: '',
      cancelToken: null,
      areaCode: '+86',
      areaCodes: Object.keys(phoneNumberRegex).map((code) => {
        return {
          text: code,
          value: code,
        };
      }),
      resendCounter: null,
      consentAgreed: false,
    };
  },
  computed: {
    isValidPhone() {
      return this.isValidPhoneNumber(this.areaCode, this.phoneNumber);
    },
    buttonText() {
      return this.resendCounter
        ? sprintf(s__('JH|RealName|Resend in %{wait}s'), {
            wait: this.resendCounter,
          })
        : s__('JH|RealName|Get code');
    },
    sendCodeDisabled() {
      const { resendCounter, isValidPhone, phoneAvailabilityMsg } = this;
      return resendCounter !== null || !isValidPhone || !phoneAvailabilityMsg;
    },
    submitDisabled() {
      const { phoneNumber, verificationCode, oauthUser, consentAgreed } = this;

      if (oauthUser && !consentAgreed) {
        return true;
      }

      if (!phoneNumber || !this.isValidPhoneNumber(this.areaCode, phoneNumber)) {
        return true;
      }

      return !verificationCode;
    },
  },
  methods: {
    isValidPhoneNumber(areaCode, phoneNumber) {
      return phoneNumberRegex[areaCode].test(phoneNumber);
    },
    assemblePhoneNumber(areaCode, phoneNumber) {
      return areaCode + phoneNumber;
    },
    async checkPhoneValidity(areaCode, phoneNumber) {
      this.phoneAvailabilityMsg = '';
      if (this.cancelToken !== null) {
        this.cancelToken();
      }
      if (!this.isValidPhoneNumber(areaCode, phoneNumber)) {
        this.errorMsg = s__('JH|RealName|Please provide a valid phone number.');
        return;
      }
      this.errorMsg = '';
      this.verifyingPhone = true;
      try {
        const fullNumber = this.assemblePhoneNumber(areaCode, phoneNumber);
        const exists = await checkPhoneAvailability(fullNumber, (c) => {
          this.cancelToken = c;
        });
        if (exists) {
          this.errorMsg = s__('JH|RealName|Phone is already taken.');
          this.phoneAvailabilityMsg = '';
        } else {
          this.phoneAvailabilityMsg = s__('JH|RealName|Phone is available.');
        }
      } catch (e) {
        if (!axios.isCancel(e)) {
          createAlert({
            message: s__('JH|RealName|An error occurred while validating phone'),
          });
        }
      } finally {
        this.cancelToken = null;
        this.verifyingPhone = false;
      }
    },
    async sendCode() {
      if (!this.phoneAvailabilityMsg) {
        return;
      }
      try {
        const params = await captchaCheck();
        try {
          await getVerificationCode({
            phone: this.assemblePhoneNumber(this.areaCode, this.phoneNumber),
            ...params,
          });
          this.afterVerificationCodeSent();
        } catch (e) {
          createAlert({
            message: e.message,
          });
          this.resendCounter = null;
        }
      } catch {
        createAlert({
          message: s__('JH|RealName|Something happened when resolving captcha'),
        });
      }
    },
    afterVerificationCodeSent() {
      this.resendCounter = 59;
      const timer = setInterval(() => {
        if (this.resendCounter === 0) {
          clearInterval(timer);
          this.resendCounter = null;
          return;
        }
        this.resendCounter -= 1;
      }, 1000);
    },
    submit() {
      this.$refs.formRef.$el.submit();
    },
  },
  i18n: {
    TAndC: s__(
      'JH|SignUp|By clicking %{button_text}, I agree that I have read and accepted the JiHu GitLab %{linkStart}Terms of Use and Privacy Statement%{linkEnd}',
    ),
  },
};
</script>

<template>
  <gl-form
    ref="formRef"
    novalidate
    class="phone-form gl-show-field-errors gl-border gl-rounded-base gl-p-5"
    method="POST"
    :action="paths.accept"
  >
    <gl-form-group :label="s__('JH|RealName|Phone')">
      <gl-form-input-group
        v-model="phoneNumber"
        required
        type="text"
        name="phone"
        data-testid="phone-field"
        data-qa-selector="new_user_phone_field"
        style="border-top-left-radius: 0; border-bottom-left-radius: 0"
        @input="(phoneNumber) => checkPhoneValidity(areaCode, phoneNumber)"
      >
        <template #prepend>
          <gl-form-select
            v-model="areaCode"
            name="area_code"
            :options="areaCodes"
            @change="(areaCode) => checkPhoneValidity(areaCode, phoneNumber)"
          />
        </template>
      </gl-form-input-group>
      <p v-if="errorMsg" class="text-danger gl-my-3">{{ errorMsg }}</p>
      <p v-if="phoneAvailabilityMsg" class="text-success gl-my-3">
        {{ phoneAvailabilityMsg }}
      </p>
      <p v-if="verifyingPhone" class="text gl-my-3">
        {{ s__('JH|RealName|Checking phone availability...') }}
      </p>
    </gl-form-group>
    <gl-form-group :label="s__('JH|RealName|Verification code')" class="verification-code-form">
      <gl-form-input-group
        v-model="verificationCode"
        required
        type="text"
        name="verification_code"
        data-testid="verification-code-field"
        data-qa-selector="new_user_verification_code_field"
      >
        <template #append>
          <gl-button
            class="btn form-control gl-button btn-confirm gl-mb-4 gl-ml-5 gl-block gl-w-auto"
            style="border-top-left-radius: 4px; border-bottom-left-radius: 4px"
            data-testid="send-msg"
            :disabled="sendCodeDisabled"
            @click="sendCode"
          >
            {{ buttonText }}
          </gl-button>
        </template>
      </gl-form-input-group>
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
    </gl-form-group>
    <gl-form-group v-if="oauthUser">
      <gl-form-checkbox v-model="consentAgreed">
        <gl-sprintf :message="$options.i18n.TAndC">
          <template #link="{ content }">
            <gl-link :href="termsPath" rel="noopener noreferer" target="_blank">
              {{ content }}
            </gl-link>
          </template>
          <template #button_text>
            {{ __('Continue') }}
          </template>
        </gl-sprintf>
      </gl-form-checkbox>
    </gl-form-group>
    <gl-button
      :disabled="submitDisabled"
      class="gl-my-3"
      variant="confirm"
      data-testid="verify-phone-number"
      block
      @click="submit"
      >{{ __('Continue') }}</gl-button
    >
    <gl-button
      category="tertiary"
      class="!gl-my-0"
      data-method="POST"
      href="/users/sign_out"
      rel="nofollow"
      variant="info"
      data-testid="sign_out_button"
      block
    >
      {{ __('Sign out') }}
    </gl-button>
  </gl-form>
</template>
