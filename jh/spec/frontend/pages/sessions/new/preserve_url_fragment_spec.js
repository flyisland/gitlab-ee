import { appendUrlFragment, appendRedirectQuery } from '~/pages/sessions/new/preserve_url_fragment';
import { setHTMLFixture, resetHTMLFixture } from 'helpers/fixtures';

const htmlTemplate = `<div class="borderless">
<div class="clearfix">
  <div class="gl-mt-5 gl-p-5 gl-text-center gl-w-9/10 gl-ml-auto gl-mr-auto restyle-login-page">
    <label class="gl-font-normal gl-mb-5">
      Sign in with
    </label>
    <div class="gl-flex gl-flex-wrap gl-justify-center gl-gap-3 js-oauth-login">
      <form class="gl-mb-3 gl-w-full" method="post" action="http://test.host/users/auth/cas3">
        <button id="oauth-login-cas3" class="btn gl-button btn-default gl-w-full gl-mb-2" type="submit">
          <span class="gl-button-text"> Cas3 </span>
        </button>
      </form>
    </div>
    <div class="gl-form-checkbox custom-control custom-checkbox">
      <input type="checkbox" name="js-remember-me-omniauth" id="js-remember-me-omniauth" class="custom-control-input">
      <label class="custom-control-label" for="js-remember-me-omniauth"><span>Remember me </span></label>
    </div>
  </div>
</div>
</div>`;

describe('preserve_url_fragment', () => {
  const setupDOM = () => {
    setHTMLFixture(htmlTemplate);
  };

  const findFormAction = () => {
    return document.querySelector(`.js-oauth-login form`).action;
  };

  beforeEach(() => {
    setupDOM();
  });

  afterEach(() => {
    resetHTMLFixture();
  });

  it('does not add an empty query parameter to OmniAuth login buttons', () => {
    appendUrlFragment();

    expect(findFormAction()).toBe('http://test.host/users/auth/cas3');
  });

  describe('adds "redirect_fragment" query parameter to OmniAuth login buttons', () => {
    it('when "remember_me" is not present', () => {
      appendRedirectQuery('#L65');

      expect(findFormAction()).toBe('http://test.host/users/auth/cas3?redirect_fragment=L65');
    });

    it('when "remember_me" is present', () => {
      document
        .querySelectorAll('form')
        .forEach((form) => form.setAttribute('action', `${form.action}?remember_me=1`));

      appendRedirectQuery('#L65');

      expect(findFormAction()).toBe(
        'http://test.host/users/auth/cas3?remember_me=1&redirect_fragment=L65',
      );
    });
  });
});
