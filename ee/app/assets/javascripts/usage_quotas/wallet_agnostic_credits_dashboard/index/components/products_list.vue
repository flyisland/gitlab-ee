<script>
import { GlKeysetPagination, GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';
import { formatNumber } from '../../../usage_billing/utils';

export default {
  name: 'ProductsList',
  components: {
    GlKeysetPagination,
    GlTable,
  },
  props: {
    products: {
      type: Object,
      required: true,
    },
    totalUsedCredits: {
      type: Number,
      required: true,
    },
  },
  emits: ['next-page', 'prev-page'],
  computed: {
    productNodes() {
      return this.products.nodes ?? [];
    },
  },
  methods: {
    formatNumber,
    calculateShare(creditsUsed) {
      if (!this.totalUsedCredits) return 0;
      return Math.round((creditsUsed / this.totalUsedCredits) * 100);
    },
    onNextPage(cursor) {
      this.$emit('next-page', cursor);
    },
    onPrevPage(cursor) {
      this.$emit('prev-page', cursor);
    },
  },
  tableFields: [
    {
      key: 'name',
      label: s__('UsageBilling|Product'),
    },
    {
      key: 'share',
      label: s__('UsageBilling|Share'),
      thAlignRight: true,
      tdClass: 'gl-text-right',
    },
    {
      key: 'creditsUsed',
      label: s__('UsageBilling|Credits used'),
      thAlignRight: true,
      tdClass: 'gl-text-right',
    },
  ],
};
</script>

<template>
  <div>
    <gl-table
      :items="productNodes"
      :fields="$options.tableFields"
      show-empty
      stacked="md"
      class="gl-w-full"
      borderless
    >
      <template #cell(name)="{ item: product }">
        <span class="gl-font-weight-semibold">{{ product.name }}</span>
      </template>

      <template #head(share)="{ label }">
        <div class="gl-flex gl-justify-end">{{ label }}</div>
      </template>

      <template #head(creditsUsed)="{ label }">
        <div class="gl-flex gl-justify-end">{{ label }}</div>
      </template>

      <template #cell(share)="{ item: product }">
        {{ calculateShare(product.creditsUsed) }}%
      </template>

      <template #cell(creditsUsed)="{ item: product }">
        {{ formatNumber(product.creditsUsed) }}
      </template>

      <template #empty>
        <div class="gl-py-6 gl-text-center">
          <p class="gl-mb-0 gl-text-subtle">{{ s__('UsageBilling|No product data available') }}</p>
        </div>
      </template>
    </gl-table>

    <div class="gl-mt-5 gl-flex gl-justify-center">
      <gl-keyset-pagination v-bind="products.pageInfo" @prev="onPrevPage" @next="onNextPage" />
    </div>
  </div>
</template>
