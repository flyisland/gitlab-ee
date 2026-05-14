import { GlKeysetPagination, GlTable } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import ProductsList from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/products_list.vue';
import { mockSubscriptionCreditsUsage } from '../mock_data';

describe('ProductsList', () => {
  /** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
  let wrapper;

  const mockProducts = mockSubscriptionCreditsUsage.products;
  const mockTotalUsedCredits = mockSubscriptionCreditsUsage.creditsUsed;

  const createComponent = ({
    propsData: { products = mockProducts, totalUsedCredits = mockTotalUsedCredits } = {},
    mountFn = shallowMountExtended,
  } = {}) => {
    wrapper = mountFn(ProductsList, {
      propsData: { products, totalUsedCredits },
    });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findRows = () => findTable().find('tbody').findAll('tr');
  const findCell = (rowIndex, cellIndex) => findRows().at(rowIndex).findAll('td').at(cellIndex);

  describe('table rendering', () => {
    beforeEach(() => {
      createComponent({ mountFn: mountExtended });
    });

    it('renders the table', () => {
      expect(findTable().exists()).toBe(true);
    });

    it('renders a row for each product', () => {
      expect(findRows()).toHaveLength(mockProducts.nodes.length);
    });

    it('renders the product name in the first column', () => {
      expect(findCell(0, 0).text()).toBe('Hosted Runners');
    });

    it('renders the share percentage in the second column', () => {
      // 3200 / 13800 * 100 = ~23%
      expect(findCell(0, 1).text()).toBe('23%');
    });

    it('renders 0% share when totalUsedCredits is 0', () => {
      createComponent({
        propsData: {
          totalUsedCredits: 0,
        },
        mountFn: mountExtended,
      });
      expect(findCell(0, 1).text()).toBe('0%');
    });

    it('renders the credits used in the third column', () => {
      expect(findCell(0, 2).text()).toBe('3.2k');
    });
  });

  describe('empty state', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          products: {
            nodes: [],
            pageInfo: {},
          },
        },
        mountFn: mountExtended,
      });
    });

    it('renders the empty state message', () => {
      expect(findTable().text()).toContain('No product data available');
    });
  });

  describe('pagination', () => {
    beforeEach(() => {
      createComponent({ mountFn: mountExtended });
    });

    it('renders pagination with correct props', () => {
      expect(findPagination().props()).toMatchObject({
        hasNextPage: mockProducts.pageInfo.hasNextPage,
        hasPreviousPage: mockProducts.pageInfo.hasPreviousPage,
        startCursor: mockProducts.pageInfo.startCursor,
        endCursor: mockProducts.pageInfo.endCursor,
      });
    });

    it('emits next-page with the cursor on next', async () => {
      findPagination().vm.$emit('next', 'nextCursor');
      await nextTick();

      expect(wrapper.emitted('next-page')).toEqual([['nextCursor']]);
    });

    it('emits prev-page with the cursor on prev', async () => {
      findPagination().vm.$emit('prev', 'prevCursor');
      await nextTick();

      expect(wrapper.emitted('prev-page')).toEqual([['prevCursor']]);
    });
  });
});
