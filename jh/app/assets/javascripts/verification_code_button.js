import { isNumber } from 'lodash-es';
import { getVerificationCode } from 'jh/rest_api';
import { captchaCheck } from 'jh/captcha';
import { createAlert } from '~/alert';
import { sprintf, s__ } from '~/locale';

const DEFAULT_WAIT_DURATION = 60;
export default class VerificationCodeButton {
  wait = DEFAULT_WAIT_DURATION;
  timer = null;
  state = {
    disabled: true,
    phoneNumber: '',
  };
  enabledButtonText = s__('JH|RealName|Get code');

  get disabledButtonText() {
    return sprintf(s__('JH|RealName|Resend in %{wait}s'), {
      wait: this.wait,
    });
  }

  constructor() {
    const verificationBtnElement = document.querySelector('.js-verification-btn');

    if (!verificationBtnElement) {
      return;
    }

    this.setVerificationButtonState = (state) => {
      this.state = state;
      verificationBtnElement.classList.toggle('disabled', this.state.disabled);
    };

    verificationBtnElement.addEventListener('click', async () => {
      const isPhoneValid = !this.timer;
      if (!isPhoneValid || this.state.disabled) {
        return;
      }
      try {
        const params = await captchaCheck();
        await getVerificationCode({ ...params, phone: this.state.phoneNumber });
        this.setTimer(verificationBtnElement);
      } catch (e) {
        // User cancelled captcha
        if (isNumber(e?.ret) && e?.ret === 2) return;

        createAlert({
          message: e?.message || e?.errorMessage,
        });
      }
    });
  }

  /**
   * @param {HTMLButtonElement} verificationBtnElement
   */
  resetVerificationBtnState(verificationBtnElement) {
    clearInterval(this.timer);
    this.timer = null;
    this.wait = DEFAULT_WAIT_DURATION;
    verificationBtnElement.removeAttribute('disabled');
    verificationBtnElement.innerText = this.enabledButtonText; // eslint-disable-line no-param-reassign
  }

  /**
   * @param {HTMLButtonElement} verificationBtnElement
   */
  setTimer(verificationBtnElement) {
    verificationBtnElement.setAttribute('disabled', true);
    this.timer = setInterval(() => {
      if (this.wait <= 0) {
        this.resetVerificationBtnState(verificationBtnElement);
        return;
      }
      // eslint-disable-next-line no-param-reassign
      verificationBtnElement.innerText = this.disabledButtonText;
      this.wait -= 1;
    }, 1000);
  }
}
