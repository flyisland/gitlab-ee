import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ExtraInfo from 'jh_else_ce/super_sidebar/components/extra_info.vue';

describe('ExtraInfo component', () => {
  let wrapper;

  const qrCode = () => wrapper.findByTestId('super-sidebar-qr-code');
  const createWrapper = () => {
    wrapper = shallowMountExtended(ExtraInfo);
  };

  describe('when is self-managed and has no active license', () => {
    beforeEach(() => {
      window.gon = {
        dot_com: false,
        has_active_license: false,
      };
    });

    it('renders the QR code', () => {
      createWrapper({});
      expect(qrCode().exists()).toBe(true);
    });
  });

  describe('when is self-managed but has active license', () => {
    beforeEach(() => {
      window.gon = {
        dot_com: false,
        has_active_license: true,
      };
    });

    it('renders the QR code', () => {
      createWrapper({});
      expect(qrCode().exists()).toBe(false);
    });
  });

  describe('when is not self-managed', () => {
    beforeEach(() => {
      window.gon = {
        dot_com: true,
        has_active_license: false,
      };
    });

    it('renders the QR code', () => {
      createWrapper({});
      expect(qrCode().exists()).toBe(false);
    });
  });
});
