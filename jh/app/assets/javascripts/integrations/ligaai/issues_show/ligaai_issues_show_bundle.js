import Vue from 'vue';

import LigaaiIssuesShowApp from './components/ligaai_issues_show_root.vue';

export default function initLigaaiIssueShow({ mountPointSelector }) {
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
    render: (createElement) => createElement(LigaaiIssuesShowApp),
  });
}
