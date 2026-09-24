import { s__ } from '~/locale';

export const LOADING = 'LOADING';
export const READY = 'READY';
export const RESOLVING = 'RESOLVING';
export const DONE = 'DONE';

export const i18n = {
  [READY]: s__('JH|Captcha|Please click here to finish the verification'),
  [RESOLVING]: s__('JH|Captcha|Verifying'),
  [DONE]: s__('JH|Captcha|Verification finished'),
};
