// The notifications page has no save button: upstream submits the form on
// change, but only for the controls it knows about. The WeCom checkbox is added
// by JH, so without its own handler a tick would silently never be saved.
jest.mock('~/pages/profiles/notifications/show', () => ({}));

describe('JH notifications page', () => {
  const setUpPage = ({ withCheckbox = true } = {}) => {
    document.body.innerHTML = withCheckbox
      ? `<form id="notifications-form">
           <input type="checkbox" class="js-wecom-notifications-enabled" />
         </form>`
      : '<form id="notifications-form"></form>';

    jest.isolateModules(() => {
      // eslint-disable-next-line global-require
      require('jh/pages/profiles/notifications/show');
    });

    return document.querySelector('.js-wecom-notifications-enabled');
  };

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('submits the form when the checkbox is ticked', () => {
    const checkbox = setUpPage();
    const submit = jest.fn();
    checkbox.form.submit = submit;

    checkbox.checked = true;
    checkbox.dispatchEvent(new Event('change'));

    expect(submit).toHaveBeenCalledTimes(1);
  });

  it('submits the form when the checkbox is unticked', () => {
    const checkbox = setUpPage();
    const submit = jest.fn();
    checkbox.form.submit = submit;

    checkbox.checked = false;
    checkbox.dispatchEvent(new Event('change'));

    expect(submit).toHaveBeenCalledTimes(1);
  });

  // The checkbox is absent whenever the instance cannot deliver to WeCom.
  it('does nothing when the checkbox is not on the page', () => {
    expect(() => setUpPage({ withCheckbox: false })).not.toThrow();
  });
});
