import { GlAlert, GlSprintf } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { assertProps } from 'helpers/assert_props';
import ContactSalesButton from 'ee/orbit/components/trial/contact_sales_button.vue';
import GroupSettingsAlert from 'ee/orbit/settings/group_settings_alert.vue';

describe('OrbitGroupSettingsAlert', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(GroupSettingsAlert, {
      propsData: {
        state: 'free_plan',
        groupName: 'Acme',
        saas: true,
        usageQuotasPath: '/acme/-/usage_quotas',
        ...props,
      },
      stubs: { GlSprintf },
    });
  };

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findContactSales = () => wrapper.findComponent(ContactSalesButton);

  describe('when the state is free_plan', () => {
    beforeEach(() => {
      createComponent({ state: 'free_plan' });
    });

    it('names the group and offers Contact sales', () => {
      expect(findAlert().props('title')).toBe('Orbit is available on Premium and Ultimate');
      expect(findAlert().props('variant')).toBe('info');
      expect(wrapper.text()).toContain('Acme is on the Free plan.');
      expect(findContactSales().props('glmContent')).toBe('orbit-free-plan');
    });
  });

  describe('when the state is unlicensed', () => {
    beforeEach(() => {
      createComponent({ state: 'unlicensed' });
    });

    it('offers Contact sales', () => {
      expect(findAlert().props('title')).toBe('Orbit is not available for this group');
      expect(findContactSales().props('glmContent')).toBe('orbit-unlicensed');
    });
  });

  describe('when the state is cdot_unavailable', () => {
    beforeEach(() => {
      createComponent({ state: 'cdot_unavailable' });
    });

    it('warns and offers Contact sales', () => {
      expect(findAlert().props('variant')).toBe('warning');
      expect(wrapper.text()).toContain('We could not check whether Acme');
      expect(findContactSales().props('glmContent')).toBe('orbit-unavailable');
    });
  });

  describe('when the state is not_eligible', () => {
    beforeEach(() => {
      createComponent({ state: 'not_eligible' });
    });

    it('names the group and offers Contact sales', () => {
      expect(findAlert().props('title')).toBe('Acme is not eligible for a free Orbit trial');
      expect(findContactSales().props('glmContent')).toBe('orbit-not-eligible');
    });
  });

  describe('when the state is trial_ended', () => {
    beforeEach(() => {
      createComponent({ state: 'trial_ended' });
    });

    it('warns and offers Contact sales', () => {
      expect(findAlert().props('variant')).toBe('warning');
      expect(findAlert().props('title')).toBe('Your free Orbit trial has ended');
      expect(wrapper.text()).toContain('Orbit is paused for Acme.');
      expect(findContactSales().props('glmContent')).toBe('orbit-trial-ended');
    });
  });

  describe('when the state is credits_used_up', () => {
    beforeEach(() => {
      createComponent({ state: 'credits_used_up' });
    });

    it('names the group, links to usage quotas, and offers Contact sales', () => {
      expect(findAlert().props('title')).toBe('Acme is out of GitLab credits');
      expect(wrapper.findByText('View usage quotas').attributes('href')).toBe(
        '/acme/-/usage_quotas',
      );
      expect(findContactSales().props('glmContent')).toBe('orbit-credits-used-up');
    });
  });

  describe('with an unknown state', () => {
    it('fails prop validation', () => {
      expect(() =>
        assertProps(GroupSettingsAlert, {
          state: 'nonsense',
          groupName: 'Acme',
          saas: true,
          usageQuotasPath: '/acme/-/usage_quotas',
        }),
      ).toThrow();
    });
  });
});
