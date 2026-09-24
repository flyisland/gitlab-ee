import Vue from 'vue';
import CaptchaModal from 'jh/captcha/captcha_modal.vue';
import UnsolvedCaptchaError from '~/captcha/unsolved_captcha_error';
import { waitForCaptchaToBeSolved as ceWaitForCaptchaToBeSolved } from '~/captcha/wait_for_captcha_to_be_solved';
/**
 * Opens a Captcha Modal with provided captchaSiteKey.
 *
 * Returns a Promise which resolves if the captcha is solved correctly, and rejects
 * if the captcha process is aborted.
 *
 * @param captchaSiteKey
 * @returns {Promise}
 */
export function waitForCaptchaToBeSolved(captchaSiteKey) {
  if (!gon.tencent_captcha_replacement_enabled && !gon.geetest_captcha_replacement_enabled) {
    return ceWaitForCaptchaToBeSolved(captchaSiteKey);
  }

  if (gon.geetest_captcha_replacement_enabled) {
    // eslint-disable-next-line no-param-reassign
    captchaSiteKey = gon.geetest_captcha_id;
  } else if (gon.tencent_captcha_replacement_enabled) {
    // eslint-disable-next-line no-param-reassign
    captchaSiteKey = gon.tencent_captcha_app_id;
  }

  return new Promise((resolve, reject) => {
    let captchaModalElement = document.createElement('div');

    document.body.append(captchaModalElement);

    let captchaModalVueInstance = new Vue({
      el: captchaModalElement,
      render: (createElement) => {
        return createElement(CaptchaModal, {
          props: {
            captchaSiteKey,
            needsCaptchaResponse: true,
          },
          on: {
            hidden: () => {
              // Cleaning up the modal from the DOM
              captchaModalVueInstance.$destroy();
              captchaModalElement.remove();

              captchaModalElement = null;
              captchaModalVueInstance = null;
            },
            receivedCaptchaResponse: (captchaResponse) => {
              if (captchaResponse) {
                resolve(captchaResponse);
              } else {
                // reject the promise with a custom exception, allowing consuming apps to
                // adjust their error handling, if appropriate.
                reject(new UnsolvedCaptchaError());
              }
            },
          },
        });
      },
    });
  });
}
