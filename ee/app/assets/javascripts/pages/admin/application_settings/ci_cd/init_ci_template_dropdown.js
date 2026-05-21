import Vue from 'vue';
import CiTemplateDropdown from './ci_template_dropdown.vue';

export function initCiTemplateDropdown() {
  const el = document.querySelector('.js-ci-template-dropdown');

  if (!el) {
    return null;
  }

  const { gitlabCiYmls, value } = el.dataset;

  return new Vue({
    el,
    name: 'CiTemplateDropdownRoot',
    provide: {
      gitlabCiYmls: JSON.parse(gitlabCiYmls),
      initialSelectedGitlabCiYmlName: value,
    },
    render(createElement) {
      return createElement(CiTemplateDropdown);
    },
  });
}
