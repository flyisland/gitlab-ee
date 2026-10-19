import { s__ } from '~/locale';

export function initPhoneAuthUsernameLabel() {
  document.addEventListener('DOMContentLoaded', () => {
    const isPhoneAuthEnabled = Boolean(window.gon?.features?.phoneAuthenticatable);

    if (!isPhoneAuthEnabled) {
      return;
    }

    const usernameFields = document.querySelectorAll('[data-testid="username-field"]');

    if (!usernameFields.length) {
      return;
    }

    const labelText = s__('JH|Username, email or phone');

    usernameFields.forEach((field) => {
      const formGroup = field.closest('.form-group');

      if (!formGroup) {
        return;
      }

      const label = formGroup.querySelector('label');

      if (!label) {
        return;
      }

      label.textContent = labelText;
    });
  });
}
