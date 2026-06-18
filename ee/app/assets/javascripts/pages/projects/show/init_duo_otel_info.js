import Vue from 'vue';
import DuoOtelInfo from './components/duo_otel_info.vue';

export function initDuoOtelInfo() {
  const el = document.getElementById('js-duo-otel-info');

  if (!el) {
    return null;
  }

  const { createWorkflowPath } = el.dataset;

  return new Vue({
    el,
    name: 'DuoOtelInfoRoot',
    render(h) {
      return h(DuoOtelInfo, {
        props: {
          createWorkflowPath,
        },
      });
    },
  });
}
