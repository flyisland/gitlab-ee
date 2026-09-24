<script>
import { uniqueId } from 'lodash-es';
import { initGeetestCaptchaScript } from 'jh/captcha/geetest/init_script';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';

export default {
  props: {
    captchaSiteKey: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      captchaResponse: '',
      buttonClass: uniqueId('geetest-captcha-button-'),
    };
  },
  mounted() {
    initGeetestCaptchaScript()
      .then((initCaptcha) => {
        this.captcha = initCaptcha(
          {
            captchaId: this.captchaSiteKey,
          },
          (captcha) => {
            captcha.appendTo(`.${this.buttonClass}`);
            captcha.onSuccess(() => {
              const captchaResponse = btoa(JSON.stringify(captcha.getValidate()));
              this.captchaResponse = captchaResponse;
              this.emitReceivedCaptchaResponse(captchaResponse);
            });
          },
        );
      })
      .catch((e) => {
        createAlert({
          message: s__('JH|Captcha|There was an error with the captcha. Please try again.'),
        });
        this.$emit('loadError', e);
      });
  },
  methods: {
    emitReceivedCaptchaResponse(captchaResponse) {
      this.$emit('receivedCaptchaResponse', captchaResponse);
    },
  },
};
</script>
<template>
  <div class="geetest-captcha">
    <input type="hidden" name="jh_captcha_response" :value="captchaResponse" />
    <div :class="buttonClass"></div>
  </div>
</template>
