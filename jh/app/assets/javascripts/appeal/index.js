import Vue from 'vue';
import AppealModal from './components/appeal_modal.vue';

let appealModalElement;
let appealModalVueInstance;
export const initAppealModal = ({ projectFullPath, path, id }) => {
  if (!(appealModalElement && appealModalVueInstance)) {
    appealModalElement = document.createElement('div');
    document.body.append(appealModalElement);

    appealModalVueInstance = new Vue(AppealModal);
    appealModalVueInstance.$mount(appealModalElement);
  }
  appealModalVueInstance.projectFullPath = projectFullPath;
  appealModalVueInstance.path = path;
  appealModalVueInstance.id = id;
  appealModalVueInstance.visible = true;
  return appealModalVueInstance;
};

export const addAppealModalPopupListener = () => {
  document.addEventListener('click', (e) => {
    const el = e.target;
    if (el.classList.contains('js-appeal-modal')) {
      const { projectFullPath, path, id } = el.dataset;

      initAppealModal({
        projectFullPath,
        path,
        id,
      });
    }
  });
};
