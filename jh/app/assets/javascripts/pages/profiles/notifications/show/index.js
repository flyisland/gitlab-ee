import '~/pages/profiles/notifications/show';

// The page has no save button: upstream submits the form on change, but only
// for the controls it knows about (see app/assets/javascripts/profile/profile.js).
// The WeCom checkbox is added by JH, so it has to bind its own handler or a
// tick would silently never be saved.
const checkbox = document.querySelector('.js-wecom-notifications-enabled');

checkbox?.addEventListener('change', () => {
  checkbox.form?.submit();
});
