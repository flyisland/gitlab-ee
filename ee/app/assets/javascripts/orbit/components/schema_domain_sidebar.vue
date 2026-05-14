<script>
import { defineComponent } from 'vue';
import { GlIcon } from '@gitlab/ui';

export default defineComponent({
  name: 'SchemaDomainSidebar',
  compatConfig: { MODE: 3 },
  components: { GlIcon },
  props: {
    domains: {
      type: Array,
      required: true,
    },
    selectedDomain: {
      type: String,
      required: false,
      default: null,
    },
    totalNodeCount: {
      type: Number,
      required: true,
    },
    expandedDomains: {
      type: Object,
      required: true,
    },
    domainColorMap: {
      type: Object,
      required: true,
    },
  },
  emits: ['select-domain', 'toggle-expand', 'select-node'],
  methods: {
    domainNodeNames(domainName) {
      const domain = this.domains.find((d) => d.name === domainName);
      return domain?.node_names || [];
    },
    isDomainExpanded(domainName) {
      return Boolean(this.expandedDomains[domainName]);
    },
  },
});
</script>

<template>
  <div
    class="schema-domain-sidebar gl-flex-shrink-0 gl-overflow-y-auto gl-bg-strong gl-py-4"
    data-testid="schema-domain-sidebar"
  >
    <p class="gl-heading-5 gl-mb-3 gl-mt-0 gl-px-4">
      {{ s__('Orbit|Domains') }}
    </p>

    <button
      type="button"
      class="schema-domain-item gl-flex gl-w-full gl-cursor-pointer gl-items-center gl-gap-2 gl-border-0 gl-px-4 gl-py-2 gl-text-left gl-text-sm"
      :class="{ 'schema-domain-item--active': !selectedDomain }"
      data-testid="all-domains-button"
      @click="$emit('select-domain', null)"
    >
      <span class="gl-font-bold">{{ s__('Orbit|All domains') }}</span>
      <span class="gl-text-subtle">({{ totalNodeCount }})</span>
    </button>

    <div v-for="domain in domains" :key="domain.name">
      <button
        type="button"
        class="schema-domain-item gl-flex gl-w-full gl-cursor-pointer gl-items-center gl-gap-1 gl-border-0 gl-py-2 gl-pl-6 gl-pr-4 gl-text-left gl-text-sm"
        :class="{ 'schema-domain-item--active': selectedDomain === domain.name }"
        :data-testid="`domain-button-${domain.name}`"
        @click="$emit('select-domain', domain.name)"
      >
        <gl-icon
          :name="isDomainExpanded(domain.name) ? 'chevron-down' : 'chevron-right'"
          :size="12"
          class="gl-flex-shrink-0 gl-text-subtle"
          @click.stop="$emit('toggle-expand', domain.name)"
        />
        <span
          v-if="domainColorMap[domain.name]"
          class="gl-inline-block gl-h-3 gl-w-3 gl-flex-shrink-0 gl-rounded-full"
          :style="{ background: domainColorMap[domain.name] }"
        ></span>
        <span>{{ domain.name }}</span>
        <span class="gl-text-subtle">({{ domain.count }})</span>
      </button>

      <div v-if="isDomainExpanded(domain.name)">
        <button
          v-for="nodeName in domainNodeNames(domain.name)"
          :key="nodeName"
          type="button"
          class="schema-domain-item gl-flex gl-w-full gl-cursor-pointer gl-border-0 gl-py-1 gl-pl-8 gl-text-left gl-text-sm gl-text-subtle"
          @click="$emit('select-node', nodeName)"
        >
          {{ nodeName }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.schema-domain-sidebar {
  width: 200px;
  border-right: 1px solid var(--gl-border-color-default);
}

.schema-domain-item {
  color: inherit;
  background: transparent;
}

.schema-domain-item:hover,
.schema-domain-item--active {
  background: var(--gl-background-color-subtle);
}
</style>
