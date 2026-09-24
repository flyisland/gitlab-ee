import { createAlert } from '~/alert';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';
import InputValidator from '~/validators/input_validator';
import { checkPhoneAvailability } from 'jh/rest_api';
import { phoneNumberRegex } from './constants';

const invalidInputClass = 'gl-field-error-outline';
const successInputClass = 'gl-field-success-outline';
const successMessageSelector = '.validation-success';
const pendingMessageSelector = '.validation-pending';
const formatErrorMessageSelector = '.validation-format-error';
const unavailableMessageSelector = '.validation-error';

let cancel;

function validatePhoneInputPattern(inputDomElement, areaCode) {
  return phoneNumberRegex[areaCode].test(inputDomElement.value);
}

function setMessageVisibility(inputDomElement, messageSelector, isVisible = true) {
  const messageElement = inputDomElement.parentElement.parentElement.querySelector(messageSelector);
  messageElement.classList.toggle('hide', !isVisible);
}

function setInputState(inputDomElement, success = true) {
  inputDomElement.classList.toggle(successInputClass, success);
  inputDomElement.classList.toggle(invalidInputClass, !success);
}

function resetInputState(inputDomElement) {
  setMessageVisibility(inputDomElement, successMessageSelector, false);
  setMessageVisibility(inputDomElement, unavailableMessageSelector, false);
  setMessageVisibility(inputDomElement, formatErrorMessageSelector, false);

  if (inputDomElement.checkValidity()) {
    inputDomElement.classList.remove(successInputClass, invalidInputClass);
  }
}

export default class PhoneValidator extends InputValidator {
  verificationButton = null;
  currentPhoneNumber;
  currentAreaCode;
  constructor(opts = {}) {
    super();

    const container = opts.container || '';
    const phoneInputBox = document.querySelector(`${container} .js-validate-phone`);
    const areaCodeSelectElement = document.querySelector('select.js-select-areacode');
    if (!phoneInputBox || !areaCodeSelectElement || !opts.verificationButton) {
      return;
    }
    this.verificationButton = opts.verificationButton;
    this.currentPhoneNumber = opts.currentPhoneNumber;
    this.currentAreaCode = opts.currentAreaCode;
    phoneInputBox.isValid = Promise.resolve(false);
    // when opts.currentAreaCode and opts.currentPhoneNumber are present, meaning we are now at
    // profile page so we don't trigger this initial verification
    if (this.verificationButton && !opts.currentAreaCode && !opts.currentPhoneNumber) {
      if (phoneInputBox.value) {
        this.validatePhoneInputExist(phoneInputBox, areaCodeSelectElement.value);
      }
    }

    phoneInputBox.addEventListener('input', () => {
      resetInputState(phoneInputBox);
      this.validatePhoneInputExist(phoneInputBox, areaCodeSelectElement.value);
    });

    areaCodeSelectElement.addEventListener('change', () => {
      resetInputState(phoneInputBox);
      this.validatePhoneInputExist(phoneInputBox, areaCodeSelectElement.value);
    });
  }

  validatePhoneInputExist(inputDomElement, areaCode) {
    const element = inputDomElement;
    const phone = element.value;
    if (
      this.currentPhoneNumber &&
      phone === this.currentPhoneNumber &&
      this.currentAreaCode &&
      areaCode === this.currentAreaCode
    ) {
      return;
    }
    if (cancel !== undefined) {
      cancel();
    }
    if (element.checkValidity() && validatePhoneInputPattern(element, areaCode)) {
      setMessageVisibility(element, pendingMessageSelector);
      element.isValid = checkPhoneAvailability(`${areaCode}${phone}`, (c) => {
        cancel = c;
      })
        .then((phoneTaken) => {
          setInputState(element, !phoneTaken);
          setMessageVisibility(element, pendingMessageSelector, false);
          setMessageVisibility(
            element,
            phoneTaken ? unavailableMessageSelector : successMessageSelector,
          );
          this.verificationButton.setVerificationButtonState({
            phoneNumber: `${areaCode}${phone}`,
            disabled: phoneTaken,
          });
          return !phoneTaken;
        })
        .catch((error) => {
          if (axios.isCancel(error)) {
            setMessageVisibility(element, pendingMessageSelector, false);
            return false;
          }
          createAlert({
            message: s__('JH|RealName|An error occurred while validating phone'),
          });
          return false;
        });
    } else {
      if (element.value) {
        setMessageVisibility(element, formatErrorMessageSelector);
      }

      this.verificationButton.setVerificationButtonState({
        phoneNumber: `${areaCode}${phone}`,
        disabled: true,
      });
    }
  }
}
