<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import { schemaNodeValidator } from '../api/schema_types';

export default defineComponent({
  name: 'SchemaNodeCard',
  compatConfig: { MODE: 3 },
  components: { GlButton },
  props: {
    node: {
      type: Object,
      required: true,
      validator: schemaNodeValidator,
    },
    collapsed: {
      type: Boolean,
      required: true,
    },
    nodeColor: {
      type: String,
      required: false,
      default: null,
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
    propertyCount() {
      return (this.node.properties || []).length;
    },
  },
});
</script>

<template>
  <div
    class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default"
    data-testid="schema-node-card"
  >
    <div
      class="gl-flex gl-cursor-pointer gl-items-center gl-justify-between gl-bg-strong gl-px-4 gl-py-3"
      @click="$emit('toggle-collapse', node.name)"
    >
      <div class="gl-flex gl-items-center gl-gap-2">
        <span
          v-if="nodeColor"
          class="gl-inline-block gl-h-3 gl-w-3 gl-flex-shrink-0 gl-rounded-full"
          :style="{ background: nodeColor }"
        ></span>
        <span class="gl-font-bold">{{ node.name }}</span>
        <span class="gl-text-subtle">·</span>
        <span class="gl-text-sm gl-text-subtle">{{ node.domain }}</span>
      </div>
      <gl-button
        :icon="collapseIcon"
        :aria-label="collapseLabel"
        size="small"
        category="tertiary"
        @click.stop="$emit('toggle-collapse', node.name)"
      />
    </div>

    <div v-if="!collapsed" class="gl-px-4 gl-py-3">
      <p v-if="node.description" class="gl-mb-3 gl-mt-0 gl-text-sm gl-text-subtle">
        {{ node.description }}
      </p>

      <p class="gl-mb-2 gl-mt-0 gl-text-sm gl-font-bold">
        {{ s__('Orbit|Properties') }} ({{ propertyCount }})
      </p>

      <div
        v-for="prop in node.properties || []"
        :key="prop.name"
        class="schema-prop-row gl-flex gl-items-center gl-py-2"
      >
        <span class="gl-flex-1 gl-text-sm">{{ prop.name }}</span>
        <span class="gl-text-sm gl-text-subtle">{{ prop.data_type }}</span>
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
