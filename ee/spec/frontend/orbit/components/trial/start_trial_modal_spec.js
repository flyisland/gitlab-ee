import { GlModal, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import StartTrialModal from 'ee/orbit/components/trial/start_trial_modal.vue';

describe('OrbitStartTrialModal', () => {
  let wrapper;

  const createComponent = ({ starting = false } = {}) => {
    wrapper = shallowMountExtended(StartTrialModal, {
      propsData: { visible: true, groupName: 'Acme', starting },
      stubs: { GlSprintf },
    });
  };

  const findModal = () => wrapper.findComponent(GlModal);

  beforeEach(() => {
    createComponent();
  });

  describe('when the trial is not starting yet', () => {
    it('asks the user to confirm and names the group', () => {
      expect(findModal().props('title')).toBe('Start a free Orbit trial?');
      expect(wrapper.text()).toContain('Orbit turns on for Acme');
    });

    it('confirms with a Start free trial button', () => {
      expect(findModal().props('actionPrimary')).toMatchObject({
        text: 'Start free trial',
        attributes: { variant: 'confirm', loading: false },
      });
    });
  });

  describe('when the trial is starting', () => {
    beforeEach(() => {
      createComponent({ starting: true });
    });

    it('shows the button as loading', () => {
      expect(findModal().props('actionPrimary').attributes.loading).toBe(true);
    });
  });

  describe('when the user confirms', () => {
    beforeEach(() => {
      findModal().vm.$emit('primary', { preventDefault: jest.fn() });
    });

    it('emits start-trial', () => {
      expect(wrapper.emitted('start-trial')).toHaveLength(1);
    });
  });

  describe('when the modal hides', () => {
    beforeEach(() => {
      findModal().vm.$emit('hidden');
    });

    it('emits hide', () => {
      expect(wrapper.emitted('hide')).toHaveLength(1);
    });
  });
});
