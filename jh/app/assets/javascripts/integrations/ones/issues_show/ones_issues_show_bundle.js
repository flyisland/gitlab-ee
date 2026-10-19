import Vue from 'vue';

import OnesIssuesShowApp from './components/ones_issues_show_root.vue';

export default function initOnesIssueShow({ mountPointSelector }) {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  const { issuesShowPath, issuesListPath } = mountPointEl.dataset;

  return new Vue({
    el: mountPointEl,
    provide: {
      issuesShowPath,
      issuesListPath,
      isClassicSidebar: true,
      canUpdate: false,
    },
    render: (createElement) => createElement(OnesIssuesShowApp),
  });
}
