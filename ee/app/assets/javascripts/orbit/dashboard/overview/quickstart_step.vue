<script>
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'QuickstartStep',
  compatConfig: { MODE: 3 },
  props: {
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
  },
});
</script>

<template>
  <li class="gl-flex gl-min-w-0 gl-flex-col gl-gap-2">
    <h3 class="gl-heading-4 gl-m-0 gl-flex gl-items-baseline gl-gap-3">
      <span
        class="orbit-quickstart-step gl-inline-flex gl-h-6 gl-w-6 gl-shrink-0 gl-items-center gl-justify-center gl-rounded-full gl-text-sm gl-font-semibold"
        aria-hidden="true"
      ></span>
      {{ title }}
    </h3>
    <div class="gl-flex gl-flex-col gl-gap-3 gl-pl-8">
      <span class="gl-text-subtle" data-testid="quickstart-step-description">{{
        description
      }}</span>
      <slot></slot>
    </div>
  </li>
</template>
