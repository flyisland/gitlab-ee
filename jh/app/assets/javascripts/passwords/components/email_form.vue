<script>
import { GlForm, GlFormGroup, GlFormInput } from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import { i18n } from '../constants';

export default {
  name: 'EmailForm',
  components: {
    GlForm,
    GlFormGroup,
    GlFormInput,
  },
  i18n,
  inject: ['emailFormAction'],
  data() {
    return {
      // The following is used by upstream component, we are simply overriding it
      /* eslint-disable vue/no-unused-properties */
      captchaName: '',
      captchaData: '',
      /* eslint-enable vue/no-unused-properties */
      submitDisabled: false,
    };
  },
  mounted() {
    // from haml: jh/app/views/devise/passwords/new.html.haml
    const captchaElement = document.querySelector('#email-recaptcha');
    if (captchaElement) {
      // testing environment?
      this.$refs['captcha-container'].appendChild(captchaElement);
      captchaElement.classList.remove('hidden');
    }
  },
  csrf,
};
</script>

<template>
  <gl-form
    ref="formRef"
    novalidate
    class="gl-show-field-errors"
    method="POST"
    :action="emailFormAction"
  >
    <gl-form-group
      :label="$options.i18n.EMAIL"
      label-for="input-email"
      class="form-group gl-px-5 gl-pt-5"
      :description="$options.i18n.REQUIRE_EMAIL_ADDRESS"
    >
      <gl-form-input id="input-email" type="email" name="user[email]" required autofocus />
    </gl-form-group>
    <input :value="$options.csrf.token" name="authenticity_token" type="hidden" />
    <div ref="captcha-container" class="gl-px-5" data-testid="captcha-container"></div>
    <div class="gl-p-5">
      <input
        :value="$options.i18n.RESET_PASSWORD"
        class="gl-button btn-confirm"
        type="submit"
        :disabled="submitDisabled"
        data-testid="form-submit-button"
      />
    </div>
  </gl-form>
</template>
