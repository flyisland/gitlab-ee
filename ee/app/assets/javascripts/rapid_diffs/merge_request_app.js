import Vue from 'vue';
import { pinia } from '~/pinia/instance';
import { adapters } from '~/rapid_diffs/app/adapter_configs/merge_request';
import { MergeRequestRapidDiffsApp } from '~/rapid_diffs/merge_request_app';
import { useCodeQuality } from '~/rapid_diffs/stores/code_quality';
import { useFindingsDrawer } from '~/mr_notes/store/findings_drawer';
import { lineCodeQualityAdapter } from 'ee/rapid_diffs/adapters/line_code_quality';
import FindingsDrawer from 'ee/diffs/components/shared/findings_drawer.vue';

class MergeRequestRapidDiffsAppEE extends MergeRequestRapidDiffsApp {
  adapterConfig = {
    ...adapters,
    text_inline: [...adapters.text_inline, lineCodeQualityAdapter],
    text_parallel: [...adapters.text_parallel, lineCodeQualityAdapter],
  };

  async init() {
    const appInitialized = super.init();
    this.#initCodeQuality();
    await appInitialized;
  }

  #initCodeQuality() {
    const { codequalityEndpoint, projectPath, projectName } = this.appData;
    if (!codequalityEndpoint) return;

    const store = useCodeQuality(pinia);
    store.endpoint = codequalityEndpoint;
    store.fetchCodeQuality();

    const drawerStore = useFindingsDrawer(pinia);
    // eslint-disable-next-line no-new
    new Vue({
      el: this.root.appendChild(document.createElement('div')),
      pinia,
      name: 'FindingsDrawerRoot',
      render: (h) =>
        store.hasFindings
          ? h(FindingsDrawer, {
              props: {
                drawer: drawerStore.activeDrawer,
                project: { fullPath: projectPath, nameWithNamespace: projectName },
              },
              on: { close: () => drawerStore.setDrawer({}) },
            })
          : null,
    });
  }
}

export const createMergeRequestRapidDiffsApp = (options) => {
  return new MergeRequestRapidDiffsAppEE(options);
};
