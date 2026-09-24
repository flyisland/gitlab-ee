import $ from 'jquery';
import * as Profile from 'jh/pages/user_settings/profiles/show';
import PhoneValidator from 'jh/pages/sessions/new/phone_validator';
import { phoneNumberRegex } from 'jh/pages/sessions/new/constants';
import VerificationCodeBtn from 'jh/verification_code_button';
import { phones } from './constants';

// Mock these dependencies to make sure that we are only testing the scope that we wanted.
// Mock function must be inlined.
jest.mock('~/pages/user_settings/profiles/show', () => {
  // NOOP
});

jest.mock('jh/pages/sessions/new/phone_validator', () => {
  return jest.fn();
});
jest.mock('jh/verification_code_button', () => {
  return jest.fn();
});

jest.mock('jh/pages/user_settings/profiles/show', () => {
  return {
    bootstrap: () => {
      jest.requireActual('jh/pages/user_settings/profiles/show');
    },
  };
});

const assemblePhone = ({ areaCode, phone }) => `${areaCode}${phone}`;

describe('pages/profile/show/index.html', () => {
  const setupDOM = () => {
    document.body.appendChild(
      $(`
      <div>
        <div class="phone form-group">
          <input class="js-validate-phone">
        </div>
        <div class="verification-code form-group">
          <button class="js-verification-btn">Get Code</button>
        </div>
      </div>
    `)[0],
    );
  };

  beforeEach(() => {
    setupDOM();
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = '';
    jest.resetModules(); // clean up requireActual cache for invoking the module every single time.
    PhoneValidator.mockClear();
    VerificationCodeBtn.mockClear();
  });

  it('should be able to bootstrap correctly', () => {
    const phoneInput = $('.js-validate-phone');

    expect(phoneInput).toHaveLength(1);
    const { mainland } = phones;
    phoneInput.val(assemblePhone(mainland));
    Profile.bootstrap();

    expect(phoneInput.val()).toBe(mainland.phone);

    expect(PhoneValidator).toHaveBeenCalled();
    expect(VerificationCodeBtn).toHaveBeenCalled();
  });

  it('should not be able to bootstrap', () => {
    document.body.innerHTML = '';
    Profile.bootstrap();
    expect(PhoneValidator).not.toHaveBeenCalled();
    expect(VerificationCodeBtn).not.toHaveBeenCalled();
  });

  describe.each`
    phoneObj
    ${phones.mainland}
    ${phones.hkSAR}
    ${phones.macauSAR}
  `(`Area code extraction`, ({ phoneObj }) => {
    it(`return ${phoneObj.phone} when phone is ${assemblePhone(phoneObj)}`, () => {
      const phoneInput = $('.js-validate-phone');
      phoneInput.val(assemblePhone(phoneObj));
      Profile.bootstrap();
      expect(phoneInput.val()).toBe(phoneObj.phone);
    });
  });

  const overseasPhoneObjs = Object.keys(phoneNumberRegex).map((code) => {
    return {
      areaCode: code,
      phone: '88888888', // random phone.
    };
  });

  describe.each(overseasPhoneObjs)('overseas phone extraction', ({ areaCode, phone }) => {
    it(`return ${phone} when the given number is ${assemblePhone({ areaCode, phone })}`, () => {
      const phoneInput = $('.js-validate-phone');
      phoneInput.val(assemblePhone({ areaCode, phone }));
      Profile.bootstrap();
      expect(phoneInput.val()).toBe(phone);
    });
  });
});
