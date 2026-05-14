import { nextTick } from 'vue';
import { GlCard } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import UpgradeSubscriptionApp from 'ee/billings/upgrade_subscription/components/app.vue';
import CreditSelectionStep from 'ee/billings/upgrade_subscription/components/credit_selection_step.vue';
import PlanSelection from 'ee/billings/upgrade_subscription/components/plan_selection.vue';
import PlanSummary from 'ee/billings/upgrade_subscription/components/plan_summary.vue';
import StepHeader from 'ee/billings/upgrade_subscription/components/step_header.vue';
import {
  PLAN_PREMIUM,
  PLAN_ULTIMATE,
  STEP_STATUS_ACTIVE,
  STEP_STATUS_COMPLETE,
  STEP_STATUS_DISABLED,
} from 'ee/billings/upgrade_subscription/constants';

const { bindInternalEventDocument } = useMockInternalEventsTracking();

describe('UpgradeSubscriptionApp component', () => {
  let wrapper;
  let trackingSpy;

  const defaultProvide = {
    premiumPlanPurchaseLink:
      'https://cdot.com/subscriptions/new?gl_namespace_id=42&plan_id=premium-plan-id',
    ultimatePlanPurchaseLink:
      'https://cdot.com/subscriptions/new?gl_namespace_id=42&plan_id=ultimate-plan-id',
    premiumPricePerMonth: '29',
    ultimatePricePerMonth: '99',
  };

  const createComponent = (provide = {}) => {
    wrapper = shallowMountExtended(UpgradeSubscriptionApp, {
      provide: {
        ...defaultProvide,
        ...provide,
      },
    });
  };

  const findPlanSelectionContainer = () => wrapper.findByTestId('select-plan-container');
  const findPlanSelection = () => findPlanSelectionContainer().findComponent(PlanSelection);
  const findPlanStepHeader = () => wrapper.findComponent(StepHeader);
  const findCreditSelectionStep = () => wrapper.findComponent(CreditSelectionStep);
  const findPlanContinue = () => wrapper.findByTestId('plan-selection-continue');
  const findPlanSelectionSummary = () => wrapper.findByTestId('select-plan-summary');

  describe('step 1 - plan selection', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the plan step header with active state', () => {
      expect(findPlanStepHeader().props()).toMatchObject({
        stepNumber: 1,
        status: STEP_STATUS_ACTIVE,
      });
    });

    it('renders the credit selection step with disabled status', () => {
      expect(findCreditSelectionStep().props('status')).toBe(STEP_STATUS_DISABLED);
    });

    it('renders the plan selection component', () => {
      expect(findPlanSelection().exists()).toBe(true);
    });

    it('passes plans with correct data', () => {
      const { plans } = findPlanSelection().props();

      expect(plans).toHaveLength(2);
      expect(plans[0]).toMatchObject({
        value: PLAN_PREMIUM,
        pricePerMonth: 29,
        recommended: true,
        precedingPlanText: 'Everything from Free, plus:',
      });
      expect(plans[1]).toMatchObject({
        value: PLAN_ULTIMATE,
        pricePerMonth: 99,
        precedingPlanText: 'Everything from Premium, plus:',
      });
    });

    it('pre-selects premium plan by default', () => {
      expect(findPlanSelection().props('selectedPlanId')).toBe(PLAN_PREMIUM);
    });

    it('enables continue button by default with pre-selected plan', () => {
      expect(findPlanContinue().attributes('disabled')).toBeUndefined();
    });

    it('does not show plan step summary', () => {
      expect(findPlanSelectionSummary().exists()).toBe(false);
    });
  });

  describe('when continuing to credit selection', () => {
    beforeEach(async () => {
      createComponent();
      findPlanContinue().vm.$emit('click');
      await nextTick();
    });

    it('hides the plan selection and continue button', () => {
      expect(findPlanSelection().exists()).toBe(false);
      expect(findPlanContinue().exists()).toBe(false);
    });

    it('marks plan step header as complete', () => {
      expect(findPlanStepHeader().props('status')).toBe(STEP_STATUS_COMPLETE);
    });

    it('marks credit selection step as active', () => {
      expect(findCreditSelectionStep().props('status')).toBe(STEP_STATUS_ACTIVE);
    });

    it('shows the selected plan summary with GlCard and PlanSummary', () => {
      expect(findPlanSelectionSummary().exists()).toBe(true);

      const card = findPlanSelectionSummary().findComponent(GlCard);
      expect(card.exists()).toBe(true);

      const summary = findPlanSelectionSummary().findComponent(PlanSummary);
      expect(summary.exists()).toBe(true);
      expect(summary.props('plan')).toMatchObject({ value: PLAN_PREMIUM, name: 'Premium' });
      expect(summary.props('showPricingBorders')).toBe(false);
    });

    it('returns to plan step when step header emits edit', async () => {
      findPlanStepHeader().vm.$emit('edit');
      await nextTick();

      const planSelection = findPlanSelection();
      expect(planSelection.exists()).toBe(true);
      expect(planSelection.props('selectedPlanId')).toBe(PLAN_PREMIUM);
      expect(findPlanSelectionSummary().exists()).toBe(false);
      expect(findCreditSelectionStep().props('status')).toBe(STEP_STATUS_DISABLED);
    });

    it('passes correct props to credit selection step', () => {
      expect(findCreditSelectionStep().props('selectedPlan')).toMatchObject({
        value: PLAN_PREMIUM,
      });
      expect(findCreditSelectionStep().props('purchaseLink')).toContain('premium-plan-id');
    });
  });

  describe('tracking plan selection', () => {
    beforeEach(() => {
      createComponent();
      trackingSpy = bindInternalEventDocument(wrapper.element).trackEventSpy;
      trackingSpy.mockClear();
    });

    it('tracks click_continue_with_plan_selected event with premium', async () => {
      findPlanContinue().vm.$emit('click');
      await nextTick();

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_continue_with_plan_selected',
        { property: 'continue_premium' },
        undefined,
      );
    });

    it('tracks click_continue_with_plan_selected event with ultimate', async () => {
      findPlanSelection().vm.$emit('select', PLAN_ULTIMATE);
      await nextTick();

      findPlanContinue().vm.$emit('click');
      await nextTick();

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_continue_with_plan_selected',
        { property: 'continue_ultimate' },
        undefined,
      );
    });
  });
});
