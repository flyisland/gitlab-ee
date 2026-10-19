import { waitForCaptchaToBeSolved } from 'jh/captcha/wait_for_captcha_to_be_solved';
import { initTencentCaptchaScript } from './tencent/init_script';

export const TENCENT_CAPTCHA_RET_USER_CANCELLED = 2;

function calloutTencentRecaptcha(TencentCaptcha) {
  return new Promise((resolve, reject) => {
    const captcha = new TencentCaptcha(
      gon.tencent_captcha_app_id,
      (res) => {
        if (res.ret === 0) {
          const params = {
            rand_str: res.randstr,
            ticket: res.ticket,
          };
          resolve(params);
        } else {
          reject(res);
        }
      },
      { loading: false },
    );
    captcha.show();
  });
}

/**
 * In scenario of sending SMS, callout tencent captcha directly
 * rather than use `waitForCaptchaToBeSolved` to show a modal,
 * since there's no `one click pass` model in this captcha.
 */
const tencentCaptchaHandler = async () => {
  if (!window.TencentCaptcha) {
    await initTencentCaptchaScript();
  }
  return calloutTencentRecaptcha(window.TencentCaptcha);
};

export const captchaCheck = () =>
  new Promise((resolve, reject) => {
    if (gon.tencent_captcha_replacement_enabled && !gon.geetest_captcha_replacement_enabled) {
      tencentCaptchaHandler().then(resolve).catch(reject);
    } else {
      const [paramKey, captchaSiteKey] = gon.geetest_captcha_replacement_enabled
        ? ['geetest_captcha_response']
        : ['g-recaptcha-response', gon.recaptcha_sitekey];
      waitForCaptchaToBeSolved(captchaSiteKey)
        .then((response) =>
          resolve({
            [paramKey]: response,
          }),
        )
        .catch(reject);
    }
  });
