<script>
import { defineComponent } from 'vue';
import { GlCollapsibleListbox } from '@gitlab/ui';
import { s__ } from '~/locale';
import { filterDomains, formatItemCount } from './schema_graph';
import SchemaEntityIcon from './schema_entity_icon.vue';

export default defineComponent({
  name: 'SchemaEntityPicker',
  compatConfig: { MODE: 3 },
  components: { GlCollapsibleListbox, SchemaEntityIcon },
  props: {
    domains: {
      type: Array,
      required: true,
    },
    selectedEntity: {
      type: String,
      required: false,
      default: null,
    },
    itemCounts: {
      type: Object,
      required: false,
      default: null,
    },
  },
  emits: ['select'],
  data() {
    return {
      search: '',
    };
  },
  computed: {
    toggleText() {
      return this.selectedEntity || s__('Orbit|Select an entity');
    },
    items() {
      return filterDomains(this.domains, this.search).map((domain) => ({
        text: domain.label,
        options: domain.entities.map((entity) => ({
          value: entity.name,
          text: entity.name,
          icon: entity.icon,
          color: entity.color,
        })),
      }));
    },
  },
  methods: {
    itemCountText(name) {
      return formatItemCount(this.itemCounts, name);
    },
  },
});
</script>

<template>
  <gl-collapsible-listbox
    :items="items"
    :selected="selectedEntity"
    :toggle-text="toggleText"
    :header-text="s__('Orbit|Entities')"
    :search-placeholder="s__('Orbit|Search entities')"
    :no-results-text="s__('Orbit|No entities match your search.')"
    searchable
    data-testid="schema-entity-picker"
    @search="search = $event"
    @select="$emit('select', $event)"
  >
    <template #list-item="{ item }">
      <span class="gl-flex gl-items-center gl-gap-3">
        <schema-entity-icon :icon="item.icon" :color="item.color" />
        <span class="gl-min-w-0 gl-grow gl-truncate">{{ item.text }}</span>
        <span class="gl-text-sm gl-tabular-nums gl-text-subtle">{{
          itemCountText(item.value)
        }}</span>
      </span>
    </template>
  </gl-collapsible-listbox>
</template>
