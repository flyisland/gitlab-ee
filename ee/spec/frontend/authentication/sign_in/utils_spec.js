import { showPasskeySignIn } from 'ee/authentication/sign_in/utils';

describe('showPasskeySignIn', () => {
  afterEach(() => {
    window.gon = {};
  });

  describe('when not on GitLab.com (redirectSignInWhenLoginNotFound saas feature is disabled)', () => {
    beforeEach(() => {
      window.gon = {};
    });

    describe.each([true, false])('when showPasswordField=%s', (showPasswordField) => {
      it('returns true', () => {
        expect(showPasskeySignIn(showPasswordField)).toBe(true);
      });
    });
  });

  describe('when on GitLab.com (redirectSignInWhenLoginNotFound saas feature is enabled)', () => {
    beforeEach(() => {
      window.gon = { saas_features: { redirectSignInWhenLoginNotFound: true } };
    });

    it('returns true when the password field is shown', () => {
      expect(showPasskeySignIn(true)).toBe(true);
    });

    it('returns false when the password field is not shown', () => {
      expect(showPasskeySignIn(false)).toBe(false);
    });
  });
});
