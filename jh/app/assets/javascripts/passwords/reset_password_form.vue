<script>
import { GlTab, GlTabs } from '@gitlab/ui';

import EmailForm from './components/email_form.vue';
import PhoneForm from './components/phone_form.vue';
import PhoneCodeVerification from './components/phone_code_verification.vue';
import { i18n } from './constants';

export default {
  name: 'ResetPasswordForm',
  components: {
    PhoneCodeVerification,
    EmailForm,
    PhoneForm,
    GlTab,
    GlTabs,
  },
  i18n,
  data() {
    return {
      isCodeSent: false,
      postForm: {},
      phoneFormOnly: window.location.search.includes('phoneFormOnly'),
    };
  },
  methods: {
    onCodeSent(postForm) {
      this.postForm = postForm;
      this.isCodeSent = true;
      this.$refs.codeVerifyForm.startCountDown();
    },
    onBack() {
      this.isCodeSent = false;
    },
  },
};
</script>

<template>
  <div>
    <gl-tabs v-show="!isCodeSent" justified>
      <div class="login-box">
        <div class="login-body">
          <gl-tab :title="$options.i18n.BY_PHONE">
            <phone-form @sent-code="onCodeSent" />
          </gl-tab>
          <gl-tab v-if="!phoneFormOnly" :title="$options.i18n.BY_EMAIL">
            <email-form />
          </gl-tab>
        </div>
      </div>
    </gl-tabs>
    <phone-code-verification
      v-show="isCodeSent"
      ref="codeVerifyForm"
      :post-form="postForm"
      @back="onBack"
    />
  </div>
</template>
