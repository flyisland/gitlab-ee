import PhoneVerificationApp from 'jh/phone/app.vue';
import { GREETING_MESSAGE, REGULATIONS } from 'jh/phone/constants';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

const gon = window?.gon;

describe('Terms app', () => {
  const defaultProvide = {
    paths: {
      accept: '/-/users/phone/verify',
    },
  };
  const createComponent = (provide = {}) =>
    shallowMountExtended(PhoneVerificationApp, {
      provide: {
        ...defaultProvide,
        ...provide,
      },
    });

  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper?.destroy();
    window.gon = gon;
  });

  describe('Phone verification App', () => {
    it('render correctly', () => {
      expect(wrapper.html()).toContain(GREETING_MESSAGE);
      expect(wrapper.html()).toContain(REGULATIONS);
    });
  });
});
