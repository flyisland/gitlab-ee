<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import { InternalEvents } from '~/tracking';
import { VALID_SUBSCRIPTION_STEP_STATUSES } from 'ee/billings/upgrade_subscription/constants';

export default {
  name: 'StepHeader',
  components: {
    GlButton,
    GlIcon,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    stepNumber: {
      type: Number,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      required: false,
      default: 'active',
      validator(value) {
        return VALID_SUBSCRIPTION_STEP_STATUSES.includes(value);
      },
    },
  },
  emits: ['edit'],
  computed: {
    isComplete() {
      return this.status === this.$options.COMPLETE;
    },
    outerCircleColor() {
      return this.status === this.$options.DISABLED ? 'gl-bg-gray-100' : 'gl-bg-status-info';
    },
    innerCircleColor() {
      return this.status === this.$options.DISABLED ? 'gl-bg-gray-300' : 'gl-bg-blue-500';
    },
  },
  methods: {
    handleEdit() {
      this.trackEvent('click_edit_plan_selection', { property: 'edit_plan_selection' });
      this.$emit('edit');
    },
  },
  ACTIVE: 'active',
  COMPLETE: 'complete',
  DISABLED: 'disabled',
  CIRCLE_CLASSES: 'gl-inline-flex gl-items-center gl-justify-center gl-rounded-full',
};
</script>

<template>
  <div :class="['gl-flex gl-justify-between', status !== $options.DISABLED && 'gl-mb-6']">
    <div class="gl-flex gl-items-center gl-gap-3">
      <span
        v-if="isComplete"
        :class="[$options.CIRCLE_CLASSES, 'gl-h-6 gl-w-6 gl-bg-status-success']"
        data-testid="step-icon-complete"
      >
        <gl-icon name="status-success" variant="success" :size="16" />
      </span>
      <span
        v-else
        :class="[$options.CIRCLE_CLASSES, 'gl-h-6 gl-w-6', outerCircleColor]"
        data-testid="step-icon-active"
      >
        <span
          :class="[
            $options.CIRCLE_CLASSES,
            'gl-h-5 gl-w-5 gl-text-sm gl-text-neutral-0',
            innerCircleColor,
          ]"
          data-testid="step-icon-inner"
        >
          {{ stepNumber }}
        </span>
      </span>

      <h2 class="gl-heading-1-fixed gl-mb-0">{{ title }}</h2>
    </div>

    <gl-button v-if="isComplete" data-testid="step-edit" @click="handleEdit">
      {{ __('Edit') }}
    </gl-button>
  </div>
</template>
