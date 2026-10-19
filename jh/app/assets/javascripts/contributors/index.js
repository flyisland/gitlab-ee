import Vue from 'vue';
import { createStore } from '~/contributors/stores';
import ContributorsGraphs from './components/contributors.vue';

export default () => {
  const el = document.querySelector('.js-contributors-graph');

  if (!el) return null;

  const { projectGraphPath, projectBranch, defaultBranch } = el.dataset;
  const store = createStore(defaultBranch);

  return new Vue({
    el,
    store,

    render(createElement) {
      return createElement(ContributorsGraphs, {
        props: {
          endpoint: projectGraphPath,
          branch: projectBranch,
        },
      });
    },
  });
};
