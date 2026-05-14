<script>
import { defineComponent } from 'vue';
import { GlButton, GlButtonGroup, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DOCS_URL } from '~/constants';
import { TAB_GRAPH, TAB_TABLE } from '../constants';

const docsPath = `${DOCS_URL}/orbit/`;

export default defineComponent({
  name: 'ExplorerTabBar',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlButtonGroup,
    GlIcon,
  },
  TAB_GRAPH,
  TAB_TABLE,
  resourceLinks: [
    { text: s__('Orbit|CLI'), href: `${DOCS_URL}/orbit/cli/` },
    { text: s__('Orbit|REST API'), href: `${DOCS_URL}/api/orbit/` },
    { text: s__('Orbit|MCP'), href: `${DOCS_URL}/orbit/mcp/` },
    { text: s__('Orbit|Docs'), href: docsPath },
  ],
  props: {
    activeTab: {
      type: String,
      required: true,
    },
    showResourceLinks: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['update:active-tab'],
});
</script>

<template>
  <div
    class="gl-flex gl-items-center gl-gap-3 gl-bg-strong gl-px-4 gl-py-3"
    data-testid="explorer-tab-bar"
  >
    <gl-button-group>
      <gl-button
        :selected="activeTab === $options.TAB_GRAPH"
        size="small"
        data-testid="tab-graph"
        @click="$emit('update:active-tab', $options.TAB_GRAPH)"
      >
        <gl-icon name="search-results" :size="14" class="gl-mr-1" />
        {{ s__('Orbit|Node Explorer') }}
      </gl-button>
      <gl-button
        :selected="activeTab === $options.TAB_TABLE"
        size="small"
        data-testid="tab-table"
        @click="$emit('update:active-tab', $options.TAB_TABLE)"
      >
        <gl-icon name="table" :size="14" class="gl-mr-1" />
        {{ s__('Orbit|Table') }}
      </gl-button>
    </gl-button-group>

    <div class="gl-flex-1"></div>

    <template v-if="showResourceLinks">
      <span class="gl-text-sm gl-text-subtle" data-testid="resource-links-label">{{
        s__('Orbit|Resources')
      }}</span>
      <gl-button-group>
        <gl-button
          v-for="link in $options.resourceLinks"
          :key="link.text"
          size="small"
          :href="link.href"
        >
          {{ link.text }}
        </gl-button>
      </gl-button-group>
    </template>
  </div>
</template>
