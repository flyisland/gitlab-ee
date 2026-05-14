import { GlAvatarLabeled, GlAvatarLink, GlKeysetPagination, GlTable } from '@gitlab/ui';
import { nextTick } from 'vue';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import UsersList from 'ee/usage_quotas/wallet_agnostic_credits_dashboard/index/components/users_list.vue';
import { mockSubscriptionCreditsUsage } from '../mock_data';

describe('UsersList', () => {
  /** @type {import('helpers/vue_test_utils_helper').ExtendedWrapper} */
  let wrapper;

  const mockUsers = mockSubscriptionCreditsUsage.users;
  const mockUserUsagePath = '/test-group/-/usage_quotas/usage_billing/users/__USERNAME__';

  const createComponent = ({
    propsData: { users = mockUsers, userUsagePath = mockUserUsagePath } = {},
    mountFn = shallowMountExtended,
  } = {}) => {
    wrapper = mountFn(UsersList, {
      propsData: { users, userUsagePath },
    });
  };

  const findTable = () => wrapper.findComponent(GlTable);
  const findPagination = () => wrapper.findComponent(GlKeysetPagination);
  const findRows = () => findTable().find('tbody').findAll('tr');
  const findCell = (rowIndex, cellIndex) => findRows().at(rowIndex).findAll('td').at(cellIndex);
  const findAvatarLabeled = (rowIndex) => findRows().at(rowIndex).findComponent(GlAvatarLabeled);
  const findAvatarLink = (rowIndex) => findRows().at(rowIndex).findComponent(GlAvatarLink);

  describe('table rendering', () => {
    beforeEach(() => {
      createComponent({ mountFn: mountExtended });
    });

    it('renders the table', () => {
      expect(findTable().exists()).toBe(true);
    });

    it('renders a row for each user', () => {
      expect(findRows()).toHaveLength(mockUsers.nodes.length);
    });

    it('renders GlAvatarLabeled with user name and username', () => {
      const avatar = findAvatarLabeled(0);

      expect(avatar.props('label')).toBe('Alice Johnson');
      expect(avatar.props('subLabel')).toBe('@ajohnson');
      expect(avatar.props('src')).toBe(mockUsers.nodes[0].avatarUrl);
    });

    it('renders credits used in the second column', () => {
      expect(findCell(0, 1).text()).toBe('1.2k');
    });

    it('links to the user detail page', () => {
      const link = findAvatarLink(0);

      expect(link.attributes('href')).toBe(
        '/test-group/-/usage_quotas/usage_billing/users/ajohnson',
      );
    });
  });

  describe('pagination', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders pagination with correct props', () => {
      expect(findPagination().props()).toMatchObject({
        hasNextPage: mockUsers.pageInfo.hasNextPage,
        hasPreviousPage: mockUsers.pageInfo.hasPreviousPage,
        startCursor: mockUsers.pageInfo.startCursor,
        endCursor: mockUsers.pageInfo.endCursor,
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

  describe('empty state', () => {
    beforeEach(() => {
      createComponent({
        propsData: { users: { nodes: [] } },
        mountFn: mountExtended,
      });
    });

    it('renders the empty state message', () => {
      expect(findTable().text()).toContain('No user data available');
    });
  });
});
