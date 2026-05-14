<script>
import { defineComponent } from 'vue';
import { s__ } from '~/locale';
import { ENTITY_TYPE_COLORS, ENTITY_TYPE_NAMES } from '../constants';

export default defineComponent({
  name: 'NodeDetailOverlay',
  compatConfig: { MODE: 3 },
  props: {
    node: {
      type: Object,
      required: false,
      default: null,
    },
    position: {
      type: Object,
      required: false,
      default: null,
    },
    entityColors: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    entityNames: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    overlayStyle() {
      return {
        left: `${this.position.x + 16}px`,
        top: `${this.position.y - 10}px`,
      };
    },
    typeColor() {
      const key = (this.node?.type || 'default').toLowerCase();
      return this.entityColors[key] || ENTITY_TYPE_COLORS[key];
    },
    typeLabel() {
      const key = (this.node?.type || '').toLowerCase();
      return this.entityNames[key] || ENTITY_TYPE_NAMES[key] || this.node?.type || '';
    },
    displayProperties() {
      const fields = [
        { key: s__('Orbit|Type'), value: this.node?.type },
        { key: s__('Orbit|FQN'), value: this.node?.fqn },
        { key: s__('Orbit|Location'), value: this.node?.location },
        {
          key: s__('Orbit|Connections'),
          value: this.node?.connections?.size ? String(this.node.connections.size) : null,
        },
      ];
      return fields.filter((field) => field.value);
    },
  },
});
</script>

<template>
  <div
    v-if="node && position"
    class="orbit-frosted-panel node-detail-overlay gl-z-10 gl-pointer-events-none gl-absolute gl-max-w-80 gl-rounded-lg gl-p-3"
    :style="overlayStyle"
    data-testid="node-detail-overlay"
  >
    <p class="gl-mb-1 gl-mt-0 gl-text-sm gl-font-bold" data-testid="overlay-node-label">
      {{ node.label || node.id }}
    </p>
    <p class="node-detail-type-label gl-mb-2 gl-mt-0" :style="{ color: typeColor }">
      {{ typeLabel }}
    </p>
    <div v-if="node.fqn" class="gl-mb-2 gl-break-all gl-text-xs">
      {{ node.fqn }}
    </div>
    <div v-for="prop in displayProperties" :key="prop.key" class="gl-flex gl-gap-2 gl-text-xs">
      <span class="gl-font-bold gl-text-subtle">{{ prop.key }}:</span>
      <span class="gl-font-mono">{{ prop.value }}</span>
    </div>
  </div>
</template>
