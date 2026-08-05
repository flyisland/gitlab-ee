import Vue from 'vue';
import RefSelector from '~/ref/components/ref_selector.vue';
import { __ } from '~/locale';

export function initTargetBranchRefSwitcher() {
  const refSwitcherEl = document.getElementById('js-target-branch');

  if (!refSwitcherEl) {
    return null;
  }

  const { projectId } = refSwitcherEl.dataset;

  return new Vue({
    el: refSwitcherEl,
    name: 'RefSelectorRoot',
    render(createElement) {
      return createElement(RefSelector, {
        props: {
          projectId,
          value: '',
          useSymbolicRefNames: true,
          queryParams: { sort: 'updated_desc' },
          enabledRefTypes: ['REF_TYPE_BRANCHES'],
          translations: {
            noRefSelected: __('No branch selected'),
          },
        },
        on: {
          input(selectedRef) {
            document.getElementById('projects_target_branch_rule_target_branch').value =
              selectedRef.replace(/^refs\/(tags|heads)\//, '');
          },
        },
      });
    },
  });
}
