import { setCookie, removeCookie } from '~/lib/utils/common_utils';
import { GITLAB_NEXT_COOKIE } from '~/lib/utils/gitlab_next';

export const JH_GITLAB_NEXT_COOKIE_DOMAIN = '.jihulab.com';

const COOKIE_OPTIONS = { domain: JH_GITLAB_NEXT_COOKIE_DOMAIN, path: '/' };
const HOST_ONLY_COOKIE_OPTIONS = { path: '/' };
const GITLAB_NEXT_TOGGLE_SELECTOR = '[data-testid="gitlab-next-toggle"]';
const JH_GITLAB_NEXT_COOKIE_HOST = JH_GITLAB_NEXT_COOKIE_DOMAIN.slice(1);

let initialized = false;

const isJihuLabHostname = () => {
  const hostname = globalThis.window?.location?.hostname?.toLowerCase();

  return (
    Boolean(hostname) &&
    (hostname === JH_GITLAB_NEXT_COOKIE_HOST || hostname.endsWith(JH_GITLAB_NEXT_COOKIE_DOMAIN))
  );
};

const getJHGitlabNextCookieOptions = () =>
  isJihuLabHostname() ? COOKIE_OPTIONS : HOST_ONLY_COOKIE_OPTIONS;

export const setJHGitlabNext = (enabled) => {
  if (enabled) {
    setCookie(GITLAB_NEXT_COOKIE, 'true', getJHGitlabNextCookieOptions());
  } else {
    removeCookie(GITLAB_NEXT_COOKIE, COOKIE_OPTIONS);
    removeCookie(GITLAB_NEXT_COOKIE, HOST_ONLY_COOKIE_OPTIONS);
  }
};

const findGitlabNextToggle = (event) => {
  const target = event.target instanceof Element ? event.target : event.target?.parentElement;

  return target?.closest(GITLAB_NEXT_TOGGLE_SELECTOR);
};

const isToggleOn = (toggle) => {
  const ariaCheckedElement = toggle.matches('[aria-checked]')
    ? toggle
    : toggle.querySelector('[aria-checked]');

  return ariaCheckedElement?.getAttribute('aria-checked') === 'true';
};

const handleGitlabNextClick = (event) => {
  const toggle = findGitlabNextToggle(event);

  return toggle ? setJHGitlabNext(!isToggleOn(toggle)) : undefined;
};

export const initJHGitlabNext = () => {
  if (initialized) return;

  // Capture the click before the upstream toggle sets a `.gitlab.com`-domain
  // cookie (which is silently ignored on JihuLab) and refreshes the page.
  document.addEventListener('click', handleGitlabNextClick, true);
  initialized = true;
};
