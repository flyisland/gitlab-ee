import MockAdapter from 'axios-mock-adapter';
import { GlDisclosureDropdownGroup, GlIcon } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import UserMenuUpgradeSubscription from 'ee/super_sidebar/components/user_menu_upgrade_subscription.vue';
import { createAlert } from '~/alert';
import { PROMO_URL } from '~/constants';
import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';
import { HTTP_STATUS_OK, HTTP_STATUS_UNPROCESSABLE_ENTITY } from '~/lib/utils/http_status';

jest.mock('~/alert');

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn(),
}));

describe('UserMenuUpgradeSubscription component', () => {
  let wrapper;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    createAlert.mockClear();
  });

  afterEach(() => {
    mock.restore();
  });

  const createWrapper = (upgradeLink = {}) => {
    wrapper = mountExtended(UserMenuUpgradeSubscription, {
      propsData: {
        upgradeLink,
      },
    });
  };

  const findUpgradeSubscriptionGroup = () => wrapper.findComponent(GlDisclosureDropdownGroup);
  const findUpgradeSubscriptionItem = () => wrapper.findByTestId('upgrade-subscription-item');

  describe('when upgrade subscription is available', () => {
    beforeEach(() => {
      createWrapper({ url: '/groups/test-group/-/billings', text: 'Upgrade subscription' });
    });

    it('renders the upgrade subscription group', () => {
      expect(findUpgradeSubscriptionGroup().exists()).toBe(true);
    });

    it('renders the upgrade subscription menu item', () => {
      expect(findUpgradeSubscriptionItem().exists()).toBe(true);
    });

    it('should render a link to upgrade subscription with correct URL', () => {
      expect(findUpgradeSubscriptionItem().text()).toBe('Upgrade subscription');
    });

    it('has Snowplow tracking attributes', () => {
      expect(findUpgradeSubscriptionItem().find('button').attributes()).toMatchObject({
        'data-track-property': 'nav_user_menu',
        'data-track-action': 'click_link',
        'data-track-label': 'upgrade_subscription',
      });
    });

    it('renders with license icon', () => {
      const icon = findUpgradeSubscriptionItem().findComponent(GlIcon);

      expect(icon.exists()).toBe(true);
      expect(icon.props('name')).toBe('license');
    });

    it('renders with hotspot styling', () => {
      const hotspotElement = findUpgradeSubscriptionItem().find('.hotspot-pulse');

      expect(hotspotElement.exists()).toBe(true);
    });

    describe('onClick', () => {
      it('calls visitUrl with the upgrade link URL', () => {
        findUpgradeSubscriptionItem().vm.$emit('action');

        expect(visitUrl).toHaveBeenCalledWith('/groups/test-group/-/billings');
      });

      describe('when personal project', () => {
        const upgradeLink = {
          url: '/user_namespace/test-project/-/transfer_personal',
          text: 'Upgrade subscription',
          is_personal_project: true,
        };

        beforeEach(() => {
          createWrapper(upgradeLink);
        });

        it('makes a PUT request and redirects on success', async () => {
          const redirectUrl = '/groups/new-test-group/-/billings';

          mock.onPut(upgradeLink.url).reply(HTTP_STATUS_OK, { redirect_to: redirectUrl });

          findUpgradeSubscriptionItem().vm.$emit('action');

          await waitForPromises();

          expect(visitUrl).toHaveBeenCalledWith(redirectUrl);
        });

        describe('when the api responds with an error', () => {
          it('creates an alert', async () => {
            mock.onPut(upgradeLink.url).reply(HTTP_STATUS_UNPROCESSABLE_ENTITY);

            findUpgradeSubscriptionItem().vm.$emit('action');

            await waitForPromises();

            expect(createAlert).toHaveBeenCalledWith({
              title: 'Billing page is not available',
              message: expect.stringContaining(
                'An error occurred while assigning your project to a group for billing.',
              ),
              messageLinks: { link: { href: `${PROMO_URL}/pricing`, target: '_blank' } },
              primaryButton: expect.any(Object),
            });
          });
        });
      });
    });
  });
});
