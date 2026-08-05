<script>
import { GlBadge, GlButton, GlButtonGroup, GlFormInput } from '@gitlab/ui';
import { debounce } from 'lodash-es';
import { s__ } from '~/locale';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';

export default {
  name: 'FilterBar',
  components: {
    GlBadge,
    GlButton,
    GlButtonGroup,
    GlFormInput,
  },
  props: {
    filters: {
      type: Array,
      required: true,
      // Array of { id: String, text: String, count: Number }, e.g. { id: 'ALL', text: 'All', count: 1 }
    },
    selectedFilterId: {
      type: String,
      required: false,
      default: null,
    },
    searchTerm: {
      type: String,
      required: false,
      default: '',
    },
    searchPlaceholder: {
      type: String,
      required: false,
      default: () => s__('ContinuousDeployment|Filter applications...'),
    },
  },
  emits: ['search', 'filter-selected'],
  data() {
    return {
      // Local copy so the input stays responsive while we debounce the emit.
      localSearchTerm: this.searchTerm,
    };
  },
  computed: {
    activeFilterId() {
      // Fall back to the first filter when the parent has not selected one.
      return this.selectedFilterId ?? this.filters[0]?.id ?? null;
    },
  },
  watch: {
    searchTerm(value) {
      this.localSearchTerm = value;
    },
  },
  created() {
    this.debouncedSearch = debounce((value) => {
      this.$emit('search', value);
    }, DEFAULT_DEBOUNCE_AND_THROTTLE_MS);
  },
  beforeDestroy() {
    this.debouncedSearch.cancel();
  },
  methods: {
    selectFilter(id) {
      if (id === this.activeFilterId) return;
      this.$emit('filter-selected', id);
    },
    onSearchInput(value) {
      this.localSearchTerm = value;
      this.debouncedSearch(value);
    },
  },
};
</script>

<template>
  <div class="gl-flex gl-flex-wrap gl-gap-3 @lg:gl-flex-nowrap">
    <gl-button-group class="gl-max-w-full">
      <gl-button
        v-for="filter in filters"
        :key="filter.id"
        :selected="filter.id === activeFilterId"
        :data-testid="`filter-button-${filter.id}`"
        @click="selectFilter(filter.id)"
      >
        {{ filter.text }}
        <gl-badge v-if="filter.count >= 0" class="gl-ml-2">{{ filter.count }}</gl-badge>
      </gl-button>
    </gl-button-group>
    <gl-form-input
      :value="localSearchTerm"
      :placeholder="searchPlaceholder"
      :aria-label="searchPlaceholder"
      data-testid="filter-search-input"
      @input="onSearchInput"
    />
  </div>
</template>
