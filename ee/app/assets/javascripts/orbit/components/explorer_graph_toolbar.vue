<script>
import { defineComponent } from 'vue';
import { GlButton, GlCollapsibleListbox, GlSearchBoxByType } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DIMENSION_OPTIONS } from '../constants';

export default defineComponent({
  name: 'ExplorerGraphToolbar',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlCollapsibleListbox,
    GlSearchBoxByType,
  },
  dimensionItems: DIMENSION_OPTIONS,
  props: {
    searchQuery: {
      type: String,
      required: true,
    },
    dimensionMode: {
      type: String,
      required: true,
    },
    expanded: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['update-search-query', 'select-dimension', 'toggle-expand'],
  computed: {
    expandIcon() {
      return this.expanded ? 'minimize' : 'maximize';
    },
    expandLabel() {
      return this.expanded ? s__('Orbit|Minimize') : s__('Orbit|Maximize');
    },
    dimensionToggleText() {
      return this.dimensionMode.toUpperCase();
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-items-center gl-gap-2 gl-p-3" data-testid="explorer-graph-toolbar">
    <gl-search-box-by-type
      :value="searchQuery"
      :placeholder="s__('Orbit|Filter entities...')"
      class="gl-max-w-26"
      data-testid="graph-search-input"
      @input="$emit('update-search-query', $event)"
    />
    <div class="gl-flex-1"></div>
    <gl-button
      size="small"
      :icon="expandIcon"
      :aria-label="expandLabel"
      category="tertiary"
      data-testid="graph-expand-btn"
      @click="$emit('toggle-expand')"
    />
    <gl-collapsible-listbox
      :items="$options.dimensionItems"
      :selected="dimensionMode"
      :toggle-text="dimensionToggleText"
      size="small"
      data-testid="dimension-select"
      @select="$emit('select-dimension', $event)"
    />
  </div>
</template>
