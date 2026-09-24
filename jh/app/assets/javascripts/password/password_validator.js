import Vue from 'vue';
import PasswordRequirementList from 'ee/password/components/password_requirement_list.vue';

const initPasswordValidator = ({ allowNoPassword = false } = {}) => {
  const passwordInputSelector = '.js-password-complexity-validation';
  const passwordRuleSetSelector = '#js-password-requirements-list';
  const passwordInputContainerSelector = '.form-group';
  const passwordInputElements = document.querySelectorAll(passwordInputSelector);

  passwordInputElements.forEach((passwordInputElement) => {
    if (!passwordInputElement) {
      return;
    }

    const el = passwordInputElement
      .closest(passwordInputContainerSelector)
      .querySelector(passwordRuleSetSelector);

    if (!el) {
      return;
    }

    const ruleTypes = JSON.parse(el.dataset.ruleTypes);

    if (ruleTypes.length === 0) {
      return;
    }

    // eslint-disable-next-line no-new
    new Vue({
      el,
      name: 'PasswordRequirementListRoot',
      render(createElement) {
        return createElement(PasswordRequirementList, {
          props: {
            ruleTypes,
            allowNoPassword,
            passwordInputElement,
          },
        });
      },
    });
  });
};

export default initPasswordValidator;
