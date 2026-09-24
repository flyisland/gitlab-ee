import { memoize } from 'lodash-es';
import { loadScript } from 'jh/captcha/utils/load_script';

const TENCENT_CAPTCHA_LIB_URL_PREFIX = 'https://turing.captcha.qcloud.com/TCaptcha.js';

/**
 * See the Tencent captcha documentation for more details:
 *
 * https://cloud.tencent.com/document/product/1110/36841
 *
 */
export const initTencentCaptchaScript = memoize(() => {
  // eslint-disable-next-line no-underscore-dangle
  if (window.__TencentCaptchaExists__) return Promise.resolve(window.TencentCaptcha);

  return loadScript(TENCENT_CAPTCHA_LIB_URL_PREFIX, (resolve) => {
    resolve(window.TencentCaptcha);
  });
});
