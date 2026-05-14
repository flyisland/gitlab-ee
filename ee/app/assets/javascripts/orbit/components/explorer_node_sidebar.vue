<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import { ENTITY_TYPE_COLORS, ENTITY_TYPE_NAMES } from '../constants';

export default defineComponent({
  name: 'ExplorerNodeSidebar',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
  },
  props: {
    node: {
      type: Object,
      required: true,
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
  emits: ['close'],
  computed: {
    nodeTypeColor() {
      const key = this.node.type?.toLowerCase() || 'default';
      return this.entityColors[key] || ENTITY_TYPE_COLORS[key];
    },
    sidebarProperties() {
      return Object.fromEntries(
        Object.entries(this.node?.properties || {})
          .filter(([, v]) => v !== null && v !== undefined && v !== '')
          .map(([k, v]) => [k.replace(/_/g, ' '), v]),
      );
    },
    displayLabel() {
      return this.node.label || this.node.id;
    },
    resolvedType() {
      const key = (this.node.type || '').toLowerCase();
      return this.entityNames[key] || ENTITY_TYPE_NAMES[key] || key;
    },
  },
});
</script>

<template>
  <div
    class="orbit-frosted-panel gl-z-20 gl-w-72 gl-absolute gl-right-3 gl-top-3 gl-overflow-y-auto gl-rounded-lg"
    style="max-height: 320px"
    data-testid="explorer-node-sidebar"
  >
    <div class="gl-flex gl-items-center gl-justify-between gl-px-3 gl-py-2">
      <span class="gl-text-sm gl-font-bold" data-testid="sidebar-node-label">{{
        displayLabel
      }}</span>
      <gl-button
        icon="close"
        :aria-label="s__('Orbit|Close')"
        size="small"
        category="tertiary"
        data-testid="close-sidebar-btn"
        @click="$emit('close')"
      />
    </div>
    <div class="gl-px-3 gl-pb-3">
      <div
        class="gl-mb-2 gl-inline-flex gl-rounded-base gl-px-2 gl-py-1 gl-text-xs gl-font-bold gl-text-neutral-0"
        data-testid="sidebar-node-type"
        :style="{ background: nodeTypeColor }"
      >
        {{ resolvedType }}
      </div>
      <div
        v-for="(value, key) in sidebarProperties"
        :key="key"
        class="gl-mb-1 gl-flex gl-gap-2 gl-text-xs"
      >
        <span class="gl-min-w-20 gl-font-bold gl-text-subtle">{{ key }}</span>
        <span class="gl-break-all">{{ value }}</span>
      </div>
    </div>
  </div>
</template>
