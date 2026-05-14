import { nextTick } from 'vue';
import { GlAlert, GlFormInput } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
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

  const defaultProps = {
    selectedPlan: { value: PLAN_PREMIUM, name: 'Premium' },
    purchaseLink: 'https://cdot.com/subscriptions/new?gl_namespace_id=42&plan_id=premium-plan-id',
    status: STEP_STATUS_ACTIVE,
  };

  const createComponent = (props = {}, mountFn = shallowMountExtended) => {
    wrapper = mountFn(CreditSelectionStep, {
      propsData: {
        ...defaultProps,
        ...props,
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
      delete window.location;
      window.location = { assign: jest.fn() };
    });

    it('redirects without add-on params when included option is selected', async () => {
      findCreditSelection().vm.$emit('select', CREDIT_OPTION_INCLUDED);
      await nextTick();

      await findCreditContinue().trigger('click');

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
});
