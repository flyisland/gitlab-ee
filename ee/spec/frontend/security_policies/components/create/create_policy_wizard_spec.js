import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import CreatePolicyWizard from 'ee/security_policies/components/create/create_policy_wizard.vue';
import WizardStepper from '~/vue_shared/components/wizard_stepper/wizard_stepper.vue';
import DetailsScopeStep from 'ee/security_policies/components/create/steps/details_scope_step.vue';
import TriggerStep from 'ee/security_policies/components/create/steps/trigger_step.vue';
import RulesStep from 'ee/security_policies/components/create/steps/rules_step.vue';
import ActionsStep from 'ee/security_policies/components/create/steps/actions_step.vue';

describe('CreatePolicyWizard', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(CreatePolicyWizard);
  };

  const findStepper = () => wrapper.findComponent(WizardStepper);

  it('renders on step 1 by default', () => {
    createComponent();

    expect(wrapper.findComponent(DetailsScopeStep).exists()).toBe(true);
  });

  it('WizardStepper receives currentStep=1', () => {
    createComponent();

    expect(findStepper().props('currentStep')).toBe(1);
  });

  it('advances to step 2 when step 1 emits next', async () => {
    createComponent();

    wrapper.findComponent(DetailsScopeStep).vm.$emit('next');
    await nextTick();

    expect(findStepper().props('currentStep')).toBe(2);
    expect(wrapper.findComponent(TriggerStep).exists()).toBe(true);
  });

  it('goes back to step 1 when step 2 emits back', async () => {
    createComponent();

    wrapper.findComponent(DetailsScopeStep).vm.$emit('next');
    await nextTick();

    wrapper.findComponent(TriggerStep).vm.$emit('back');
    await nextTick();

    expect(findStepper().props('currentStep')).toBe(1);
    expect(wrapper.findComponent(DetailsScopeStep).exists()).toBe(true);
  });

  it('emits cancel when step emits cancel', () => {
    createComponent();

    wrapper.findComponent(DetailsScopeStep).vm.$emit('cancel');

    expect(wrapper.emitted('cancel')).toBeDefined();
  });

  it('emits submit with policyData when step 4 emits submit', async () => {
    createComponent();

    wrapper.findComponent(DetailsScopeStep).vm.$emit('next');
    await nextTick();

    wrapper.findComponent(TriggerStep).vm.$emit('next');
    await nextTick();

    wrapper.findComponent(RulesStep).vm.$emit('next');
    await nextTick();

    wrapper.findComponent(ActionsStep).vm.$emit('submit');

    expect(wrapper.emitted('submit')).toBeDefined();
    expect(wrapper.emitted('submit')[0][0]).toEqual(
      expect.objectContaining({
        details: expect.any(Object),
        trigger: expect.any(Object),
        rules: expect.any(Array),
        actions: expect.any(Array),
      }),
    );
  });
});
