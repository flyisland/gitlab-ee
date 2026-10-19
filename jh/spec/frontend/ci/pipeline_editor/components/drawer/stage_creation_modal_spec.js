import { shallowMount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import StageCreationModal from 'jh/ci/pipeline_editor/components/drawer/stage_creation_modal.vue';

describe('<StageCreationModal />', () => {
  let wrapper;
  const createComponent = () => {
    wrapper = shallowMount(StageCreationModal);
  };

  const findModal = () => wrapper.findComponent(GlModal);

  describe('events', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should create stage', () => {
      const modal = findModal();
      const stageName = 'test';
      wrapper.vm.stageName = stageName;
      modal.vm.$emit('primary');

      expect(wrapper.emitted('create-stage')[0][0]).toEqual(stageName);
    });

    it('should close the modal', () => {
      const modal = findModal();
      modal.vm.$emit('canceled');

      expect(wrapper.emitted('close')).toHaveLength(1);
    });
  });
});
