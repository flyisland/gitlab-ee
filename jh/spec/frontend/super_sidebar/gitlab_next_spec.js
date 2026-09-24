import { initJHGitlabNext, setJHGitlabNext } from 'jh/super_sidebar/gitlab_next';
import setWindowLocation from 'helpers/set_window_location_helper';
import { setCookie, removeCookie } from '~/lib/utils/common_utils';

// Stub the cookie helpers so we can assert how GitLab Next writes/clears the
// canary cookie without mutating document.cookie.
jest.mock('~/lib/utils/common_utils', () => ({
  setCookie: jest.fn(),
  removeCookie: jest.fn(),
}));

describe('JH GitLab Next utils', () => {
  const gitlabNextCookie = 'gitlab_canary';
  const cookieOptions = { domain: '.jihulab.com', path: '/' };
  const hostOnlyCookieOptions = { path: '/' };

  const renderToggle = (ariaChecked) => {
    document.body.innerHTML = `<div data-testid="gitlab-next-toggle"><button role="switch" aria-checked="${ariaChecked}"></button></div>`;
  };
  const clickToggle = () =>
    document.querySelector('[data-testid="gitlab-next-toggle"] button').click();

  beforeEach(() => {
    document.body.innerHTML = '';
  });

  describe('setJHGitlabNext', () => {
    describe('when enabling', () => {
      it.each`
        url                                    | expectedCookieOptions
        ${'https://jihulab.com/'}              | ${cookieOptions}
        ${'https://next.jihulab.com/'}         | ${cookieOptions}
        ${'http://host.docker.internal:3000/'} | ${hostOnlyCookieOptions}
        ${'http://localhost:3000/'}            | ${hostOnlyCookieOptions}
      `('sets the canary cookie for $url', ({ url, expectedCookieOptions }) => {
        setWindowLocation(url);

        setJHGitlabNext(true);

        expect(setCookie).toHaveBeenCalledWith(gitlabNextCookie, 'true', expectedCookieOptions);
        expect(removeCookie).not.toHaveBeenCalled();
      });
    });

    describe('when disabling', () => {
      beforeEach(() => {
        setJHGitlabNext(false);
      });

      it('removes both the JihuLab root-domain and host-only cookies', () => {
        expect(removeCookie).toHaveBeenCalledWith(gitlabNextCookie, cookieOptions);
        expect(removeCookie).toHaveBeenCalledWith(gitlabNextCookie, hostOnlyCookieOptions);
        expect(setCookie).not.toHaveBeenCalled();
      });
    });
  });

  // Only the click wiring is exercised here; the per-host cookie options are
  // already covered exhaustively by the `setJHGitlabNext` matrix above.
  describe('initJHGitlabNext', () => {
    beforeEach(() => {
      initJHGitlabNext();
    });

    it('enables GitLab Next when the toggle is clicked while off', () => {
      setWindowLocation('https://jihulab.com/');
      renderToggle('false');

      clickToggle();

      expect(setCookie).toHaveBeenCalledWith(gitlabNextCookie, 'true', cookieOptions);
    });

    it('removes the JihuLab canary cookie when the toggle is clicked while on', () => {
      renderToggle('true');

      clickToggle();

      expect(removeCookie).toHaveBeenCalledWith(gitlabNextCookie, cookieOptions);
      expect(removeCookie).toHaveBeenCalledWith(gitlabNextCookie, hostOnlyCookieOptions);
    });

    it('ignores clicks outside the GitLab Next toggle', () => {
      document.body.innerHTML = '<button data-testid="other-toggle" aria-checked="false"></button>';

      document.querySelector('[data-testid="other-toggle"]').click();

      expect(setCookie).not.toHaveBeenCalled();
      expect(removeCookie).not.toHaveBeenCalled();
    });
  });
});
