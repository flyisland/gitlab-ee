<script>
import { defineComponent } from 'vue';
import { GlBadge, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';

export default defineComponent({
  name: 'SchemaDetailPanel',
  compatConfig: { MODE: 3 },
  components: { GlBadge, GlButton },
  tableColumns: [
    { key: 'name', label: s__('Orbit|Name'), class: 'gl-flex-1' },
    { key: 'data_type', label: s__('Orbit|Type'), class: 'schema-detail-col-type' },
    { key: 'nullable', label: s__('Orbit|Nullable'), class: 'schema-detail-col-nullable' },
  ],
  props: {
    node: {
      type: Object,
      required: true,
    },
    properties: {
      type: Array,
      required: true,
    },
    description: {
      type: String,
      required: false,
      default: '',
    },
    domain: {
      type: String,
      required: false,
      default: '',
    },
    nodeColor: {
      type: String,
      required: true,
    },
  },
  emits: ['close'],
  methods: {
    cellValue(prop, key) {
      if (key === 'nullable') return prop.nullable ? s__('Orbit|Yes') : s__('Orbit|No');
      return prop[key];
    },
  },
});
</script>

<template>
  <div
    class="orbit-frosted-panel gl-z-20 gl-border-l gl-w-80 gl-shrink-0 gl-overflow-y-auto gl-rounded-lg gl-border-default"
    data-testid="schema-detail-panel"
  >
    <div class="gl-flex gl-items-center gl-justify-between gl-px-4 gl-py-3">
      <span class="gl-text-sm gl-font-bold">
        {{ s__('Orbit|Selected Entity') }}
      </span>
      <gl-button
        icon="close"
        :aria-label="s__('Orbit|Close')"
        size="small"
        category="tertiary"
        data-testid="close-detail-panel-btn"
        @click="$emit('close')"
      />
    </div>

    <div class="gl-px-4 gl-pb-4">
      <div class="gl-mb-2 gl-flex gl-items-center gl-gap-2">
        <gl-badge
          size="sm"
          class="gl-rounded-base gl-text-neutral-0"
          :style="{ background: nodeColor }"
        >
          {{ domain }}
        </gl-badge>
        <span class="gl-font-bold">
          {{ node.label }}
        </span>
      </div>

      <p v-if="description" class="gl-mb-3 gl-mt-0 gl-text-sm gl-text-subtle">
        {{ description }}
      </p>

      <p v-if="properties.length" class="gl-mb-2 gl-mt-0 gl-text-sm gl-font-bold">
        {{ s__('Orbit|Properties') }}:
      </p>

      <div v-if="properties.length" class="schema-detail-header gl-flex gl-py-1">
        <span
          v-for="col in $options.tableColumns"
          :key="col.key"
          :class="col.class"
          class="gl-text-xs gl-font-bold gl-text-subtle"
        >
          {{ col.label }}
        </span>
      </div>

      <div
        v-for="prop in properties"
        :key="prop.name"
        class="schema-detail-row gl-flex gl-items-center gl-py-1"
      >
        <span
          v-for="col in $options.tableColumns"
          :key="col.key"
          :class="[col.class, col.key === 'name' ? '' : 'gl-text-subtle']"
          class="gl-text-xs"
        >
          {{ cellValue(prop, col.key) }}
        </span>
      </div>
    </div>
  </div>
</template>
