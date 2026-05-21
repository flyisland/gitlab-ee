import { GlButton } from '@gitlab/ui';
import UpgradeToPremiumCard from 'ee/usage_quotas/usage_billing/components/upgrade_to_premium_card.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';

describe('UpgradeToPremiumCard', () => {
  let wrapper;

  const createComponent = (provide = {}) => {
    wrapper = mountExtended(UpgradeToPremiumCard, {
      provide: {
        upgradeButtonPath: 'https://subscriptions.example.com',
        ...provide,
      },
    });
  };

  const findUpgradeButton = () => wrapper.findComponent(GlButton);
  const findCardTitle = () => wrapper.find('.gl-card-header');

  beforeEach(() => {
    createComponent();
  });

  it('renders card title', () => {
    expect(findCardTitle().text()).toBe('Unlock more credits with Premium');
  });

  it('renders message text', () => {
    expect(wrapper.text()).toContain('Upgrade to keep using GitLab Duo Agent Platform');
    expect(wrapper.text()).toContain('access a broad credit allocation');
  });

  it('renders upgrade button', () => {
    expect(findUpgradeButton().props('href')).toBe('https://subscriptions.example.com');
    expect(findUpgradeButton().text()).toBe('Upgrade to Premium');
  });

  describe('tracking', () => {
    useMockInternalEventsTracking();

    it('has correct tracking attributes on upgrade button', () => {
      expect(findUpgradeButton().attributes()).toMatchObject({
        'data-event-tracking': 'click_cta_upgrade_to_premium',
        'data-event-property': 'upgrade_to_premium_card',
      });
    });
  });
});
