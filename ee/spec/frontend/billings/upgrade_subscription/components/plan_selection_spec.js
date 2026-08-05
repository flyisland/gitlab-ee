import { GlButton, GlCard, GlFormRadioGroup } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import { PROMO_URL } from '~/constants';
import PlanSelection from 'ee/billings/upgrade_subscription/components/plan_selection.vue';
import PlanSummary from 'ee/billings/upgrade_subscription/components/plan_summary.vue';
import PromoTermsLink from 'ee/billings/upgrade_subscription/components/promo_terms_link.vue';
import { PLAN_PREMIUM, PLAN_ULTIMATE } from 'ee/billings/upgrade_subscription/constants';

const { bindInternalEventDocument } = useMockInternalEventsTracking();

describe('PlanSelection component', () => {
  let wrapper;
  let trackingSpy;

  const defaultPlans = [
    {
      value: PLAN_PREMIUM,
      name: 'Premium',
      pricePerMonth: 29,
      recommended: true,
      precedingPlanText: 'Everything from Free, plus:',
      details: ['$12 in GitLab Credits', 'Unlimited licensed users'],
      featuresLink: `${PROMO_URL}/pricing/${PLAN_PREMIUM}/`,
    },
    {
      value: PLAN_ULTIMATE,
      name: 'Ultimate',
      pricePerMonth: 99,
      precedingPlanText: 'Everything from Premium, plus:',
      details: ['$24 in GitLab Credits', 'Advanced security'],
      featuresLink: `${PROMO_URL}/pricing/${PLAN_ULTIMATE}/`,
    },
  ];

  const creditOptionPlans = [
    {
      value: 'included',
      name: 'Included credits',
      description: 'Best for teams getting started.',
      recommended: false,
      precedingPlanText: '12 credits/user/month included in plan for:',
      details: ['Up to 600 code suggestions', 'Up to 48 code reviews'],
    },
    {
      value: 'monthly',
      name: 'Monthly commitment',
      description: 'Discounted bulk credits.',
      recommended: false,
      pricePerMonth: 0.95,
      precedingPlanText: 'All included credits, plus shared credits for:',
      details: ['Up to 50 additional code suggestions per credit'],
    },
  ];

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(PlanSelection, {
      propsData: {
        plans: defaultPlans,
        selectedPlanId: null,
        ...props,
      },
    });
    trackingSpy = bindInternalEventDocument(wrapper.element).trackEventSpy;
    trackingSpy.mockClear();
  };

  const findRadioGroup = () => wrapper.findComponent(GlFormRadioGroup);
  const findCards = () => wrapper.findAllComponents(GlCard);
  const findPlanSummaries = () => wrapper.findAllComponents(PlanSummary);
  const findFeaturesButtons = () => wrapper.findAllComponents(GlButton);
  const findPromoTermsLinks = () => wrapper.findAllComponents(PromoTermsLink);

  beforeEach(() => {
    createComponent();
  });

  it('renders a card for each plan', () => {
    expect(findCards()).toHaveLength(2);
  });

  it('emits select event when a plan is chosen', () => {
    findRadioGroup().vm.$emit('change', PLAN_ULTIMATE);

    expect(wrapper.emitted('select')).toEqual([[PLAN_ULTIMATE]]);
  });

  it('renders a plan summary for each plan', () => {
    const summaries = findPlanSummaries();
    expect(summaries).toHaveLength(2);
    expect(summaries.at(0).props('plan')).toMatchObject({ name: 'Premium' });
    expect(summaries.at(1).props('plan')).toMatchObject({ name: 'Ultimate' });
  });

  it('renders preceding plan text and details for each plan', () => {
    expect(wrapper.text()).toContain('Everything from Free, plus:');
    expect(wrapper.text()).toContain('$12 in GitLab Credits');
    expect(wrapper.text()).toContain('Unlimited licensed users');

    expect(wrapper.text()).toContain('Everything from Premium, plus:');
    expect(wrapper.text()).toContain('$24 in GitLab Credits');
    expect(wrapper.text()).toContain('Advanced security');
  });

  it('renders features link buttons with correct href', () => {
    const buttons = findFeaturesButtons();

    expect(buttons).toHaveLength(2);
    expect(buttons.at(0).attributes()).toMatchObject({
      href: `${PROMO_URL}/pricing/${PLAN_PREMIUM}/`,
      target: '_blank',
    });
    expect(buttons.at(1).attributes()).toMatchObject({
      href: `${PROMO_URL}/pricing/${PLAN_ULTIMATE}/`,
      target: '_blank',
    });
  });

  describe('when featuresLink is not provided', () => {
    beforeEach(() => {
      createComponent({ plans: creditOptionPlans });
    });

    it('does not render features link', () => {
      expect(findFeaturesButtons()).toHaveLength(0);
    });
  });

  describe('when promoTermsLink is provided', () => {
    beforeEach(() => {
      const plansWithPromo = defaultPlans.map((plan) => ({
        ...plan,
        promoTermsLink: `${PROMO_URL}/pricing/#promo-terms`,
      }));
      createComponent({ plans: plansWithPromo });
    });

    it('renders promo terms link for each plan', () => {
      expect(findPromoTermsLinks()).toHaveLength(2);
      expect(findPromoTermsLinks().at(0).props('href')).toBe(`${PROMO_URL}/pricing/#promo-terms`);
    });
  });

  describe('when promoTermsLink is not provided', () => {
    it('does not render promo terms link', () => {
      expect(findPromoTermsLinks()).toHaveLength(0);
    });
  });

  describe('conditionally renders preceding plan text for each plan', () => {
    beforeEach(() => {
      const plansWithoutPrecedingText = [
        { value: 'a', name: 'Plan A', details: ['detail 1'] },
        { value: 'b', name: 'Plan B', precedingPlanText: 'Some text', details: ['detail 2'] },
      ];
      createComponent({ plans: plansWithoutPrecedingText });
    });

    it('does not render undefined text', () => {
      expect(wrapper.text()).not.toContain('undefined');
    });

    it('renders present preceding plan text', () => {
      expect(wrapper.text()).toContain('Some text');
    });
  });

  it('passes plan data to card-content scoped slot', () => {
    wrapper = shallowMountExtended(PlanSelection, {
      propsData: { plans: defaultPlans, selectedPlanId: null },
      scopedSlots: {
        'card-content': `<div data-testid="slot-probe">{{ props.plan.name }}</div>`,
      },
    });

    const probes = wrapper.findAll('[data-testid="slot-probe"]');
    expect(probes).toHaveLength(2);
    expect(probes.at(0).text()).toBe('Premium');
    expect(probes.at(1).text()).toBe('Ultimate');
  });

  describe('tracking features link clicks', () => {
    it('tracks click_see_all_features event for premium plan', async () => {
      await findFeaturesButtons().at(0).vm.$emit('click');

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_see_all_features_upgrade_subscription_plan_card',
        { property: `see_all_features_${PLAN_PREMIUM}` },
        undefined,
      );
    });

    it('tracks click_see_all_features event for ultimate plan', async () => {
      await findFeaturesButtons().at(1).vm.$emit('click');

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_see_all_features_upgrade_subscription_plan_card',
        { property: `see_all_features_${PLAN_ULTIMATE}` },
        undefined,
      );
    });
  });

  describe('showRecommendedBadge prop', () => {
    describe('when showRecommendedBadge is false', () => {
      beforeEach(() => {
        createComponent({ showRecommendedBadge: false });
      });

      it('passes showRecommendedBadge false to PlanSummary', () => {
        const summaries = findPlanSummaries();
        expect(summaries.at(0).props('showRecommendedBadge')).toBe(false);
        expect(summaries.at(1).props('showRecommendedBadge')).toBe(false);
      });
    });
  });

  describe('when a plan is default selected', () => {
    beforeEach(() => {
      createComponent({ selectedPlanId: PLAN_PREMIUM });
    });

    it('renders the radio group with the selected plan', () => {
      expect(findRadioGroup().attributes('checked')).toBe(PLAN_PREMIUM);
    });
  });
});
