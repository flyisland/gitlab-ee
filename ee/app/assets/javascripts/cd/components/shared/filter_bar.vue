<script>
import { GlButton, GlButtonGroup, GlFormInput } from '@gitlab/ui';
import { debounce } from 'lodash-es';
import { s__ } from '~/locale';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';

export default {
  name: 'FilterBar',
  components: {
    GlButton,
    GlButtonGroup,
    GlFormInput,
  },
  props: {
    filters: {
      type: Array,
      required: true,
      // Array of { id: String, text: String }, e.g. { id: 'ALL', text: 'All' }
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
  <div class="gl-flex gl-gap-3">
    <gl-button-group>
      <gl-button
        v-for="filter in filters"
        :key="filter.id"
        :selected="filter.id === activeFilterId"
        :data-testid="`filter-button-${filter.id}`"
        @click="selectFilter(filter.id)"
      >
        {{ filter.text }}
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
