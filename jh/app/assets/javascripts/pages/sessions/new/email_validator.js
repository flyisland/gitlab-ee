import { debounce } from 'lodash-es';

import { createAlert } from '~/alert';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';
import InputValidator from '~/validators/input_validator';

const debounceTimeoutDuration = 1000;
const rootUrl = gon.relative_url_root;
const emailRegexPattern = /[^@\s]+@[^@\s]+\.[^@\s]+/;
const invalidInputClass = 'gl-field-error-outline';
const successInputClass = 'gl-field-success-outline';
const successMessageSelector = '.validation-success';
const pendingMessageSelector = '.validation-pending';
const unavailableMessageSelector = '.validation-error';
const warningMessageSelector = '.validation-warning';

export default class EmailValidator extends InputValidator {
  constructor(opts = {}) {
    super();

    const container = opts.container || '';
    const validateLengthElements = document.querySelectorAll(`${container} #new_user_email`);

    this.debounceValidateInput = debounce((inputDomElement) => {
      EmailValidator.validateEmailInput(inputDomElement);
    }, debounceTimeoutDuration);

    validateLengthElements.forEach((element) =>
      element.addEventListener('input', this.eventHandler.bind(this)),
    );
  }

  eventHandler(event) {
    const inputDomElement = event.target;

    EmailValidator.resetInputState(inputDomElement);
    this.debounceValidateInput(inputDomElement);
  }

  static validateEmailInput(inputDomElement) {
    const userEmail = inputDomElement.value;
    // checkValidity checks if the email format meets \w+@\w* format. we should bail when it returns false.
    // And it fires `invalid` event which is handled by app/assets/javascripts/gl_field_error.js
    if (!inputDomElement.checkValidity()) {
      return;
    }

    // Handles if the email contains a suffix like .com .cc
    if (!emailRegexPattern.test(userEmail)) {
      EmailValidator.setMessageVisibility(inputDomElement, warningMessageSelector, true);
      return;
    }

    if (userEmail.length > 1) {
      EmailValidator.setMessageVisibility(inputDomElement, warningMessageSelector, false);
      EmailValidator.setMessageVisibility(inputDomElement, pendingMessageSelector);
      EmailValidator.fetchUsernameAvailability(userEmail)
        .then((emailTaken) => {
          EmailValidator.setInputState(inputDomElement, !emailTaken);
          EmailValidator.setMessageVisibility(inputDomElement, pendingMessageSelector, false);
          EmailValidator.setMessageVisibility(
            inputDomElement,
            emailTaken ? unavailableMessageSelector : successMessageSelector,
          );
        })
        .catch(() =>
          createAlert({
            message: s__('JH|An error occurred while validating email'),
          }),
        );
    }
  }

  static fetchUsernameAvailability(username) {
    return axios.get(`${rootUrl}/users/${username}/email_exists`).then(({ data }) => data.exists);
  }

  static setMessageVisibility(inputDomElement, messageSelector, isVisible = true) {
    const messageElement = inputDomElement.parentElement.querySelector(messageSelector);
    messageElement.classList.toggle('hide', !isVisible);
  }

  static setInputState(inputDomElement, success = true) {
    inputDomElement.classList.toggle(successInputClass, success);
    inputDomElement.classList.toggle(invalidInputClass, !success);
  }

  static resetInputState(inputDomElement) {
    EmailValidator.setMessageVisibility(inputDomElement, successMessageSelector, false);
    EmailValidator.setMessageVisibility(inputDomElement, unavailableMessageSelector, false);

    if (inputDomElement.checkValidity()) {
      inputDomElement.classList.remove(successInputClass, invalidInputClass);
    }
  }
}
