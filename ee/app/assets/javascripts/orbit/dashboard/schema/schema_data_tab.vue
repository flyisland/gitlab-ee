<script>
import { defineComponent } from 'vue';
import { GlButton } from '@gitlab/ui';
import { InternalEvents } from '~/tracking';
import { entityNeighbors, entityRelationships, itemCount, schemaDomains } from './schema_graph';
import SchemaDomainMap from './schema_domain_map.vue';
import SchemaEntityDetails from './schema_entity_details.vue';
import SchemaEntityGraph from './schema_entity_graph.vue';
import SchemaEntityPicker from './schema_entity_picker.vue';

export default defineComponent({
  name: 'SchemaDataTab',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    SchemaDomainMap,
    SchemaEntityDetails,
    SchemaEntityGraph,
    SchemaEntityPicker,
  },
  mixins: [InternalEvents.mixin()],
  props: {
    schema: {
      type: Object,
      required: true,
    },
    graphStats: {
      type: Object,
      required: false,
      default: null,
    },
    initialEntity: {
      type: String,
      required: false,
      default: null,
    },
  },
  emits: ['show-instances'],
  data() {
    return {
      selectedEntity: null,
    };
  },
  computed: {
    domains() {
      return schemaDomains(this.schema);
    },
    selectedNode() {
      return this.schema.nodes.find((node) => node.name === this.selectedEntity) || null;
    },
    selectedDomain() {
      return this.domains.find((domain) => domain.key === this.selectedNode?.domain) || null;
    },
    selectedEntitySummary() {
      return (
        this.domains
          .flatMap((domain) => domain.entities)
          .find((entity) => entity.name === this.selectedEntity) || null
      );
    },
    relationships() {
      return entityRelationships(this.schema, this.selectedEntity);
    },
    neighbors() {
      return entityNeighbors({
        domains: this.domains,
        relationships: this.relationships,
        name: this.selectedEntity,
      });
    },
    selectedItemCount() {
      return itemCount(this.graphStats, this.selectedEntity);
    },
  },
  watch: {
    initialEntity: 'selectInitialEntity',
  },
  mounted() {
    this.selectInitialEntity();
  },
  methods: {
    selectEntity(name, label) {
      if (name === this.selectedEntity) return;

      this.trackEvent('click_orbit_schema_item', { label });
      this.selectedEntity = name;
    },
    navigateTo(name, label) {
      if (name === this.selectedEntity) return;

      this.selectEntity(name, label);
      this.focusAfterRender('selectedEntityName');
    },
    clearSelection() {
      this.selectedEntity = null;
      this.focusAfterRender('mapView');
    },
    async focusAfterRender(ref) {
      await this.$nextTick();
      this.$refs[ref].focus();
    },
    selectInitialEntity() {
      const wanted = this.initialEntity?.toLowerCase();
      const node = wanted && this.schema.nodes.find((n) => n.name.toLowerCase() === wanted);
      if (node) this.selectedEntity = node.name;
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-min-h-0 gl-flex-1 gl-flex-col" data-testid="schema-data-tab">
    <h2 class="gl-heading-4 gl-mb-1">{{ s__('Orbit|How your data connects') }}</h2>
    <p class="gl-mb-4 gl-text-subtle">
      {{
        s__(
          'Orbit|Everything in Orbit belongs to a project. Select an entity to see how it connects.',
        )
      }}
    </p>

    <div class="gl-mb-3 gl-flex gl-flex-wrap gl-items-center gl-gap-3">
      <schema-entity-picker
        :domains="domains"
        :selected-entity="selectedEntity"
        :item-counts="graphStats"
        @select="selectEntity($event, 'picker')"
      />
      <div v-if="selectedNode" class="gl-flex gl-flex-wrap gl-items-center gl-gap-2 gl-text-sm">
        <gl-button variant="link" data-testid="schema-breadcrumb-root" @click="clearSelection">
          {{ s__('Orbit|Schema') }}
        </gl-button>
        <span class="gl-text-subtle" aria-hidden="true">/</span>
        <span class="gl-text-subtle">{{ selectedDomain.label }}</span>
        <span class="gl-text-subtle" aria-hidden="true">/</span>
        <span
          ref="selectedEntityName"
          tabindex="-1"
          class="gl-font-bold"
          data-testid="schema-breadcrumb-current"
        >
          {{ selectedEntity }}
        </span>
      </div>
    </div>

    <div v-if="!selectedNode" ref="mapView" tabindex="-1" data-testid="schema-map-view">
      <schema-domain-map :domains="domains" @select="navigateTo($event, 'map')" />
    </div>

    <div v-else class="gl-flex gl-flex-col gl-gap-5 @lg/panel:gl-flex-row @lg/panel:gl-items-start">
      <schema-entity-graph
        class="gl-min-w-0 gl-grow"
        :entity="selectedEntitySummary"
        :neighbors="neighbors"
        @select="navigateTo($event, 'neighbor')"
      />
      <schema-entity-details
        class="@lg/panel:gl-w-48 @lg/panel:gl-shrink-0"
        :entity="selectedEntitySummary"
        :node="selectedNode"
        :relationships="relationships"
        :item-count="selectedItemCount"
        @select="navigateTo($event, 'details')"
        @close="clearSelection"
        @show-instances="$emit('show-instances', $event)"
      />
    </div>
  </div>
</template>
