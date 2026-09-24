import MockAdapter from 'axios-mock-adapter';
import { nextTick } from 'vue';
import PhoneForm from 'jh/passwords/components/phone_form.vue';
import { i18n, noUserMatchPhoneError, phoneInvalidError } from 'jh/passwords/constants';
import { captchaCheck, TENCENT_CAPTCHA_RET_USER_CANCELLED } from 'jh/captcha';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK } from '~/lib/utils/http_status';
import waitForPromises from 'helpers/wait_for_promises';
import { phones } from '../profile/show/constants';

jest.mock('jh/captcha');
describe('Password reset phone form', () => {
  const { mainland } = phones;
  let wrapper;
  let mock;
  let areaCodeInput;
  let phoneInput;
  let submitButton;
  const findErrorTextElement = () => wrapper.findByTestId('error-text');
  const normalInputAndSubmit = async () => {
    await phoneInput.setValue(mainland.phone);

    await submitButton.trigger('click');

    await nextTick();
  };

  const mockPhoneAvailability = (exists) => {
    const phone = encodeURIComponent(`${mainland.areaCode}${mainland.phone}`);
    mock.onGet(`-/users/phone/exists?phone=${phone}`).reply(HTTP_STATUS_OK, { exists });
  };

  beforeEach(() => {
    wrapper = mountExtended(PhoneForm);
    areaCodeInput = wrapper.findByTestId('form-phone-area-select');
    phoneInput = wrapper.find('#input-phone');
    submitButton = wrapper.findByTestId('form-phone-submit');
    mock = new MockAdapter(axios);
  });

  it('should render correctly', () => {
    expect(submitButton.attributes('disabled')).toBe('disabled');
    expect(findErrorTextElement().exists()).toBe(false);
  });

  describe('with invalid phone', () => {
    it('should shows invalid phone', async () => {
      await phoneInput.setValue(`${mainland.phone}123`);

      expect(submitButton.attributes('disabled')).toBe('disabled');
      expect(findErrorTextElement().text()).toBe(phoneInvalidError.message);
    });
  });

  describe.each([['mainland'], ['hkSAR'], ['macauSAR']])('with valid phone from %s', (area) => {
    it('should enable submit button', async () => {
      areaCodeInput.element.value = phones[area].areaCode;
      await areaCodeInput.trigger('change');
      await phoneInput.setValue(phones[area].phone);

      await waitForPromises();
      expect(submitButton.attributes('disabled')).toBeUndefined();
    });
  });

  describe('with user not found', () => {
    it('shows error', async () => {
      captchaCheck.mockReturnValue(Promise.resolve({}));
      mockPhoneAvailability(false);

      await normalInputAndSubmit();
      await waitForPromises();

      expect(findErrorTextElement().text()).toBe(noUserMatchPhoneError.message);
      expect(submitButton.attributes('disabled')).toBeUndefined();

      await phoneInput.setValue(`${mainland.phone}0`); // change value
      await phoneInput.setValue(mainland.phone); // ...and change back

      expect(findErrorTextElement().exists()).toBe(false);
      expect(submitButton.attributes('disabled')).toBeUndefined();
    });
  });

  describe('with user closes captcha', () => {
    it('should do nothing but reenable submit button', async () => {
      captchaCheck.mockReturnValue(Promise.reject(TENCENT_CAPTCHA_RET_USER_CANCELLED));

      await normalInputAndSubmit();

      expect(findErrorTextElement().exists()).toBe(false);
      expect(submitButton.attributes('disabled')).toBeUndefined();
    });
  });

  describe('with send verification api error', () => {
    it('shows error', async () => {
      captchaCheck.mockReturnValue(Promise.resolve({}));
      mockPhoneAvailability(true);
      mock
        .onPost('/-/sms/verification_code')
        .reply(HTTP_STATUS_OK, { status: 'SENDING_CODE_ERROR' });

      await normalInputAndSubmit();
      await waitForPromises();

      expect(findErrorTextElement().text()).toBe(i18n.SEND_CODE_ERROR);
    });
  });

  it('should send code successfully', async () => {
    captchaCheck.mockReturnValue(Promise.resolve({}));
    mockPhoneAvailability(true);
    mock.onPost('/-/sms/verification_code').reply(HTTP_STATUS_OK, { status: 'OK' });

    await normalInputAndSubmit();
    await waitForPromises();

    expect(wrapper.emitted('sent-code')[0]).toStrictEqual([
      {
        phone: `${mainland.areaCode}${mainland.phone}`,
      },
    ]);
  });
});
