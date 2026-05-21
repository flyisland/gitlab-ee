<script>
import { GlButton, GlIcon } from '@gitlab/ui';
import { ENFORCEMENT_MODES } from '../../constants';

export default {
  name: 'EnforcementModeSelector',
  components: { GlButton, GlIcon },
  props: {
    value: {
      type: String,
      required: false,
      default: 'enforce',
    },
  },
  emits: ['input'],
  data() {
    return {
      modes: ENFORCEMENT_MODES,
      localValue: this.value,
    };
  },
  watch: {
    value(v) {
      this.localValue = v;
    },
  },
  methods: {
    select(id) {
      this.localValue = id;
      this.$emit('input', id);
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-gap-4">
    <gl-button
      v-for="mode in modes"
      :key="mode.id"
      class="gl-flex-1 gl-cursor-pointer gl-rounded-base gl-bg-default gl-p-4 gl-text-left"
      :class="
        localValue === mode.id
          ? ['gl-border-2', 'gl-border-blue-500']
          : ['gl-border', 'gl-border-default']
      "
      @click="select(mode.id)"
    >
      <div class="gl-flex gl-items-center gl-gap-3">
        <gl-icon :name="mode.icon" class="gl-shrink-0" />
        <div class="gl-py-2">
          <p class="gl-mb-1 gl-font-bold">{{ mode.label }}</p>
          <p class="gl-mb-0 gl-text-sm gl-text-secondary">{{ mode.description }}</p>
        </div>
      </div>
    </gl-button>
  </div>
</template>
