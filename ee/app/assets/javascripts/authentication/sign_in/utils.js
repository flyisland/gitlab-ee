export const showPasskeySignIn = (showPasswordField) => {
  // When not on gitlab.com we always show the passkey sign in regardless of if the password
  // field is shown yet.
  // redirectSignInWhenLoginNotFound is the SaaS feature used to determine if we
  // are using cells architecture (gitlab.com)
  if (!window.gon?.saas_features?.redirectSignInWhenLoginNotFound) {
    return true;
  }

  return showPasswordField;
};
