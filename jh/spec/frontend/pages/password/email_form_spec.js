import { mountExtended } from 'helpers/vue_test_utils_helper';
import EmailForm from 'jh/passwords/components/email_form.vue';
import { provide } from 'jh_jest/pages/password/constant';

jest.mock('jh/captcha');
describe('Password reset email form', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mountExtended(EmailForm, {
      provide,
    });
  });

  it('should render correctly', () => {
    const hiddenCaptchaInput = wrapper.findByTestId('captcha-container');

    expect(hiddenCaptchaInput.exists()).toBe(true);
  });
});
