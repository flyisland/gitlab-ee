import { GlCard } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import { helpPagePath } from '~/helpers/help_page_helper';
import { useMockInternalEventsTracking } from 'helpers/tracking_internal_events_helper';
import CreditPurchaseCard from 'ee/admin/subscriptions/show/components/credit_purchase_card.vue';

describe('CreditPurchaseCard', () => {
  let wrapper;

  const purchaseCreditsPath =
    'https://customers.gitlab.com/subscriptions/purchases/gitlab?deployment_type=self_managed&plan_type=gitlab_credits';

  const createComponent = (provide = {}) => {
    wrapper = shallowMountExtended(CreditPurchaseCard, {
      provide: {
        purchaseCreditsPath,
        ...provide,
      },
      stubs: { GlCard },
    });
  };

  const findCtaButton = () => wrapper.findByTestId('credit-purchase-card-cta-button');
  const findLearnMoreButton = () => wrapper.findByTestId('credit-purchase-card-learn-more-button');
  const findCreditsCount = () => wrapper.findByTestId('credits-count');

  beforeEach(() => {
    createComponent();
  });

  it('renders the card title', () => {
    expect(wrapper.text()).toContain('GitLab Credits');
  });

  it('renders the description', () => {
    expect(wrapper.text()).toContain(
      'Purchase monthly credits for your instance and unlock AI capabilities. Volume discounts available.',
    );
  });

  it('displays 0 credits', () => {
    expect(findCreditsCount().text()).toBe('0');
  });

  it('renders "Credits" label', () => {
    expect(wrapper.text()).toContain('Credits');
  });

  it('renders "Purchase credits" CTA with correct attributes', () => {
    expect(findCtaButton().text()).toBe('Purchase credits');
    expect(findCtaButton().attributes()).toMatchObject({
      href: purchaseCreditsPath,
      'data-event-tracking': 'click_purchase_credits_cta_on_sm_credits_card',
      'data-event-property': 'purchase_credits',
    });
  });

  it('renders learn more button with correct attributes', () => {
    expect(findLearnMoreButton().text()).toBe('Learn more');
    expect(findLearnMoreButton().attributes()).toMatchObject({
      href: helpPagePath('subscriptions/gitlab_credits'),
      target: '_blank',
      'data-event-tracking': 'click_learn_more_cta_on_sm_credits_card',
      'data-event-property': 'learn_more',
    });
  });

  describe('when purchaseCreditsPath is empty', () => {
    beforeEach(() => {
      createComponent({ purchaseCreditsPath: '' });
    });

    it('does not render the CTA button', () => {
      expect(findCtaButton().exists()).toBe(false);
    });

    it('still renders the learn more button', () => {
      expect(findLearnMoreButton().exists()).toBe(true);
    });
  });

  describe('tracking', () => {
    const { bindInternalEventDocument } = useMockInternalEventsTracking();
    let triggerEvent;
    let trackEventSpy;

    beforeEach(() => {
      ({ triggerEvent, trackEventSpy } = bindInternalEventDocument(wrapper.element));
    });

    it('fires click_purchase_credits_cta_on_sm_credits_card when CTA button is clicked', () => {
      triggerEvent('[data-testid="credit-purchase-card-cta-button"]');

      expect(trackEventSpy).toHaveBeenCalledWith('click_purchase_credits_cta_on_sm_credits_card', {
        property: 'purchase_credits',
      });
    });

    it('fires click_learn_more_cta_on_sm_credits_card when learn more button is clicked', () => {
      triggerEvent('[data-testid="credit-purchase-card-learn-more-button"]');

      expect(trackEventSpy).toHaveBeenCalledWith('click_learn_more_cta_on_sm_credits_card', {
        property: 'learn_more',
      });
    });
  });
});
