import { nextTick } from 'vue';
import { GlAlert, GlFormInput } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { useMockLocationHelper } from 'helpers/mock_window_location_helper';
import axios from '~/lib/utils/axios_utils';
import CreditSelectionStep from 'ee/billings/upgrade_subscription/components/credit_selection_step.vue';
import PlanSelection from 'ee/billings/upgrade_subscription/components/plan_selection.vue';
import StepHeader from 'ee/billings/upgrade_subscription/components/step_header.vue';
import {
  CREDIT_OPTION_INCLUDED,
  CREDIT_OPTION_MONTHLY,
  PLAN_PREMIUM,
  PLAN_ULTIMATE,
  STEP_STATUS_ACTIVE,
  STEP_STATUS_DISABLED,
} from 'ee/billings/upgrade_subscription/constants';

const { bindInternalEventDocument } = useMockInternalEventsTracking();

describe('CreditSelectionStep component', () => {
  let wrapper;
  let trackingSpy;
  let axiosPostSpy;

  useMockLocationHelper();

  beforeEach(() => {
    axiosPostSpy = jest.spyOn(axios, 'post').mockReturnValue(Promise.resolve());
  });

  afterEach(() => {
    axiosPostSpy.mockRestore();
  });

  const defaultProps = {
    selectedPlan: { value: PLAN_PREMIUM, name: 'Premium' },
    purchaseLink: 'https://cdot.com/subscriptions/new?gl_namespace_id=42&plan_id=premium-plan-id',
    status: STEP_STATUS_ACTIVE,
  };

  const defaultProvide = {
    premiumCartTrackingUrl:
      '/-/gitlab_subscriptions/hand_raise_leads/track_cart_abandonment?namespace_id=42&plan=premium',
    ultimateCartTrackingUrl:
      '/-/gitlab_subscriptions/hand_raise_leads/track_cart_abandonment?namespace_id=42&plan=ultimate',
    creditsCartTrackingUrl:
      '/-/gitlab_subscriptions/hand_raise_leads/track_cart_abandonment?namespace_id=42&credits=0',
  };

  const createComponent = (props = {}, mountFn = shallowMountExtended, provide = {}) => {
    wrapper = mountFn(CreditSelectionStep, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        ...defaultProvide,
        ...provide,
      },
    });
  };

  const findStepHeader = () => wrapper.findComponent(StepHeader);
  const findCreditSelection = () => wrapper.findComponent(PlanSelection);
  const findCreditContinue = () => wrapper.findByTestId('credit-selection-continue');
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findCreditsInput = () => wrapper.findComponent(GlFormInput);
  const setCreditsInputValue = async (value) => {
    findCreditsInput().vm.$emit('input', value);
    await nextTick();
  };

  it('renders the step header with step number 2', () => {
    createComponent();

    expect(findStepHeader().props()).toMatchObject({
      stepNumber: 2,
      status: STEP_STATUS_ACTIVE,
    });
  });

  it('does not render content when status is disabled', () => {
    createComponent({ status: STEP_STATUS_DISABLED });

    expect(findCreditContinue().exists()).toBe(false);
    expect(findCreditSelection().exists()).toBe(false);
  });

  describe('when active', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the credit selection component with two options', () => {
      expect(findCreditSelection().exists()).toBe(true);
      expect(findCreditSelection().props('plans')).toHaveLength(2);
    });

    it('pre-selects included credits option by default', () => {
      expect(findCreditSelection().props('selectedPlanId')).toBe(CREDIT_OPTION_INCLUDED);
    });

    it('enables continue to checkout by default', () => {
      expect(findCreditContinue().props('disabled')).toBe(false);
    });

    it('enables continue to checkout when monthly option with default input is selected', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();

      expect(findCreditContinue().props('disabled')).toBe(false);
    });

    it('does not show alert when included option is selected', () => {
      expect(findAlert().exists()).toBe(false);
    });

    it('shows info alert when monthly option is selected', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();

      expect(findAlert().exists()).toBe(true);
      expect(findAlert().props('variant')).toBe('info');
      expect(findAlert().props('dismissible')).toBe(false);
    });

    it('includes selected plan name in included credits description', () => {
      const creditPlans = findCreditSelection().props('plans');
      expect(creditPlans[0].description).toContain(defaultProps.selectedPlan.name);
    });

    it('shows Premium included credits text for Premium plan', () => {
      const creditPlans = findCreditSelection().props('plans');
      expect(creditPlans[0].precedingPlanText).toContain(
        '12 credits/user/month included in plan for:',
      );
      expect(creditPlans[0].details[0]).toContain('Up to 600 code suggestions');
      expect(creditPlans[0].details[1]).toContain('Up to 48 code reviews');
    });

    it('shows the continue to checkout button', () => {
      expect(findCreditContinue().exists()).toBe(true);
    });
  });

  describe('when active with Ultimate plan', () => {
    beforeEach(() => {
      createComponent({ selectedPlan: { value: PLAN_ULTIMATE, name: 'Ultimate' } });
    });

    it('shows Ultimate included credits text for Ultimate plan', () => {
      const creditPlans = findCreditSelection().props('plans');
      expect(creditPlans[0].precedingPlanText).toContain(
        '24 credits/user/month included in plan for:',
      );
      expect(creditPlans[0].details[0]).toContain('Up to 1200 code suggestions');
      expect(creditPlans[0].details[1]).toContain('Up to 96 code reviews');
    });
  });

  describe('credits input validation', () => {
    beforeEach(async () => {
      createComponent({}, mountExtended);

      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();
    });

    it('disables continue when credits amount is empty', async () => {
      await setCreditsInputValue('');

      expect(findCreditContinue().props('disabled')).toBe(true);
      expect(wrapper.text()).toContain('Minimum 5 credits');
    });

    it('disables continue when credits amount is less than 5', async () => {
      await setCreditsInputValue('3');

      expect(findCreditContinue().props('disabled')).toBe(true);
      expect(wrapper.text()).toContain('Minimum 5 credits');
    });

    it('disables continue when credits amount exceeds 999999', async () => {
      await setCreditsInputValue('1000000');

      expect(findCreditContinue().props('disabled')).toBe(true);
      expect(wrapper.text()).toContain('Cannot exceed 999,999 credits');
    });

    it('disables continue when credits amount is not a valid number', async () => {
      await setCreditsInputValue('abc');

      expect(findCreditContinue().props('disabled')).toBe(true);
      expect(wrapper.text()).toContain('Must be a valid number');
    });

    it('enables continue when credits amount is valid', async () => {
      await setCreditsInputValue(50);

      expect(findCreditContinue().props('disabled')).toBe(false);
      expect(wrapper.text()).not.toContain('Minimum 5 credits');
      expect(wrapper.text()).not.toContain('Cannot exceed 999,999 credits');
      expect(wrapper.text()).not.toContain('Must be a valid number');
    });

    it('shows description when input is valid and hides it on error', async () => {
      expect(wrapper.text()).toContain('We recommend starting with 20 credits per month.');

      await setCreditsInputValue('abc');

      expect(wrapper.text()).not.toContain('We recommend starting with 20 credits per month.');
    });

    it('auto-selects monthly option when credits input is focused', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_INCLUDED);
      await nextTick();

      expect(findCreditSelection().props('selectedPlanId')).toBe(CREDIT_OPTION_INCLUDED);

      findCreditsInput().vm.$emit('focus');
      await nextTick();

      expect(findCreditSelection().props('selectedPlanId')).toBe(CREDIT_OPTION_MONTHLY);
    });
  });

  describe('cost estimation display', () => {
    const findCostEstimation = () => wrapper.findByTestId('cost-estimation');

    beforeEach(async () => {
      createComponent({}, mountExtended);

      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();
    });

    it('shows cost estimation with default credits amount', () => {
      expect(findCostEstimation().text()).toContain('20 × $0.95 = $19.00/mo');
      expect(findCostEstimation().text()).toContain('$228.00/yr');
    });

    it('hides cost estimation when input has an error', async () => {
      await setCreditsInputValue('abc');

      expect(findCostEstimation().exists()).toBe(false);
    });

    it('hides cost estimation when credits are below minimum', async () => {
      await setCreditsInputValue('4');

      expect(findCostEstimation().exists()).toBe(false);
    });

    it('updates cost estimation when credits amount changes', async () => {
      await setCreditsInputValue(5);

      expect(findCostEstimation().text()).toContain('5 × $0.95 = $4.75/mo');
      expect(findCostEstimation().text()).toContain('$57.00/yr');
    });
  });

  describe('credits input error tracking', () => {
    beforeEach(async () => {
      createComponent({}, mountExtended);

      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();

      trackingSpy = bindInternalEventDocument(wrapper.element).trackEventSpy;
      trackingSpy.mockClear();
    });

    it('tracks error_below_minimum when credits amount is empty', async () => {
      await setCreditsInputValue('');

      expect(trackingSpy).toHaveBeenCalledWith(
        'error_input_quantity',
        { property: 'error_below_minimum' },
        undefined,
      );
    });

    it('tracks error_below_minimum when credits amount is less than 5', async () => {
      await setCreditsInputValue('3');

      expect(trackingSpy).toHaveBeenCalledWith(
        'error_input_quantity',
        { property: 'error_below_minimum' },
        undefined,
      );
    });

    it('tracks error_exceeds_maximum when credits amount exceeds 999999', async () => {
      await setCreditsInputValue('1000000');

      expect(trackingSpy).toHaveBeenCalledWith(
        'error_input_quantity',
        { property: 'error_exceeds_maximum' },
        undefined,
      );
    });

    it('tracks error_invalid_characters when credits amount is not a valid number', async () => {
      await setCreditsInputValue('abc');

      expect(trackingSpy).toHaveBeenCalledWith(
        'error_input_quantity',
        { property: 'error_invalid_characters' },
        undefined,
      );
    });

    it('does not track error event when credits amount is valid', async () => {
      await setCreditsInputValue(50);

      expect(trackingSpy).not.toHaveBeenCalled();
    });

    it('does not track same error type consecutively', async () => {
      await setCreditsInputValue('a');
      await setCreditsInputValue('ab');

      expect(trackingSpy).toHaveBeenCalledTimes(1);
    });

    it('tracks when error type changes', async () => {
      await setCreditsInputValue('abc');
      await setCreditsInputValue('3');

      expect(trackingSpy).toHaveBeenCalledTimes(2);
      expect(trackingSpy).toHaveBeenNthCalledWith(
        1,
        'error_input_quantity',
        { property: 'error_invalid_characters' },
        undefined,
      );
      expect(trackingSpy).toHaveBeenNthCalledWith(
        2,
        'error_input_quantity',
        { property: 'error_below_minimum' },
        undefined,
      );
    });

    it('tracks again after valid input clears the error', async () => {
      await setCreditsInputValue('abc');
      await setCreditsInputValue(50);
      await setCreditsInputValue('abc');

      expect(trackingSpy).toHaveBeenCalledTimes(2);
    });
  });

  describe('redirect on continue to checkout', () => {
    beforeEach(() => {
      createComponent({}, mountExtended);
    });

    it('redirects without add-on params when included option is selected', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_INCLUDED);
      await nextTick();

      await findCreditContinue().trigger('click');
      await waitForPromises();

      const assignedUrl = window.location.assign.mock.calls[0][0];
      expect(assignedUrl).toContain('plan_id=premium-plan-id');
      expect(assignedUrl).not.toContain('add_on_plan_type');
      expect(assignedUrl).not.toContain('add_on_quantity');
      expect(assignedUrl).not.toContain('entry_point');
    });

    it('redirects with add-on params when monthly option is selected', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();

      await setCreditsInputValue(50);

      await findCreditContinue().trigger('click');
      await waitForPromises();

      const assignedUrl = window.location.assign.mock.calls[0][0];
      expect(assignedUrl).toContain('plan_id=premium-plan-id');
      expect(assignedUrl).toContain('add_on_plan_type=gitlab_credits');
      expect(assignedUrl).toContain('add_on_quantity=50');
      expect(assignedUrl).toContain('entry_point=com_daisy_chain');
    });
  });

  describe('tracking credit selection', () => {
    beforeEach(() => {
      createComponent({}, mountExtended);
      trackingSpy = bindInternalEventDocument(wrapper.element).trackEventSpy;
      trackingSpy.mockClear();
    });

    it('tracks continue_to_checkout event with included option', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_INCLUDED);
      await nextTick();

      await findCreditContinue().trigger('click');

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_continue_to_checkout',
        { property: 'continue_to_checkout_included', value: undefined },
        undefined,
      );
    });

    it('tracks continue_to_checkout event with monthly option and credit quantity', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();

      await setCreditsInputValue(50);

      await findCreditContinue().trigger('click');

      expect(trackingSpy).toHaveBeenCalledWith(
        'click_continue_to_checkout',
        { property: 'continue_to_checkout_monthly', value: 50 },
        undefined,
      );
    });
  });

  describe('cart abandonment tracking on continue to checkout', () => {
    it('fires premium plan tracking request', async () => {
      createComponent();
      findCreditContinue().vm.$emit('click');
      await waitForPromises();

      expect(axiosPostSpy).toHaveBeenCalledTimes(1);
      expect(axiosPostSpy).toHaveBeenCalledWith(defaultProvide.premiumCartTrackingUrl);
    });

    it('fires ultimate plan tracking request', async () => {
      createComponent({ selectedPlan: { value: PLAN_ULTIMATE } });

      findCreditContinue().vm.$emit('click');
      await waitForPromises();

      expect(axiosPostSpy).toHaveBeenCalledTimes(1);
      expect(axiosPostSpy).toHaveBeenCalledWith(defaultProvide.ultimateCartTrackingUrl);
    });

    it('fires both plan and credits tracking requests when monthly option is selected', async () => {
      createComponent();
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_MONTHLY);
      await nextTick();
      findCreditContinue().vm.$emit('click');
      await waitForPromises();

      expect(axiosPostSpy).toHaveBeenCalledTimes(2);
      expect(axiosPostSpy).toHaveBeenCalledWith(defaultProvide.premiumCartTrackingUrl);
      expect(axiosPostSpy).toHaveBeenCalledWith(defaultProvide.creditsCartTrackingUrl);
    });

    it('does not fire any tracking when no urls are provided', async () => {
      createComponent({}, shallowMountExtended, {
        premiumCartTrackingUrl: '',
        ultimateCartTrackingUrl: '',
        creditsCartTrackingUrl: '',
      });
      findCreditContinue().vm.$emit('click');
      await waitForPromises();

      expect(axiosPostSpy).not.toHaveBeenCalled();
    });

    it('still redirects after firing tracking requests', async () => {
      createComponent();
      findCreditContinue().vm.$emit('click');
      await waitForPromises();

      expect(window.location.assign).toHaveBeenCalledWith(
        expect.stringContaining('plan_id=premium-plan-id'),
      );
    });
  });
});
