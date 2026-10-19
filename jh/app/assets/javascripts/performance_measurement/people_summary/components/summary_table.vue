<script>
import { GlTable, GlAvatarLabeled, GlLoadingIcon, GlPagination } from '@gitlab/ui';
import { TABLE_COLUMNS } from '../constants';
import { fetchTableData } from '../api';

export default {
  components: {
    GlTable,
    GlLoadingIcon,
    GlPagination,
    GlAvatarLabeled,
  },
  data() {
    return {
      loading: false,
      items: [],
      sortBy: 'active_points',
      sortDesc: true,
      sortDirection: 'desc',
      currentPage: 1,
      totalItems: 0,
    };
  },
  computed: {
    params() {
      const { sortBy, sortDesc, currentPage } = this;

      return {
        sort: sortBy,
        sortDesc,
        page: currentPage,
      };
    },
  },
  watch: {
    params: {
      handler(val) {
        this.loadData(val);
      },
      immediate: true,
    },
  },
  methods: {
    async loadData(params) {
      this.loading = true;
      try {
        const data = await fetchTableData(params);
        this.items = data;
      } finally {
        this.loading = false;
      }
    },
    onSortChange({ sortBy, sortDesc }) {
      this.sortBy = sortBy;
      this.sortDesc = sortDesc;
    },
    onPageChange(page) {
      this.currentPage = page;
    },
  },
  TABLE_COLUMNS,
};
</script>

<template>
  <gl-loading-icon v-if="loading" />
  <div v-else>
    <p class="gl-mb-6 gl-mt-7 gl-text-size-h2 gl-font-bold">
      {{ s__('JH|PerformanceMeasurement|Individual data') }}
    </p>
    <gl-table
      :fields="$options.TABLE_COLUMNS"
      :items="items"
      :sort-by.sync="sortBy"
      :sort-desc.sync="sortDesc"
      :sort-direction="sortDirection"
      no-local-sorting
      @sort-changed="onSortChange"
    >
      <template #cell(gitlab_user)="{ value }">
        <gl-avatar-labeled
          :size="32"
          :entity-name="value.name"
          :label="value.name"
          :sub-label="`@${value.username}`"
          class="gl-flex gl-items-center"
          shape="circle"
        />
      </template>
    </gl-table>
    <gl-pagination
      class="gl-mt-3"
      :value="currentPage"
      :per-page="10"
      :total-items="totalItems"
      :prev-page="null"
      :next-page="null"
      align="center"
      @input="onPageChange"
    />
  </div>
</template>
