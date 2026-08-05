<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';

export default {
  name: 'AvailableModelsRow',
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['click'],
};
</script>
<template>
  <span
    v-gl-tooltip="{
      title: s__(
        'AdminAIPoweredFeatures|Available models can only be configured when using a GitLab managed model.',
      ),
      disabled: !disabled,
      placement: 'right',
    }"
    data-testid="disabled-tooltip"
  >
    <gl-button
      data-testid="configure-button"
      :disabled="disabled"
      :loading="isLoading"
      @click="$emit('click')"
    >
      {{ __('Configure') }}
    </gl-button>
  </span>
</template>
