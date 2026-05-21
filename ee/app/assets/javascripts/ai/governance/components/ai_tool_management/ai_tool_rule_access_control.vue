<script>
import { GlButton, GlButtonGroup, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';

const ACCESS_OPTIONS = [
  {
    value: 'ALLOW',
    icon: 'check',
    label: s__('AiGovernance|Allow'),
    selectedIconClass: 'gl-text-green-500',
  },
  { value: 'ASK', icon: 'question-o', label: s__('AiGovernance|Ask') },
  {
    value: 'DENY',
    icon: 'close',
    label: s__('AiGovernance|Deny'),
    selectedIconClass: 'gl-text-red-500',
  },
];

export default {
  name: 'AiToolRuleAccessControl',
  components: {
    GlButton,
    GlButtonGroup,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    value: {
      type: String,
      required: false,
      default: null,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    disabledTooltip: {
      type: String,
      required: false,
      default: '',
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select'],
  ACCESS_OPTIONS,
  methods: {
    handleSelect(newValue, event) {
      event.currentTarget.blur();
      if (newValue === this.value || this.isLoading) return;
      this.$emit('select', newValue);
    },
  },
};
</script>

<template>
  <span
    v-gl-tooltip="disabled ? disabledTooltip : ''"
    class="gl-inline-flex"
    :class="{ '!gl-pointer-events-auto': disabled }"
  >
    <gl-button-group>
      <gl-button
        v-for="option in $options.ACCESS_OPTIONS"
        :key="option.value"
        v-gl-tooltip="option.label"
        :data-testid="`access-option-${option.value.toLowerCase()}`"
        :aria-label="option.label"
        size="small"
        category="secondary"
        icon
        :selected="value === option.value"
        :loading="isLoading && value === option.value"
        :disabled="disabled || isLoading"
        @click="handleSelect(option.value, $event)"
      >
        <gl-icon
          :name="option.icon"
          :class="value === option.value ? option.selectedIconClass : null"
        />
      </gl-button>
    </gl-button-group>
  </span>
</template>
