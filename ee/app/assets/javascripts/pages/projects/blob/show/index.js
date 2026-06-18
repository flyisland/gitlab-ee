import { initEEBlobShow } from 'ee/blob/show/blob_show_bundle';
import * as Sentry from '~/sentry/sentry_browser_wrapper';

if (gon.features?.vue3MigrateRepository) {
  (async () => {
    try {
      // eslint-disable-next-line no-shadow -- Override with Vue 3 app
      const { initEEBlobShow } = await import('ee/blob/show/blob_show_bundle?vue3');
      initEEBlobShow();
      return;
    } catch (e) {
      Sentry.captureException(e);
    }

    initEEBlobShow();
  })();
} else {
  initEEBlobShow();
}
