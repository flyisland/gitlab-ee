<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { schemaEdgeValidator } from '../api/schema_types';
import { resolveNodeColor } from '../utils/schema_mappers';

export default defineComponent({
  name: 'SchemaEdgeCard',
  compatConfig: { MODE: 3 },
  components: { GlButton, GlIcon },
  props: {
    edge: {
      type: Object,
      required: true,
      validator: schemaEdgeValidator,
    },
    collapsed: {
      type: Boolean,
      required: true,
    },
    nodeStyleMap: {
      type: Object,
      required: true,
    },
    nodeDomainMap: {
      type: Object,
      required: true,
    },
    domainColorMap: {
      type: Object,
      required: true,
    },
  },
  emits: ['toggle-collapse'],
  computed: {
    collapseIcon() {
      return this.collapsed ? 'chevron-right' : 'chevron-down';
    },
    collapseLabel() {
      return this.collapsed ? s__('Orbit|Expand') : s__('Orbit|Collapse');
    },
    variantCount() {
      return (this.edge.variants || []).length;
    },
  },
  methods: {
    colorForNode(nodeName) {
      return resolveNodeColor(nodeName, {
        nodeStyleMap: this.nodeStyleMap,
        domainColorMap: this.domainColorMap,
        nodeDomainMap: this.nodeDomainMap,
      });
    },
    domainForNode(nodeName) {
      return this.nodeDomainMap[nodeName] ?? '';
    },
  },
});
</script>

<template>
  <div
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default"
    data-testid="schema-edge-card"
  >
    <div
      class="gl-flex gl-cursor-pointer gl-items-center gl-justify-between gl-bg-strong gl-px-4 gl-py-3"
      @click="$emit('toggle-collapse', edge.name)"
    >
      <span class="gl-font-bold">{{ edge.name }}</span>
      <gl-button
        :icon="collapseIcon"
        :aria-label="collapseLabel"
        size="small"
        category="tertiary"
        @click.stop="$emit('toggle-collapse', edge.name)"
      />
    </div>

    <div v-if="!collapsed" class="gl-px-4 gl-py-3">
      <p v-if="edge.description" class="gl-mb-3 gl-mt-0 gl-text-sm gl-text-subtle">
        {{ edge.description }}
      </p>

      <p class="gl-mb-2 gl-mt-0 gl-text-sm gl-font-bold">
        {{ s__('Orbit|Variants') }} ({{ variantCount }})
      </p>

      <div
        v-for="(variant, idx) in edge.variants || []"
        :key="idx"
        class="schema-prop-row gl-flex gl-items-center gl-gap-2 gl-py-2 gl-text-sm"
      >
        <span
          v-if="colorForNode(variant.source_type)"
          class="gl-inline-block gl-h-2 gl-w-2 gl-flex-shrink-0 gl-rounded-full"
          :style="{ background: colorForNode(variant.source_type) }"
        ></span>
        <span>{{ variant.source_type }}</span>
        <span class="gl-text-subtle">{{ domainForNode(variant.source_type) }}</span>
        <gl-icon name="arrow-right" :size="12" class="gl-text-subtle" />
        <span
          v-if="colorForNode(variant.target_type)"
          class="gl-inline-block gl-h-2 gl-w-2 gl-flex-shrink-0 gl-rounded-full"
          :style="{ background: colorForNode(variant.target_type) }"
        ></span>
        <span>{{ variant.target_type }}</span>
        <span class="gl-text-subtle">{{ domainForNode(variant.target_type) }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.schema-prop-row {
  border-bottom: 1px solid var(--gl-border-color-default);
}

.schema-prop-row:last-child {
  border-bottom: none;
}
</style>
