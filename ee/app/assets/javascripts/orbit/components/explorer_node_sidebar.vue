<script>
import { defineComponent } from 'vue';
import { GlButton, GlIcon } from '@gitlab/ui';
import { n__, s__, sprintf } from '~/locale';
import { ENTITY_TYPE_COLORS, ENTITY_TYPE_ICONS, ENTITY_TYPE_NAMES } from '../constants';

const EXPLORE_SUGGESTIONS = {
  group: [
    s__('Orbit|Who are the most active members?'),
    s__('Orbit|What projects are in this group?'),
  ],
  project: [
    s__('Orbit|Show recent merge requests'),
    s__('Orbit|Who are the top contributors?'),
    s__('Orbit|Check pipeline health'),
  ],
  user: [s__('Orbit|What did this user author?'), s__('Orbit|Which groups are they in?')],
  mergerequest: [s__('Orbit|Who reviewed this?'), s__('Orbit|What issues does this close?')],
  workitem: [s__('Orbit|Who is assigned?'), s__('Orbit|What MRs reference this?')],
  pipeline: [s__('Orbit|Who triggered this pipeline?'), s__('Orbit|Which MR is this for?')],
  vulnerability: [s__('Orbit|Which project is affected?'), s__('Orbit|What MR fixes this?')],
};

export default defineComponent({
  name: 'ExplorerNodeSidebar',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlIcon,
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
    typeKey() {
      return (this.node.type || '').toLowerCase();
    },
    typeIcon() {
      return ENTITY_TYPE_ICONS[this.typeKey] || null;
    },
    schemaRoute() {
      return { name: 'schema', query: { entity: this.resolvedType } };
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
    connectionCount() {
      return this.node.connections?.size || 0;
    },
    suggestions() {
      return EXPLORE_SUGGESTIONS[this.typeKey] || [];
    },
    connectionsLabel() {
      return sprintf(
        n__('Orbit|%{count} connection', 'Orbit|%{count} connections', this.connectionCount),
        { count: this.connectionCount },
      );
    },
  },
});
</script>

<template>
  <div
    class="orbit-frosted-panel explorer-node-sidebar gl-z-20 gl-w-72 gl-absolute gl-right-3 gl-top-3 gl-overflow-y-auto gl-rounded-lg"
    data-testid="explorer-node-sidebar"
  >
    <div class="gl-flex gl-items-center gl-justify-between gl-px-3 gl-py-2">
      <span class="gl-text-sm gl-font-bold" data-testid="sidebar-node-label">
        {{ displayLabel }}
      </span>
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
      <!-- Type button (links to schema) -->
      <div class="gl-mb-2 gl-flex gl-items-center gl-gap-2">
        <router-link
          :to="schemaRoute"
          class="gl-flex gl-cursor-pointer gl-items-center gl-gap-2 gl-rounded-base gl-border-1 gl-border-solid gl-border-default gl-bg-default gl-px-2 gl-py-1 gl-text-sm gl-text-default hover:gl-bg-strong"
          data-testid="sidebar-node-type"
        >
          <gl-icon v-if="typeIcon" :name="typeIcon" :size="12" :style="{ color: nodeTypeColor }" />
          <span
            v-else
            class="gl-inline-block gl-h-2 gl-w-2 gl-flex-shrink-0 gl-rounded-full"
            :style="{ backgroundColor: nodeTypeColor }"
          ></span>
          {{ resolvedType }}
        </router-link>
        <span v-if="connectionCount" class="gl-text-xs gl-text-subtle">
          {{ connectionsLabel }}
        </span>
      </div>

      <!-- Properties -->
      <div
        v-for="(value, key) in sidebarProperties"
        :key="key"
        class="gl-mb-1 gl-flex gl-gap-2 gl-text-xs"
      >
        <span class="gl-min-w-20 gl-font-bold gl-text-subtle">{{ key }}</span>
        <span class="gl-break-all">{{ value }}</span>
      </div>

      <!-- Explore suggestions -->
      <div v-if="suggestions.length" class="gl-border-t gl-mt-3 gl-border-default gl-pt-2">
        <p
          class="gl-mb-2 gl-mt-0 gl-flex gl-items-center gl-gap-1 gl-text-xs gl-font-bold gl-text-subtle"
        >
          <gl-icon name="bulb" :size="12" aria-hidden="true" />
          {{ s__('Orbit|Try asking an agent') }}
        </p>
        <div class="gl-flex gl-flex-col gl-gap-1">
          <span
            v-for="suggestion in suggestions"
            :key="suggestion"
            class="gl-text-xs gl-italic gl-text-subtle"
          >
            "{{ suggestion }}"
          </span>
        </div>
      </div>
    </div>
  </div>
</template>
