import Vue from 'vue';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import LearnGitlab from './components/learn_gitlab.vue';

export function initLearnGitlab() {
  const el = document.getElementById('js-learn-gitlab-app');

  if (!el) {
    return null;
  }

  const actions = convertObjectPropsToCamelCase(JSON.parse(el.dataset.actions));
  const sections = convertObjectPropsToCamelCase(JSON.parse(el.dataset.sections));
  const project = convertObjectPropsToCamelCase(JSON.parse(el.dataset.project));
  const { learnGitlabEndPath } = el.dataset;

  return new Vue({
    el,
    name: 'LearnGitlabRoot',
    render(createElement) {
      return createElement(LearnGitlab, {
        props: { actions, sections, project, learnGitlabEndPath },
      });
    },
  });
}
