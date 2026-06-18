import { initSinglePageApplication } from '~/vue_shared/spa';
import { createRouter } from './router';

export const initCdRoot = () => {
  const el = document.querySelector('.js-cd-root');
  if (!el) {
    return null;
  }

  const { baseRoute } = el.dataset;

  const router = createRouter(baseRoute);

  return initSinglePageApplication({
    name: 'CdRoot',
    el,
    router,
  });
};
