<script>
import { GlBreadcrumb, GlButton, GlLink } from '@gitlab/ui';
import { s__ } from '~/locale';
import WizardStepper from '~/vue_shared/components/wizard_stepper/wizard_stepper.vue';
import { WIZARD_STEPS } from '../../constants';
import DetailsScopeStep from './steps/details_scope_step.vue';
import TriggerStep from './steps/trigger_step.vue';
import RulesStep from './steps/rules_step.vue';
import ActionsStep from './steps/actions_step.vue';

const STEP_COMPONENTS = {
  1: DetailsScopeStep,
  2: TriggerStep,
  3: RulesStep,
  4: ActionsStep,
};

const STEP_KEYS = {
  1: 'details',
  2: 'trigger',
  3: 'rules',
  4: 'actions',
};

export default {
  name: 'CreatePolicyWizard',
  components: {
    GlBreadcrumb,
    GlButton,
    GlLink,
    WizardStepper,
  },
  emits: ['cancel', 'submit'],
  data() {
    return {
      currentStep: 1,
      policyData: {
        details: { name: '', description: '', enforcementMode: 'enforce', scope: 'all' },
        trigger: { triggerId: null, config: {} },
        rules: [],
        actions: [],
      },
      wizardSteps: WIZARD_STEPS,
      breadcrumbItems: [
        { text: s__('SecurityOrchestration|Policies'), href: '#' },
        { text: s__('SecurityOrchestration|Create Policy') },
      ],
    };
  },
  computed: {
    activeStepComponent() {
      return STEP_COMPONENTS[this.currentStep];
    },
    activeStepValue() {
      return this.policyData[STEP_KEYS[this.currentStep]];
    },
  },
  methods: {
    onStepInput(val) {
      this.policyData[STEP_KEYS[this.currentStep]] = val;
    },
    next() {
      if (this.currentStep < 4) {
        this.currentStep += 1;
      }
    },
    back() {
      if (this.currentStep > 1) {
        this.currentStep -= 1;
      }
    },
    cancel() {
      this.$emit('cancel');
    },
    submit() {
      this.$emit('submit', this.policyData);
    },
  },
};
</script>

<template>
  <div class="gl-mx-auto gl-max-w-4xl gl-px-4 gl-py-5">
    <gl-breadcrumb :items="breadcrumbItems" class="gl-mb-3" />
    <gl-link href="#" class="gl-mb-4 gl-block"
      >&larr; {{ s__('SecurityOrchestration|Back to Dashboard') }}</gl-link
    >
    <h1 class="gl-heading-1 gl-mb-5">{{ s__('SecurityOrchestration|Create Policy') }}</h1>
    <wizard-stepper :steps="wizardSteps" :current-step="currentStep" />
    <component
      :is="activeStepComponent"
      :value="activeStepValue"
      @input="onStepInput"
      @next="next"
      @back="back"
      @cancel="cancel"
      @submit="submit"
    />
  </div>
</template>
