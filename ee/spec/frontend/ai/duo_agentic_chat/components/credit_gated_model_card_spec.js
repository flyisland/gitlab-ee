import { GlButton } from '@gitlab/ui';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import CreditGatedModelCard from 'ee/ai/duo_agentic_chat/components/credit_gated_model_card.vue';

describe('CreditGatedModelCard', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = mountExtended(CreditGatedModelCard, {
      propsData: {
        modelName: 'Claude Fable 5',
        purchaseCreditsPath: '/purchase-credits',
        canBuyAddon: true,
        ...props,
      },
    });
  };

  const findPurchaseButton = () => wrapper.findByTestId('purchase-credits-button');
  const findLearnMoreButton = () => wrapper.findByTestId('learn-more-button');
  const findDescription = () => wrapper.findByTestId('credit-gated-model-card-description');

  it('names the model the user picked', () => {
    createComponent();

    expect(wrapper.text()).toContain('Purchase credits to use Claude Fable 5');
  });

  it('explains why the model is unavailable and how to proceed', () => {
    createComponent();

    expect(wrapper.text()).toContain("This model isn't included in your trial");
    expect(wrapper.text()).toContain('or select another model');
  });

  it('links to the purchase path', () => {
    createComponent();

    expect(findPurchaseButton().attributes('href')).toBe('/purchase-credits');
  });

  it('links to the credits documentation', () => {
    createComponent();

    expect(findLearnMoreButton().attributes('href')).toContain(
      'subscriptions/gitlab_credits#for-the-free-tier',
    );
  });

  describe('when the user cannot buy the add-on', () => {
    beforeEach(() => {
      createComponent({ canBuyAddon: false });
    });

    it('offers documentation only', () => {
      expect(findPurchaseButton().exists()).toBe(false);
      expect(wrapper.findAllComponents(GlButton)).toHaveLength(1);
      expect(findLearnMoreButton().attributes('href')).toContain(
        'subscriptions/gitlab_credits#for-the-free-tier',
      );
    });

    it('does not tell the user to buy credits they have no permission to buy', () => {
      expect(wrapper.text()).not.toContain('Purchase credits to use');
      expect(wrapper.text()).toContain("Claude Fable 5 isn't included in your trial");
    });

    it('points at the administrator instead', () => {
      expect(findDescription().text()).toBe(
        'Select another model, or contact your administrator to purchase monthly credits.',
      );
    });
  });

  describe('when there is no purchase path', () => {
    it('does not render a broken purchase link', () => {
      createComponent({ purchaseCreditsPath: '' });

      expect(findPurchaseButton().exists()).toBe(false);
    });
  });
});
