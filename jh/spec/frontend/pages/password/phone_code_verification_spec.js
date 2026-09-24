import MockAdapter from 'axios-mock-adapter';
import { nextTick } from 'vue';
import PhoneCodeVerification from 'jh/passwords/components/phone_code_verification.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { captchaCheck, TENCENT_CAPTCHA_RET_USER_CANCELLED } from 'jh/captcha';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK } from '~/lib/utils/http_status';
import waitForPromises from 'helpers/wait_for_promises';
import { provide } from 'jh_jest/pages/password/constant';

jest.mock('jh/captcha');

const HTTP_STATUS_PRECONDITION_FAILED = 412;

describe('Password reset phone code verification', () => {
  let wrapper;
  let resendLink;
  let mock;
  const findErrorTextElement = () => wrapper.findByTestId('error-text');

  const fillCode = async (count) => {
    const elements = wrapper.findAllByTestId('code-inputs');
    for (let i = 0; i < count; i += 1) {
      elements.wrappers[i].setValue('0');
    }

    await nextTick();
  };

  const findFormResetToken = () => {
    return wrapper.findByTestId('reset_password_token').element.value;
  };

  beforeEach(() => {
    wrapper = mountExtended(PhoneCodeVerification, {
      provide,
      propsData: {
        postForm: {
          phone: '+86158000000',
        },
      },
    });
    wrapper.vm.startCountDown();
    mock = new MockAdapter(axios);
    resendLink = wrapper.findByTestId('resend-link');
    // there is no `.focus` for fake-dom library.
    jest.spyOn(wrapper.vm, 'focusCodeInputAt').mockReturnValue(undefined);
  });

  describe('input full code', () => {
    let submitFn;
    beforeEach(() => {
      submitFn = jest.spyOn(wrapper.vm.$refs.formRef.$el, 'submit');
    });
    it('should submit code', async () => {
      mock
        .onPost('/users/reset_password_token')
        .reply(HTTP_STATUS_OK, JSON.stringify({ token: 'A Token' }));

      await fillCode(6);
      await waitForPromises();

      expect(findFormResetToken()).toBe('A Token');
      expect(submitFn).toHaveBeenCalled();
    });

    it('should fails when bad code', async () => {
      const message = 'bad code';
      mock
        .onPost('/users/reset_password_token')
        .reply(HTTP_STATUS_PRECONDITION_FAILED, JSON.stringify({ message }));

      await fillCode(6);
      await waitForPromises();

      expect(findFormResetToken()).toBe('');
      expect(submitFn).not.toHaveBeenCalled();
      expect(findErrorTextElement().text()).toBe(message);
    });
  });

  describe('not input full code', () => {
    it('should not submit code', async () => {
      const spySubmit = jest.spyOn(wrapper.vm, 'submitCode');
      spySubmit.mockReturnValue(true);

      await fillCode(5);

      expect(spySubmit).not.toHaveBeenCalled();
    });
  });

  describe('count down counter', () => {
    it('should clear after countdown', () => {
      expect(wrapper.vm.resendCounter).not.toBeUndefined();

      jest.advanceTimersByTime((wrapper.vm.resendCounter + 1) * 1000);

      expect(wrapper.vm.resendCounter).toBeUndefined();
    });
  });

  describe('resend code', () => {
    it('should send request', async () => {
      captchaCheck.mockReturnValue(Promise.resolve({}));
      mock.onPost('/-/sms/verification_code').reply(HTTP_STATUS_OK, { status: 'OK' });

      jest.advanceTimersByTime((wrapper.vm.resendCounter + 1) * 1000);
      await resendLink.trigger('click');

      await waitForPromises();

      expect(captchaCheck).toHaveBeenCalled();
      expect(wrapper.vm.resendCounter).not.toBeUndefined();
    });

    describe('when user close captcha', () => {
      it('not reset counter', async () => {
        captchaCheck.mockReturnValue(Promise.reject(TENCENT_CAPTCHA_RET_USER_CANCELLED));

        jest.advanceTimersByTime((wrapper.vm.resendCounter + 1) * 1000);
        await resendLink.trigger('click');

        await nextTick();

        expect(captchaCheck).toHaveBeenCalled();
        expect(wrapper.vm.resendCounter).toBeUndefined();
      });
    });
  });
});
