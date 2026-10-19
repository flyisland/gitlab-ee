import Vue from 'vue';
import TencentCaptchaButton from 'jh/captcha/tencent/captcha_button.vue';
import GeetestCaptchaButton from 'jh/captcha/geetest/captcha_button.vue';

/**
 * Init a Captcha inline the form with provided captchaSiteKey.
 *
 * @param captchaSiteKey
 */

export function initCaptcha() {
  const captchaElements = document.querySelectorAll('.js-captcha');

  if (!captchaElements.length) {
    return;
  }

  const [component, captchaSiteKey] = gon.geetest_captcha_replacement_enabled
    ? [GeetestCaptchaButton, gon.geetest_captcha_id]
    : [TencentCaptchaButton, gon.tencent_captcha_app_id];

  captchaElements.forEach((captchaElement) => {
    return new Vue({
      el: captchaElement,
      render: (createElement) => {
        return createElement(component, {
          props: {
            captchaSiteKey,
          },
        });
      },
    });
  });
}
