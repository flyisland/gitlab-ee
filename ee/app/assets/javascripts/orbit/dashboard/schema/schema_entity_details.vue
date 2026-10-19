<script>
import { defineComponent } from 'vue';
import { GlBadge, GlButton, GlTab, GlTableLite, GlTabs, GlTruncate } from '@gitlab/ui';
import { formatNumber, n__, s__, sprintf } from '~/locale';
import { groupByEntity } from './schema_graph';
import SchemaEntityIcon from './schema_entity_icon.vue';

function propertyValues({ enum_values: enumValues, nullable }) {
  if (enumValues?.length) return enumValues.join(', ');
  if (nullable) return s__('Orbit|Can be empty');
  return '';
}

export default defineComponent({
  name: 'SchemaEntityDetails',
  compatConfig: { MODE: 3 },
  components: { GlBadge, GlButton, GlTab, GlTableLite, GlTabs, GlTruncate, SchemaEntityIcon },
  props: {
    entity: {
      type: Object,
      required: true,
    },
    node: {
      type: Object,
      required: true,
    },
    relationships: {
      type: Object,
      required: true,
    },
    itemCount: {
      type: Number,
      required: false,
      default: null,
    },
  },
  emits: ['select', 'close', 'show-instances'],
  propertyFields: [
    { key: 'name', label: s__('Orbit|Property'), thClass: 'gl-w-1/3' },
    { key: 'type', label: s__('Orbit|Type'), thClass: 'gl-w-1/5' },
    { key: 'values', label: s__('Orbit|Values') },
  ],
  computed: {
    relationshipCount() {
      return this.relationships.outgoing.length + this.relationships.incoming.length;
    },
    relationshipCountSrText() {
      return n__('Orbit|%d relationship', 'Orbit|%d relationships', this.relationshipCount);
    },
    incomingByEntity() {
      return groupByEntity(this.relationships.incoming);
    },
    properties() {
      return (this.node.properties || []).map((property) => ({
        name: property.name,
        type: property.data_type,
        values: propertyValues(property),
      }));
    },
    propertyCountSrText() {
      return n__('Orbit|%d property', 'Orbit|%d properties', this.properties.length);
    },
    itemCountText() {
      return sprintf(s__('Orbit|%{count} in your graph'), {
        count: formatNumber(this.itemCount),
      });
    },
  },
});
</script>

<template>
  <aside
    :aria-label="s__('Orbit|Entity details')"
    class="gl-border gl-flex gl-flex-col gl-gap-4 gl-rounded-lg gl-border-default gl-p-5"
    data-testid="schema-entity-details"
  >
    <div class="gl-flex gl-items-start gl-gap-3">
      <schema-entity-icon :icon="entity.icon" :color="entity.color" size="md" />
      <div class="gl-min-w-0 gl-grow">
        <h2 class="gl-heading-4 gl-mb-1 gl-break-words">{{ entity.name }}</h2>
        <p v-if="node.description" class="gl-mb-0 gl-text-subtle">{{ node.description }}</p>
      </div>
      <gl-button
        category="tertiary"
        icon="close"
        size="small"
        :aria-label="s__('Orbit|Close details')"
        data-testid="schema-details-close"
        @click="$emit('close')"
      />
    </div>

    <p v-if="itemCount !== null" class="gl-mb-0 gl-text-sm gl-text-subtle">
      {{ itemCountText }}
    </p>

    <div v-if="itemCount !== 0">
      <gl-button
        icon="earth"
        data-testid="schema-explore"
        @click="$emit('show-instances', { entityType: entity.name })"
      >
        {{ s__('Orbit|Explore') }}
      </gl-button>
    </div>

    <gl-tabs>
      <gl-tab
        :title="s__('Orbit|Relationships')"
        :tab-count="relationshipCount"
        :tab-count-sr-text="relationshipCountSrText"
      >
        <div class="gl-flex gl-flex-col gl-gap-4 gl-pt-3">
          <div v-if="relationships.outgoing.length" data-testid="schema-outgoing">
            <h3 class="gl-heading-6 gl-mb-2 gl-text-subtle">
              {{ sprintf(s__('Orbit|From %{entity}'), { entity: entity.name }) }}
            </h3>
            <ul class="gl-m-0 gl-list-none gl-p-0">
              <li
                v-for="relationship in relationships.outgoing"
                :key="`${relationship.edge}-${relationship.entity}`"
                class="gl-border-t gl-flex gl-items-baseline gl-gap-3 gl-border-default gl-py-2"
              >
                <code class="gl-shrink-0 gl-bg-transparent gl-p-0 gl-text-sm">{{
                  relationship.edge
                }}</code>
                <span class="gl-text-subtle" aria-hidden="true">&rarr;</span>
                <gl-button
                  variant="link"
                  class="gl-shrink-0"
                  @click="$emit('select', relationship.entity)"
                >
                  <span class="gl-font-bold">{{ relationship.entity }}</span>
                </gl-button>
                <gl-truncate
                  v-if="relationship.description"
                  :text="relationship.description"
                  with-tooltip
                  class="gl-min-w-0 gl-text-sm gl-text-subtle"
                />
              </li>
            </ul>
          </div>

          <div v-if="incomingByEntity.length" data-testid="schema-incoming">
            <h3 class="gl-heading-6 gl-mb-2 gl-text-subtle">
              {{ sprintf(s__('Orbit|To %{entity}'), { entity: entity.name }) }}
            </h3>
            <ul class="gl-m-0 gl-list-none gl-p-0">
              <li
                v-for="group in incomingByEntity"
                :key="group.entity"
                class="gl-border-t gl-flex gl-flex-col gl-items-start gl-gap-2 gl-border-default gl-py-2"
              >
                <gl-button variant="link" @click="$emit('select', group.entity)">
                  <span class="gl-font-bold">{{ group.entity }}</span>
                </gl-button>
                <ul class="gl-m-0 gl-flex gl-w-full gl-list-none gl-flex-col gl-gap-1 gl-p-0">
                  <li
                    v-for="edge in group.edges"
                    :key="edge.name"
                    class="gl-flex gl-min-w-0 gl-items-baseline gl-gap-3"
                  >
                    <code class="gl-shrink-0 gl-bg-transparent gl-p-0 gl-text-sm">{{
                      edge.name
                    }}</code>
                    <gl-truncate
                      v-if="edge.description"
                      :text="edge.description"
                      with-tooltip
                      class="gl-min-w-0 gl-text-sm gl-text-subtle"
                    />
                  </li>
                </ul>
              </li>
            </ul>
          </div>
        </div>
      </gl-tab>

      <gl-tab
        :title="s__('Orbit|Properties')"
        :tab-count="properties.length"
        :tab-count-sr-text="propertyCountSrText"
      >
        <gl-table-lite
          :fields="$options.propertyFields"
          :items="properties"
          fixed
          class="gl-mt-3"
          data-testid="schema-properties"
        >
          <template #cell(name)="{ item }">
            <code class="gl-break-words gl-bg-transparent gl-p-0 gl-text-sm">{{ item.name }}</code>
          </template>
          <template #cell(type)="{ item }">
            <gl-badge variant="neutral">{{ item.type }}</gl-badge>
          </template>
          <template #cell(values)="{ item }">
            <span class="gl-break-words gl-text-sm gl-text-subtle">{{ item.values }}</span>
          </template>
        </gl-table-lite>
      </gl-tab>
    </gl-tabs>
  </aside>
</template>
