import MockAdapter from 'axios-mock-adapter';
import { merge } from 'lodash-es';
import { GlForm, GlFormGroup, GlFormSelect } from '@gitlab/ui';
import PhoneForm from 'jh/phone/components/phone_form.vue';
import { phoneNumberRegex } from 'jh/pages/sessions/new/constants';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import { HTTP_STATUS_OK } from '~/lib/utils/http_status';
import waitForPromises from 'helpers/wait_for_promises';
import { captchaCheck } from 'jh/captcha';
import { createAlert } from '~/alert';
import Api from 'jh/api';
import { verificationCodePath } from 'jh/rest_api';

jest.mock('~/locale', () => ({
  ...jest.requireActual('~/locale'),
  s__: (key) => key,
}));

jest.mock('jh/captcha', () => ({
  captchaCheck: jest.fn().mockImplementation(() =>
    Promise.resolve({
      randstr: 'some_callback_string',
      ticket: 'test_ticket',
      ip: '127.0.0.1',
    }),
  ),
}));

jest.mock('~/alert', () => ({
  ...jest.requireActual('~/alert'),
  createAlert: jest.fn(),
}));

describe('PhoneForm', () => {
  const dummyUrlRoot = '/gitlab';
  const dummyGon = {
    relative_url_root: dummyUrlRoot,
  };
  const defaultProvide = {
    paths: {
      accept: '/-/users/phone/verify',
    },
    termsPath: '/terms/',
    oauthUser: false,
  };
  const mainlandNumber = '13800000000';
  const hkNumber = '00000000';
  const macauNumber = '0000000';

  let wrapper;
  let mock;
  let originalGon;

  const findAreaCodeSelector = () => wrapper.findComponent(GlFormSelect);
  const findAreaCodeOptions = () => findAreaCodeSelector().findAll('option');
  const findPhoneInputComponent = () => wrapper.findByTestId('phone-field');
  const findPhoneInputElement = () => findPhoneInputComponent().find('input');
  const findVerificationInputComponent = () => wrapper.findByTestId('verification-code-field');
  const findVerificationInputElement = () => findVerificationInputComponent().find('input');
  const findSendCodeButton = () => wrapper.findComponentByTestId('send-msg');
  const findContinueButton = () => wrapper.findComponentByTestId('verify-phone-number');

  const createComponent = (provide = {}) => {
    wrapper = mountExtended(PhoneForm, {
      provide: merge({}, defaultProvide, provide),
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    originalGon = window.gon;
    window.gon = { ...dummyGon };
  });

  afterEach(() => {
    mock.restore();
    window.gon = originalGon;
    captchaCheck.mockClear();
    createAlert.mockClear();
  });

  it('should render correctly', () => {
    createComponent();

    expect(wrapper.findComponent(GlForm).attributes('action')).toEqual(defaultProvide.paths.accept);
    expect(findSendCodeButton().props('disabled')).toBe(true);
    expect(wrapper.vm.isValidPhone).toBe(false);
    const formGroups = wrapper.findAllComponents(GlFormGroup);
    expect(formGroups).toHaveLength(2);
    expect(findSendCodeButton().props('disabled')).toBe(true);
    expect(findContinueButton().props('disabled')).toBe(true);
    expect(wrapper.findByTestId('sign_out_button').exists()).toBe(true);
    // These lines should be tested after i18n function gets fixed.
    // expect(formGroups.at(0).attributes('label')).toBe('JH|RealName|Phone');
    // expect(formGroups.at(1).attributes('label')).toBe('JH|RealName|Verification code');
  });

  it('should be able to submit form to any endpoint', () => {
    const otherPath = '/-/users/other/1/accept';
    createComponent({
      paths: {
        accept: otherPath,
      },
    });

    expect(wrapper.findComponent(GlForm).attributes('action')).toEqual(otherPath);
  });

  it('should change area code correctly', async () => {
    createComponent();

    const selectComponent = findAreaCodeSelector();
    expect(selectComponent.exists()).toBe(true);
    const areaCodes = findAreaCodeOptions();
    expect(areaCodes).toHaveLength(Object.keys(phoneNumberRegex).length);
    expect(wrapper.vm.areaCode).toEqual(areaCodes.at(0).attributes('value'));
    expect(wrapper.vm.isValidPhone).toBe(false);
    await areaCodes.at(1).setSelected();

    expect(wrapper.vm.areaCode).toEqual(areaCodes.at(1).attributes('value'));
    expect(wrapper.vm.isValidPhone).toBe(false);
  });

  describe('phone existence check', () => {
    it('should be able send code after set valid phone number', async () => {
      const phone = encodeURIComponent(`+86${mainlandNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${phone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
      createComponent();
      const inputBoxElement = findPhoneInputElement();
      expect(inputBoxElement.exists()).toBe(true);
      expect(wrapper.vm.isValidPhone).toBe(false);

      // current area code = +86
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();
      expect(wrapper.vm.phoneNumber).toBe(mainlandNumber);
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(findSendCodeButton().props('disabled')).toBe(false);
    });

    it('should be able to validate the phone number after area code changed', async () => {
      const phone = encodeURIComponent(`+86${mainlandNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${phone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
      createComponent();

      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(findSendCodeButton().props('disabled')).toBe(false);

      const areaCodes = findAreaCodeOptions();
      await areaCodes.at(1).setSelected();
      await waitForPromises();
      expect(wrapper.vm.isValidPhone).toBe(false);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('');
      expect(findSendCodeButton().props('disabled')).toBe(true);
    });

    it('should validate HK and Macau phone number', async () => {
      const hkPhone = encodeURIComponent(`+852${hkNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${hkPhone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
      const macauPhone = encodeURIComponent(`+853${macauNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${macauPhone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
      createComponent();

      const areaCodes = findAreaCodeOptions();
      await areaCodes.at(1).setSelected();

      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(hkNumber);
      await waitForPromises();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(findSendCodeButton().props('disabled')).toBe(false);

      await inputBoxElement.setValue('');
      await areaCodes.at(2).setSelected();
      await inputBoxElement.setValue(macauNumber);
      await waitForPromises();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(findSendCodeButton().props('disabled')).toBe(false);
    });

    it('should not be able to send code if number exists', async () => {
      const phone = encodeURIComponent(`+86${mainlandNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${phone}`)
        .reply(HTTP_STATUS_OK, {
          exists: true,
        });

      createComponent();
      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.errorMsg).toBe('JH|RealName|Phone is already taken.');
      expect(findSendCodeButton().props('disabled')).toBe(true);
    });
  });

  describe('send verification code', () => {
    let sendCodeEndpoint;

    beforeEach(() => {
      sendCodeEndpoint = Api.buildUrl(verificationCodePath);
      const phone = encodeURIComponent(`+86${mainlandNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${phone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
    });

    it('should be able to send verification code', async () => {
      mock.onPost(sendCodeEndpoint).reply(HTTP_STATUS_OK, {
        status: 'OK',
      });
      createComponent();

      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();

      const sendButton = findSendCodeButton();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(sendButton.props('disabled')).toBe(false);

      await sendButton.trigger('click');
      await waitForPromises();
      expect(wrapper.vm.resendCounter).not.toBeNull();
      expect(sendButton.props('disabled')).toBe(true);
    });

    it('should be rate limited', async () => {
      mock.onPost(sendCodeEndpoint).reply(HTTP_STATUS_OK, {
        status: 'SENDING_LIMIT_RATE_ERROR',
      });
      createComponent();

      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();

      const sendButton = findSendCodeButton();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(sendButton.props('disabled')).toBe(false);
      expect(createAlert).not.toHaveBeenCalled();

      await sendButton.trigger('click');
      await waitForPromises();
      expect(wrapper.vm.resendCounter).toBeNull();
      expect(createAlert).toHaveBeenCalled();
    });

    it('should not send code if responses not ok', async () => {
      mock.onPost(sendCodeEndpoint).reply(HTTP_STATUS_OK, {
        status: 'SOME_OTHER_CODE',
      });
      createComponent();

      const inputBoxElement = findPhoneInputElement();
      await inputBoxElement.setValue(mainlandNumber);
      await waitForPromises();

      const sendButton = findSendCodeButton();
      expect(wrapper.vm.isValidPhone).toBe(true);
      expect(wrapper.vm.phoneAvailabilityMsg).toBe('JH|RealName|Phone is available.');
      expect(sendButton.props('disabled')).toBe(false);
      expect(createAlert).not.toHaveBeenCalled();

      await sendButton.trigger('click');
      await waitForPromises();
      expect(wrapper.vm.resendCounter).toBeNull();
      expect(createAlert).toHaveBeenCalled();
    });
  });

  describe('verify phone number', () => {
    it('should be able verify number', async () => {
      const phone = encodeURIComponent(`+86${mainlandNumber}`);
      mock
        .onGet(`${dummyGon.relative_url_root}/-/users/phone/exists?phone=${phone}`)
        .reply(HTTP_STATUS_OK, {
          exists: false,
        });
      createComponent();

      expect(findSendCodeButton().props('disabled')).toBe(true);
      const phoneInputElement = findPhoneInputElement();
      await phoneInputElement.setValue(mainlandNumber);
      await waitForPromises();

      expect(findSendCodeButton().props('disabled')).toBe(false);
      expect(findContinueButton().props('disabled')).toBe(true);

      const verificationCodeInputElement = findVerificationInputElement();
      await verificationCodeInputElement.setValue('000000');
      expect(findContinueButton().props('disabled')).toBe(false);
    });
  });
});
