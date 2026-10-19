import { mount } from '@vue/test-utils';
import { GlButton, GlModal } from '@gitlab/ui';
import AppealModal from 'jh/appeal/components/appeal_modal.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { stubComponent } from 'helpers/stub_component';
import { createAppeal } from 'jh/api/appeal_api';
import { createAlert, VARIANT_SUCCESS } from '~/alert';
import { ERROR_MESSAGE, SUCCESS_MESSAGE } from 'jh/appeal/constants';

jest.mock('jh/api/appeal_api');
jest.mock('~/alert', () => ({
  ...jest.requireActual('~/alert'),
  createAlert: jest.fn(),
}));

describe('Appeal modal component', () => {
  let wrapper;
  let modal;
  const findModal = () => wrapper.findComponent(GlModal);
  const findSubmitButton = () => wrapper.findAllComponents(GlButton).at(1);

  beforeEach(() => {
    wrapper = mount(AppealModal, {
      data() {
        return {
          id: '1',
          projectFullPath: 'test/testPath',
          path: 'testPath',
          description: '',
        };
      },
      stubs: {
        GlModal: stubComponent(GlModal, {
          template: `
            <div>
              <slot name="modal-title"></slot>
              <slot></slot>
              <slot name="modal-footer"></slot>
            </div>`,
        }),
      },
      attrs: {
        static: true,
        visible: true,
      },
      attachTo: document.body,
    });
    modal = findModal();
    jest.spyOn(wrapper.vm, 'hideModal');
  });

  afterEach(() => {
    createAlert.mockReset();
    createAppeal.mockReset();
  });

  it('hide modal when click cancel', async () => {
    const cancelButton = modal.find('[data-qa-selector="appeal_cancel_button"]');
    cancelButton.trigger('click');

    await waitForPromises();

    expect(wrapper.vm.visible).toBe(false);
  });

  describe('with empty description', () => {
    it('disable appeal submit button', async () => {
      const appealButton = modal.find('[data-qa-selector="appeal_submit_button"]');
      expect(findSubmitButton().props('disabled')).toBe(true);

      appealButton.trigger('click');

      await waitForPromises();

      expect(modal.isVisible()).toBe(true);
      expect(createAppeal).not.toHaveBeenCalled();
    });
  });

  describe('with non-empty description', () => {
    beforeEach(() => {
      wrapper.vm.description = 'test description';
    });
    it('enable appeal submit button', () => {
      // const appealButton = modal.find('[data-qa-selector="appeal_submit_button"]');
      expect(findSubmitButton().props('disabled')).toBe(false);
    });
    it('create success flash when submission is successful', async () => {
      const appealButton = modal.find('[data-qa-selector="appeal_submit_button"]');
      createAppeal.mockReturnValue(Promise.resolve({ data: 'success' }));
      appealButton.trigger('click');

      await waitForPromises();

      expect(wrapper.vm.visible).toBe(false);
      expect(createAppeal).toHaveBeenCalledTimes(1);
      const expected = {
        message: SUCCESS_MESSAGE,
        variant: VARIANT_SUCCESS,
      };
      expect(createAlert).toHaveBeenNthCalledWith(1, expected);
    });

    it('create error flash when submission is failed', async () => {
      const appealButton = modal.find('[data-qa-selector="appeal_submit_button"]');
      createAppeal.mockReturnValue(Promise.reject(new Error('fail')));
      appealButton.trigger('click');

      await waitForPromises();

      expect(createAppeal).toHaveBeenCalledTimes(1);
      expect(createAlert).toHaveBeenNthCalledWith(1, { message: ERROR_MESSAGE });
    });
  });
});
