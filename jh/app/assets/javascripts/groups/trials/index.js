import Vue from 'vue';
import TrialsBanner from './components/trial_banner.vue';

export const initTrialsBanner = () => {
  const el = document.querySelector('.js-jh-trials-banner');

  if (!el) {
    return null;
  }

  const { trialPath, exploreOptionsPath } = el.dataset;

  return new Vue({
    el,
    render(h) {
      return h(TrialsBanner, {
        props: {
          trialPath,
          exploreOptionsPath,
        },
      });
    },
  });
};
