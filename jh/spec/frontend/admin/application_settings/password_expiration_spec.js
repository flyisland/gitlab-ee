import { GlFormCheckbox } from '@gitlab/ui';
import passwordExpiration from 'jh/admin/application_settings/password_expiration/components/app.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';

describe('PasswordExpiration form editor component', () => {
  let wrapper;

  const findCheckBoxGroup = (w = wrapper) => w.findComponent(GlFormCheckbox);
  const findCheckBoxinput = (w = wrapper) =>
    w.find('input[name="application_setting[password_expiration_enabled]"]');
  const findInDaysGroup = (w = wrapper) => w.findByTestId('password-expiration-in-days');
  const findInDaysInput = (w = wrapper) =>
    findInDaysGroup(w).find('input[name="application_setting[password_expires_in_days]"]');
  const findNoticeDaysGroup = (w = wrapper) => w.findByTestId('password-expires-notice-days');
  const findNoticeDaysInput = (w = wrapper) =>
    findNoticeDaysGroup(w).find(
      'input[name="application_setting[password_expires_notice_before_days]"]',
    );

  const createComponent = (provides) =>
    mountExtended(passwordExpiration, {
      provide: {
        passwordExpirationEnabledData: false,
        passwordExpiresInDaysData: 30,
        passwordExpiresNoticeBeforeDaysData: 7,
        ...provides,
      },
    });

  describe('Renders passwordExpiration', () => {
    it('should be rendered by default value', () => {
      wrapper = createComponent({
        passwordExpirationEnabledData: true,
        passwordExpiresInDaysData: 30,
        passwordExpiresNoticeBeforeDaysData: 7,
      });
      expect(findCheckBoxGroup().exists()).toBe(true);
      expect(findCheckBoxinput().element.value).toBe('true');

      expect(findInDaysGroup().exists()).toBe(true);
      expect(findInDaysInput().element.disabled).toBe(false);

      expect(findNoticeDaysGroup().exists()).toBe(true);
      expect(findNoticeDaysInput().element.disabled).toBe(false);
    });

    it('should be disabled input when checkbox unchecked', async () => {
      wrapper = createComponent({
        passwordExpirationEnabledData: true,
      });

      await findCheckBoxGroup().find('input').setChecked(false);
      expect(['', 'false']).toContain(findCheckBoxinput().element.value);
      expect(findInDaysInput().element.disabled).toBe(true);
      expect(findNoticeDaysInput().element.disabled).toBe(true);
    });
  });
});
