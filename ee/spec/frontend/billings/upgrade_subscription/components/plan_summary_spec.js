import { GlBadge } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import PlanSummary from 'ee/billings/upgrade_subscription/components/plan_summary.vue';

describe('PlanSummary component', () => {
  let wrapper;

  const defaultPlan = {
    name: 'Premium',
    description: 'For scaling organizations.',
    pricePerMonth: 29,
    recommended: true,
  };

  const createComponent = ({ plan = {}, props = {} } = {}) => {
    wrapper = shallowMountExtended(PlanSummary, {
      propsData: {
        plan: { ...defaultPlan, ...plan },
        ...props,
      },
    });
  };

  const findBadge = () => wrapper.findComponent(GlBadge);
  const findPricing = () => wrapper.findByTestId('plan-summary-pricing');

  it('renders the plan name and description', () => {
    createComponent();

    expect(wrapper.find('h2').text()).toBe('Premium');
    expect(wrapper.text()).toContain('For scaling organizations.');
  });

  it('renders the formatted price', () => {
    createComponent();

    expect(wrapper.text()).toContain('$');
    expect(wrapper.text()).toContain('29');
    expect(wrapper.text()).toContain('per user/month, billed annually');
  });

  describe('recommended badge', () => {
    it('renders badge when plan has recommended key', () => {
      createComponent();

      expect(findBadge().exists()).toBe(true);
      expect(findBadge().text()).toBe('Recommended');
    });

    it('does not render badge when plan does not have recommended key', () => {
      createComponent({ plan: { recommended: false } });

      expect(findBadge().exists()).toBe(false);
    });

    it('does not render badge when showRecommendedBadge is false', () => {
      createComponent({ props: { showRecommendedBadge: false } });

      expect(findBadge().exists()).toBe(false);
    });
  });

  it('rounds the price amount when given whole dollars', () => {
    createComponent({ plan: { pricePerMonth: 29.0 } });

    expect(wrapper.text()).toContain('29');
  });

  it('formats sub-dollar amounts with 2 decimal places', () => {
    createComponent({ plan: { pricePerMonth: 0.95 } });

    expect(wrapper.text()).toContain('0.95');
  });

  describe('when pricePerMonth is not provided', () => {
    it('does not render pricing section', () => {
      createComponent({ plan: { pricePerMonth: undefined } });

      expect(findPricing().exists()).toBe(false);
    });
  });

  describe('pricing label', () => {
    it('uses default label when pricingLabel is not provided', () => {
      createComponent();

      expect(wrapper.text()).toContain('per user/month, billed annually');
    });

    it('uses custom pricing labels when provided', () => {
      createComponent({
        plan: {
          pricingLabel: 'per GitLab Credit',
          pricingSubLabel: 'volume discount available',
        },
      });

      expect(wrapper.text()).toContain('per GitLab Credit');
      expect(wrapper.text()).not.toContain('per user/month, billed annually');
      expect(wrapper.text()).toContain('volume discount available');
    });
  });

  describe('pricing borders', () => {
    it('renders borders by default', () => {
      createComponent();

      const classes = findPricing().classes();

      ['gl-border-t', 'gl-border-b', 'gl-my-5', 'gl-py-5'].forEach((cls) => {
        expect(classes).toContain(cls);
      });
    });

    it('does not render borders when showPricingBorders is false', () => {
      createComponent({ props: { showPricingBorders: false } });

      const classes = findPricing().classes();

      ['gl-border-t', 'gl-border-b'].forEach((cls) => {
        expect(classes).not.toContain(cls);
      });
      ['gl-mt-4', 'gl-mb-0', 'gl-py-0'].forEach((cls) => {
        expect(classes).toContain(cls);
      });
    });
  });
});
