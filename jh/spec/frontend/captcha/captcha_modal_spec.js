import { GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import { stubComponent } from 'helpers/stub_component';
import CaptchaModal from 'jh/captcha/captcha_modal.vue';
import TencentCaptchaButton from 'jh/captcha/tencent/captcha_button.vue';
import GeetestCaptchaButton from 'jh/captcha/geetest/captcha_button.vue';
import { initTencentCaptchaScript } from 'jh/captcha/tencent/init_script';
import { initGeetestCaptchaScript } from 'jh/captcha/geetest/init_script';

jest.mock('jh/captcha/tencent/init_script');
jest.mock('jh/captcha/geetest/init_script');

const { gon } = window;

describe('Captcha Modal', () => {
  let wrapper;
  let modal;
  let captcha;

  const captchaSiteKey = 'abc123';

  function createComponent() {
    wrapper = shallowMount(CaptchaModal, {
      propsData: {
        captchaSiteKey,
      },
      stubs: {
        GlModal: stubComponent(GlModal),
      },
    });
  }

  beforeEach(() => {
    captcha = jest.fn();

    initTencentCaptchaScript.mockResolvedValue(captcha);
    initGeetestCaptchaScript.mockResolvedValue(captcha);
  });

  afterEach(() => {
    window.gon = gon;
  });

  const findGlModal = () => {
    const glModal = wrapper.findComponent(GlModal);

    jest.spyOn(glModal.vm, 'show').mockImplementation(() => glModal.vm.$emit('shown'));
    jest
      .spyOn(glModal.vm, 'hide')
      .mockImplementation(() => glModal.vm.$emit('hide', { trigger: '' }));

    return glModal;
  };
  const findTencentCaptchaButton = () => wrapper.findComponent(TencentCaptchaButton);
  const findGeetestCaptchaButton = () => wrapper.findComponent(GeetestCaptchaButton);

  const showModal = () => {
    wrapper.setProps({ needsCaptchaResponse: true });
  };

  beforeEach(() => {
    createComponent();
    modal = findGlModal();
  });

  describe('rendering', () => {
    it('renders', () => {
      expect(modal.exists()).toBe(true);
    });

    it('assigns the modal a unique ID', () => {
      const firstModalInstanceId = modal.props('modalId');
      createComponent();
      const secondInstanceModalId = findGlModal().props('modalId');
      expect(firstModalInstanceId).not.toEqual(secondInstanceModalId);
    });
  });

  describe('functionality', () => {
    describe('when modal is shown', () => {
      describe('when tencent captcha is enabled', () => {
        beforeEach(() => {
          window.gon = {
            ...gon,
            tencent_captcha_replacement_enabled: true,
          };
          createComponent();
          modal = findGlModal();
        });

        describe('when tencent_captcha_button.vue emit a captcha response successfully', () => {
          beforeEach(async () => {
            showModal();

            await nextTick();
          });

          it('shows modal', () => {
            expect(modal.vm.show).toHaveBeenCalled();
          });

          it('renders tencent_captcha_button.vue', () => {
            expect(findTencentCaptchaButton().isVisible()).toBe(true);
          });

          describe('then the user solves the captcha', () => {
            const captchaResponse = 'a captcha response';

            beforeEach(() => {
              findTencentCaptchaButton().vm.$emit('receivedCaptchaResponse', captchaResponse);
            });

            it('emits receivedCaptchaResponse exactly once with the captcha response', () => {
              expect(wrapper.emitted('receivedCaptchaResponse')).toEqual([[captchaResponse]]);
            });

            it('hides modal with null trigger', () => {
              // Assert that hide is called with zero args, so that we don't trigger the logic
              // for hiding the modal via cancel, esc, headerclose, etc, without a captcha response
              expect(modal.vm.hide).toHaveBeenCalledWith();
            });
          });

          describe('then the user hides the modal without solving the captcha', () => {
            // Even though we don't explicitly check for these trigger values, these are the
            // currently supported ones which can be emitted.
            // See https://bootstrap-vue.org/docs/components/modal#prevent-closing
            describe.each`
              trigger          | expected
              ${'cancel'}      | ${[[null]]}
              ${'esc'}         | ${[[null]]}
              ${'backdrop'}    | ${[[null]]}
              ${'headerclose'} | ${[[null]]}
            `('using the $trigger trigger', ({ trigger, expected }) => {
              beforeEach(() => {
                const bvModalEvent = {
                  trigger,
                };
                modal.vm.$emit('hide', bvModalEvent);
              });

              it(`emits receivedCaptchaResponse with ${JSON.stringify(expected)}`, () => {
                expect(wrapper.emitted('receivedCaptchaResponse')).toEqual(expected);
              });
            });
          });
        });

        describe('when tencent_captcha_button.vue emit a null captcha response', () => {
          beforeEach(() => {
            showModal();
            findTencentCaptchaButton().vm.$emit('receivedCaptchaResponse', null);
          });

          it('emits receivedCaptchaResponse exactly once with null', () => {
            expect(wrapper.emitted('receivedCaptchaResponse')).toEqual([[null]]);
          });

          it('hides modal with null trigger', () => {
            // Assert that hide is called with zero args, so that we don't trigger the logic
            // for hiding the modal via cancel, esc, headerclose, etc, without a captcha response
            expect(modal.vm.hide).toHaveBeenCalledWith();
          });
        });
      });
      describe('when geetest captcha is enabled', () => {
        beforeEach(() => {
          window.gon = {
            ...gon,
            geetest_captcha_replacement_enabled: true,
          };
          createComponent();
          modal = findGlModal();
        });

        describe('when geetest_captcha_button.vue emit a captcha response successfully', () => {
          beforeEach(async () => {
            showModal();

            await nextTick();
          });

          it('shows modal', () => {
            expect(modal.vm.show).toHaveBeenCalled();
          });

          it('renders geetest_captcha_button.vue', () => {
            expect(findGeetestCaptchaButton().isVisible()).toBe(true);
          });

          describe('then the user solves the captcha', () => {
            const captchaResponse = 'a captcha response';

            beforeEach(() => {
              findGeetestCaptchaButton().vm.$emit('receivedCaptchaResponse', captchaResponse);
            });

            it('emits receivedCaptchaResponse exactly once with the captcha response', () => {
              expect(wrapper.emitted('receivedCaptchaResponse')).toEqual([[captchaResponse]]);
            });

            it('hides modal with null trigger', () => {
              // Assert that hide is called with zero args, so that we don't trigger the logic
              // for hiding the modal via cancel, esc, headerclose, etc, without a captcha response
              expect(modal.vm.hide).toHaveBeenCalledWith();
            });
          });

          describe('then the user hides the modal without solving the captcha', () => {
            // Even though we don't explicitly check for these trigger values, these are the
            // currently supported ones which can be emitted.
            // See https://bootstrap-vue.org/docs/components/modal#prevent-closing
            describe.each`
              trigger          | expected
              ${'cancel'}      | ${[[null]]}
              ${'esc'}         | ${[[null]]}
              ${'backdrop'}    | ${[[null]]}
              ${'headerclose'} | ${[[null]]}
            `('using the $trigger trigger', ({ trigger, expected }) => {
              beforeEach(() => {
                const bvModalEvent = {
                  trigger,
                };
                modal.vm.$emit('hide', bvModalEvent);
              });

              it(`emits receivedCaptchaResponse with ${JSON.stringify(expected)}`, () => {
                expect(wrapper.emitted('receivedCaptchaResponse')).toEqual(expected);
              });
            });
          });
        });

        describe('when geetest_captcha_button.vue emit a null captcha response', () => {
          beforeEach(() => {
            showModal();
            findGeetestCaptchaButton().vm.$emit('receivedCaptchaResponse', null);
          });

          it('emits receivedCaptchaResponse exactly once with null', () => {
            expect(wrapper.emitted('receivedCaptchaResponse')).toEqual([[null]]);
          });

          it('hides modal with null trigger', () => {
            // Assert that hide is called with zero args, so that we don't trigger the logic
            // for hiding the modal via cancel, esc, headerclose, etc, without a captcha response
            expect(modal.vm.hide).toHaveBeenCalledWith();
          });
        });
      });
    });
  });
});
