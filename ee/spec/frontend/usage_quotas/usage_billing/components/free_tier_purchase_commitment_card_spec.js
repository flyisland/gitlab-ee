import { GlButton } from '@gitlab/ui';
import FreeTierPurchaseCommitmentCard from 'ee/usage_quotas/usage_billing/components/free_tier_purchase_commitment_card.vue';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import { helpPagePath } from '~/helpers/help_page_helper';

describe('FreeTierPurchaseCommitmentCard', () => {
  let wrapper;

  const purchaseCreditsPath = 'https://customers.gitlab.com/purchase/credits';

  const createComponent = (provide = {}) => {
    wrapper = mountExtended(FreeTierPurchaseCommitmentCard, {
      provide: {
        purchaseCreditsPath,
        ...provide,
      },
    });
  };

  const findPurchaseButton = () => wrapper.findAllComponents(GlButton).at(0);
  const findLearnMoreButton = () => wrapper.findAllComponents(GlButton).at(1);
  const findCardTitle = () => wrapper.find('.gl-card-header');

  beforeEach(() => {
    createComponent();
  });

  it('renders card title', () => {
    expect(findCardTitle().text()).toBe('Save on GitLab Credits with monthly commitments');
  });

  it('renders card body', () => {
    expect(wrapper.text()).toContain(
      'Monthly commitments offer significant discounts off list price.',
    );
  });

  it('renders purchase credits button with correct href', () => {
    expect(findPurchaseButton().props('href')).toBe(purchaseCreditsPath);
    expect(findPurchaseButton().props('variant')).toBe('confirm');
    expect(findPurchaseButton().text()).toBe('Purchase credits');
  });

  it('renders learn more button with correct href', () => {
    expect(findLearnMoreButton().props('href')).toBe(helpPagePath('subscriptions/gitlab_credits'));
    expect(findLearnMoreButton().props('variant')).toBe('confirm');
    expect(findLearnMoreButton().props('category')).toBe('tertiary');
    expect(findLearnMoreButton().text()).toBe('Learn more');
  });

  describe('tracking', () => {
    it('has correct tracking attributes on purchase credits button', () => {
      expect(findPurchaseButton().attributes()).toMatchObject({
        'data-event-tracking': 'click_purchase_credits_cta_active_trial',
      });
    });

    it('has correct tracking attributes on learn more button', () => {
      expect(findLearnMoreButton().attributes()).toMatchObject({
        'data-event-tracking': 'click_learn_more_link_free_tier_purchase_commitment',
      });
    });
  });
});
