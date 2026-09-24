import { memoize } from 'lodash-es';
import { loadScript } from 'jh/captcha/utils/load_script';

const GEETEST_CAPTCHA_LIB_URL = 'https://static.geetest.com/v4/gt4.js';

/**
 * See the Geetest captcha documentation for more details:
 *
 * https://docs.geetest.com/gt4/deploy/client/web
 *
 */
export const initGeetestCaptchaScript = memoize(() => {
  return loadScript(GEETEST_CAPTCHA_LIB_URL, (resolve) => {
    resolve(window.initGeetest4);
  });
});
