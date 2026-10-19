import { GlButton } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import HandRaiseLeadButton from 'ee/hand_raise_leads/hand_raise_lead/components/hand_raise_lead_button.vue';
import ContactSalesButton from 'ee/orbit/components/trial/contact_sales_button.vue';

describe('OrbitContactSalesButton', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(ContactSalesButton, {
      propsData: { saas: false, glmContent: 'orbit-free-plan', ...props },
    });
  };

  const findHandRaise = () => wrapper.findComponent(HandRaiseLeadButton);
  const findLink = () => wrapper.findComponent(GlButton);

  describe('on GitLab.com', () => {
    beforeEach(() => {
      createComponent({ saas: true });
    });

    it('opens the hand-raise lead modal', () => {
      expect(findHandRaise().props('glmContent')).toBe('orbit-free-plan');
      expect(findHandRaise().props('ctaTracking')).toMatchObject({ label: 'orbit_contact_sales' });
      expect(findHandRaise().props('buttonAttributes')).toEqual({ category: 'secondary' });
      expect(findLink().exists()).toBe(false);
    });
  });

  describe('off GitLab.com', () => {
    beforeEach(() => {
      createComponent({ saas: false });
    });

    it('links to the sales page', () => {
      expect(findLink().attributes('href')).toBe('https://about.gitlab.com/sales/');
      expect(findLink().attributes('target')).toBe('_blank');
      expect(findLink().props('category')).toBe('secondary');
      expect(findHandRaise().exists()).toBe(false);
    });
  });
});
