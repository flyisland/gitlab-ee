import { GlTabs } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import ResetPasswordForm from 'jh/passwords/reset_password_form.vue';
import PhoneForm from 'jh/passwords/components/phone_form.vue';
import PhoneCodeVerification from 'jh/passwords/components/phone_code_verification.vue';
import { provide } from 'jh_jest/pages/password/constant';

describe('Password reset form', () => {
  let wrapper;

  const findTabs = () => wrapper.findComponent(GlTabs);
  const findPhoneForm = () => wrapper.findComponent(PhoneForm);
  const findVerificationForm = () => wrapper.findComponent(PhoneCodeVerification);

  beforeEach(() => {
    wrapper = mountExtended(ResetPasswordForm, {
      provide,
    });
  });

  it('renders correctly', () => {
    expect(findTabs().isVisible()).toBe(true);
    expect(findVerificationForm().isVisible()).toBe(false);
  });

  it('switch correctly', async () => {
    findPhoneForm().vm.$emit('sent-code', { phone: '' });

    await nextTick();

    expect(findTabs().isVisible()).toBe(false);
    expect(findVerificationForm().isVisible()).toBe(true);
  });
});
