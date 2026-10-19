<script>
import { GlTable, GlSkeletonLoader } from '@gitlab/ui';
import { glSlotsMixin } from '~/lib/utils/vue3compat/gl_slots_mixin';

const LOADER_ITEMS_COUNT = 3;

export default {
  name: 'BaseFeatureSettingsTable',
  components: {
    GlTable,
    GlSkeletonLoader,
  },
  mixins: [glSlotsMixin],
  props: {
    fields: {
      type: Array,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      // Position of each feature from the last sort, or null when unsorted. Rows keep this
      // position when a cell value changes, so an edited row does not jump elsewhere.
      sortRank: null,
    };
  },
  computed: {
    loaderItems() {
      // create placeholder items to render during loading
      return new Array(LOADER_ITEMS_COUNT).fill(true);
    },
    tableFields() {
      return this.fields.map((field) => ({
        ...field,
        // Rows are placeholders while loading, so there is nothing to sort yet.
        sortable: Boolean(field.sortable) && !this.isLoading,
        tdClass: 'gl-content-center !gl-border-b-0',
      }));
    },
    displayItems() {
      if (this.isLoading) return this.loaderItems;
      if (!this.sortRank) return this.items;

      return [...this.items].sort((a, b) => this.sortRank[a.feature] - this.sortRank[b.feature]);
    },
  },
  methods: {
    onSortChanged({ sortBy, sortDesc }) {
      const collator = new Intl.Collator(undefined, { numeric: true });
      const sortValue = (item) => String(item[sortBy] ?? '');

      // Negate rather than reverse, so rows with equal values keep their relative order.
      const direction = sortDesc ? -1 : 1;
      const sorted = [...this.items].sort(
        (a, b) => collator.compare(sortValue(a), sortValue(b)) * direction,
      );

      this.sortRank = Object.fromEntries(sorted.map(({ feature }, index) => [feature, index]));
    },
    showSlot(slot) {
      return slot.startsWith('head') || !this.isLoading;
    },
    showLoader(scope, slot) {
      // only display loaders non-header cells
      if (!slot.startsWith('cell')) return false;

      if (!scope.field.loaderWidths) return false;

      return this.isLoading;
    },
    getLoaderWidth(scope) {
      const { loaderWidths } = scope.field;

      return loaderWidths[scope.index % loaderWidths.length];
    },
  },
};
</script>
<template>
  <gl-table
    class="gl-border gl-mb-0 gl-rounded-lg gl-border-section gl-bg-section"
    tbody-tr-class="gl-bg-subtle"
    :fields="tableFields"
    :items="displayItems"
    primary-key="feature"
    responsive
    borderless
    no-local-sorting
    @sort-changed="onSortChanged"
  >
    <template v-for="slot in Object.keys(glSlots())" #[slot]="scope">
      <div v-if="showLoader(scope, slot)" :key="slot" :class="scope.field.loaderClass">
        <gl-skeleton-loader :height="38" :width="600">
          <rect y="8" x="0" :width="getLoaderWidth(scope)" height="24" rx="10" />
        </gl-skeleton-loader>
      </div>
      <slot v-if="showSlot(slot)" :name="slot" v-bind="scope"></slot>
    </template>
  </gl-table>
</template>
